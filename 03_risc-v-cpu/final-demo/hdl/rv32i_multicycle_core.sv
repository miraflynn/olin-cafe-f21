`timescale 1ns/1ps
`default_nettype none

`include "alu_types.sv"
`include "rv32i_defines.sv"

/*
 Based on H&H Section 7.4.10
 Unimplemented instructions 
 lb
 lh
 lbu
 lhu
 auipc
 sb
 sh 
 jalr
 jal
*/

module rv32i_multicycle_core(
  clk, rst, ena,
  mem_addr, mem_rd_data, mem_wr_data, mem_wr_ena,
  PC
);

parameter PC_START_ADDRESS=0; // `MEM_MAP_TEXT_START;

// Standard control signals.
input  wire clk, rst, ena; // <- worry about implementing the ena signal last.

// Memory interface.
output logic [31:0] mem_addr, mem_wr_data;
input   wire [31:0] mem_rd_data;
output logic mem_wr_ena;

// Program Counter
output wire [31:0] PC;
wire [31:0] PC_old;
logic PC_ena;
logic [31:0] PC_next; 

// Control Signals
// Decoder
logic [6:0] op;
logic [2:0] funct3;
logic [6:0] funct7;
logic rtype, itype, ltype, stype, btype, jtype;
enum logic [1:0] {IMM_SRC_ITYPE, IMM_SRC_STYPE, IMM_SRC_BTYPE, IMM_SRC_JTYPE} immediate_src;
logic [31:0] extended_immediate;
// R-file Control Signals
logic [4:0] rd, rs1, rs2;
wire [31:0] reg_data1, reg_data2;
logic reg_write;
logic [31:0] rfile_wr_data;
wire [31:0] reg_A, reg_B;
// ALU Control Signals
enum logic [1:0] {ALU_SRC_A_PC, ALU_SRC_A_RF, ALU_SRC_A_OLD_PC} alu_src_a;
enum logic [1:0] {ALU_SRC_B_RF, ALU_SRC_B_IMM, ALU_SRC_B_4} alu_src_b;
logic [31:0] src_a, src_b;
wire [31:0] alu_result;
alu_control_t alu_control, ri_alu_control;
wire overflow;
wire zero;
wire equal;
// Non-architectural Register Signals
logic IR_write;
wire [31:0] IR; // Instruction Register (current instruction)
logic ALU_ena;
wire [31:0] alu_last; // Not a descriptive name, but this is what it's called in the text.
logic mem_data_ena;
wire [31:0] mem_data;
enum logic {MEM_SRC_PC, MEM_SRC_RESULT} mem_src;
enum logic [1:0] {RESULT_SRC_ALU, RESULT_SRC_MEM_DATA, RESULT_SRC_ALU_LAST} result_src; 
logic [31:0] result;

// Program Counter Registers
register #(.N(32), .RESET(PC_START_ADDRESS)) PC_REGISTER (
  .clk(clk), .rst(rst), .ena(PC_ena), .d(PC_next), .q(PC)
);
register #(.N(32)) PC_OLD_REGISTER(
  .clk(clk), .rst(rst), .ena(PC_ena), .d(PC), .q(PC_old)
);

// Register file
register_file REGISTER_FILE(
  .clk(clk), 
  .wr_ena(reg_write), .wr_addr(rd), .wr_data(rfile_wr_data),
  .rd_addr0(rs1), .rd_addr1(rs2),
  .rd_data0(reg_data1), .rd_data1(reg_data2)
);

// Non-architecture register: save register read data for future cycles.
register #(.N(32)) REGISTER_A (.clk(clk), .rst(rst), .ena(1'b1), .d(reg_data1), .q(reg_A));
register #(.N(32)) REGISTER_B (.clk(clk), .rst(rst), .ena(1'b1), .d(reg_data2), .q(reg_B));
always_comb mem_wr_data = reg_B;

// ALU and related control signals
// Feel free to replace with your ALU from the homework.
alu_behavioural ALU (
  .a(src_a), .b(src_b), .result(alu_result),
  .control(alu_control),
  .overflow(overflow), .zero(zero), .equal(equal)
);
always_comb begin : ALU_MUX_A
  case (alu_src_a)
    ALU_SRC_A_PC: src_a = PC;
    ALU_SRC_A_RF: src_a = reg_A;
    ALU_SRC_A_OLD_PC: src_a = PC_old;
    default: src_a = 0;
  endcase 
end
always_comb begin : ALU_MUX_B
  case (alu_src_b)
    ALU_SRC_B_RF: src_b = reg_B;
    ALU_SRC_B_IMM: src_b = extended_immediate;
    ALU_SRC_B_4: src_b = 32'd4;
    default: src_b = 0;
  endcase
end

always_comb begin : ALU_CONTROL_DECODING
  case(funct3)
    FUNCT3_ADD : begin
      if(rtype & funct7[5]) ri_alu_control = ALU_SUB;
      else ri_alu_control = ALU_ADD;
    end
    FUNCT3_SLL : ri_alu_control = ALU_SLL;
    FUNCT3_SLT : ri_alu_control = ALU_SLT;
    FUNCT3_SLTU : ri_alu_control = ALU_SLTU;
    FUNCT3_XOR : ri_alu_control = ALU_XOR;
    FUNCT3_SHIFT_RIGHT : begin
      if(funct7[5]) ri_alu_control = ALU_SRL;
      else ri_alu_control = ALU_SRA;
    end
    FUNCT3_OR : ri_alu_control = ALU_OR;
    FUNCT3_AND : ri_alu_control = ALU_AND;
  endcase
end

// Non-architectural Register: IR
// Stores the current instruction once it's ready from memory.
register #(.N(32)) IR_REGISTER (
  .clk(clk), .rst(rst), .ena(IR_write), .d(mem_rd_data), .q(IR)
);

// Non-architectural Register: ALU Result
// Stores the ALU result for future clock cycles.
register #(.N(32)) ALU_REGISTER(
  .clk(clk), .rst(rst), .ena(ALU_ena), .d(alu_result), .q(alu_last)
);

// Non-architectural Register: Memory Data
register #(.N(32)) MEM_DATA_REGISTER(
  .clk(clk), .rst(rst), .ena(mem_data_ena), .d(mem_rd_data), .q(mem_data)
);

// Memory Address Mux
always_comb begin : MEM_ADDR_MUX
  case(mem_src)
    MEM_SRC_PC : mem_addr = PC;
    MEM_SRC_RESULT: mem_addr = result;
  endcase
end

// Result Muxing
always_comb begin: RESULT_MUX
  case(result_src)
    RESULT_SRC_ALU: result = alu_result;
    RESULT_SRC_MEM_DATA: result = mem_data;
    RESULT_SRC_ALU_LAST: result = alu_last;
    default: result = alu_result;
  endcase
end
always_comb begin : RESULT_ALIASES // Worth having separate names for debugging.
  PC_next = result;
  rfile_wr_data = result;
end

// Instruction Decoding
always_comb begin : instruction_decoder
  // Pull apart instruction
  op = IR[6:0];
  rd = IR[11:7];
  rs1 = IR[19:15];
  rs2 = IR[24:20];
  funct3 = IR[14:12];
  funct7 = IR[31:25];

  // Comparators to see which op type it is (could be more efficient with gates given how elegant the op code encoding is, but these signals are very useful for debugging).
  ltype = (op == OP_LTYPE);
  itype = (op == OP_ITYPE);
  rtype = (op == OP_RTYPE);
  stype = (op == OP_STYPE);
  btype = (op == OP_BTYPE);
  jtype = (op == OP_JAL) | (op == OP_JALR);
  
  // Immediate decoding
  case(op)
    OP_ITYPE: immediate_src = IMM_SRC_ITYPE;
    OP_STYPE: immediate_src = IMM_SRC_STYPE;
    OP_BTYPE: immediate_src = IMM_SRC_BTYPE;
    OP_JALR : immediate_src = IMM_SRC_ITYPE;
    OP_JAL  : immediate_src = IMM_SRC_JTYPE;
    default: immediate_src = IMM_SRC_ITYPE; // immediate isn't used under any other op codes, so we could put anything here.
  endcase

  // TODO(avinash) be better about showing how RISC-V lets this happen with less logic. Maybe with a side comment of how "back in my day" ISAs weren't that nice.
  case(immediate_src)
    IMM_SRC_ITYPE : extended_immediate = {{20{IR[31]}}, IR[31:20]};
    IMM_SRC_STYPE : extended_immediate = {{20{IR[31]}}, IR[31:25],IR[11:7]};
    IMM_SRC_BTYPE : extended_immediate = {{20{IR[31]}}, IR[7],IR[30:25], IR[11:8], 1'b0};
    IMM_SRC_JTYPE : extended_immediate = {{12{IR[31]}}, IR[19:12], IR[20], IR[30:21], 1'b0};
  endcase
end


// Multicycle FSM
enum logic [3:0] {
  // Cycle 1: Get the current instruction, store in IR.
  S_FETCH = 0,
  // Cycle 2: Decode the instruction.
  S_DECODE = 1, 
  // Cycle 3: Varies based on op code.
  S_MEM_ADDR = 2, S_EXECUTE_R = 3, S_EXECUTE_I = 4, 
  S_JAL =5 , S_JALR = 6, S_BRANCH = 7,
  // Cycle 4: Varies based on op code.
  S_ALU_WRITEBACK = 8, S_MEM_READ = 9, S_MEM_WRITE = 10, S_JUMP_WRITEBACK = 11,
  // Cycle 5: For load instructions.
  S_MEM_WRITEBACK = 12,
  S_ERROR = 4'hF
} state;
always_ff @(posedge clk) begin : MULTICYCLE_FSM
  if(rst)  state <= S_FETCH;
  else begin
    case(state)
      S_FETCH: begin
        state <= S_DECODE;
      end
      S_DECODE: begin
`ifdef SIMULATION 
        $display("PC = 0x%h, IR = 0x%h, decoded op: %s", PC, IR, op_name(op));
`endif // SIMULATION
        case(op)
          OP_RTYPE: state <= S_EXECUTE_R;
          OP_ITYPE: state <= S_EXECUTE_I;
          OP_STYPE, OP_LTYPE, OP_LUI: state <= S_MEM_ADDR;
          OP_JAL: state <= S_JAL;
          OP_JALR: state <= S_JALR;
          OP_BTYPE: state <= S_BRANCH;
          default: begin
            $display("Error: op %b not implemented yet", op);
            state <= S_ERROR;
          end
        endcase
      end
      S_MEM_ADDR: begin
        case(op)
          OP_LTYPE, OP_LUI: state <= S_MEM_READ;
          OP_STYPE: state <= S_MEM_WRITE;
          default: state <= S_ERROR; 
        endcase
      end
      S_EXECUTE_R, S_EXECUTE_I: begin
        state <= S_ALU_WRITEBACK;
      end
      S_JAL : begin
        state <= S_JUMP_WRITEBACK;
      end
      S_JALR: begin
        state <= S_JUMP_WRITEBACK;
      end
      S_JUMP_WRITEBACK : begin
        state <= S_FETCH;
      end
      S_BRANCH: begin
        state <= S_FETCH;
      end
      S_MEM_READ: begin
        state <= S_MEM_WRITEBACK;
      end
      S_ALU_WRITEBACK, S_MEM_WRITEBACK, S_MEM_WRITE: begin
        state <= S_FETCH;
      end
      default: begin
        state <= S_ERROR;
      end
    endcase
  end
end
always_comb begin : MULTICYCLE_FSM_COMB_OUTPUTS
// This is the laziest way to do this: it's more compact if you reason about the states and do custom comb. logic. 
// That said, making it work is the highest priority! Optimize only when you need to.
  case(state)
    S_FETCH: begin
      mem_wr_ena = 0;
      PC_ena = 1;
      reg_write = 0;
      alu_src_a = ALU_SRC_A_PC;
      alu_src_b = ALU_SRC_B_4;
      IR_write = 1;
      ALU_ena = 0;
      mem_data_ena = 0;
      mem_src = MEM_SRC_PC;
      result_src = RESULT_SRC_ALU;
      alu_control = ALU_ADD;
    end
    S_DECODE: begin
      mem_wr_ena = 0;
      PC_ena = 0;
      reg_write = 0;
      alu_src_a = ALU_SRC_A_OLD_PC;
      alu_src_b = ALU_SRC_B_IMM;
      IR_write = 0;
      ALU_ena = 1;
      mem_data_ena = 0;
      mem_src = MEM_SRC_PC;
      result_src = RESULT_SRC_ALU;
      alu_control = ALU_ADD;
    end
    S_EXECUTE_R: begin
      mem_wr_ena = 0;
      PC_ena = 0;
      reg_write = 0;
      alu_src_a = ALU_SRC_A_RF;
      alu_src_b = ALU_SRC_B_RF;
      IR_write = 0;
      ALU_ena = 1;
      mem_data_ena = 0;
      mem_src = MEM_SRC_PC;
      result_src = RESULT_SRC_ALU;
      alu_control = ri_alu_control;
    end
    S_EXECUTE_I: begin
      mem_wr_ena = 0;
      PC_ena = 0;
      reg_write = 0;
      alu_src_a = ALU_SRC_A_RF;
      alu_src_b = ALU_SRC_B_IMM;
      IR_write = 0;
      ALU_ena = 1;
      mem_data_ena = 0;
      mem_src = MEM_SRC_PC;
      result_src = RESULT_SRC_ALU;
      alu_control = ri_alu_control;
    end
    S_ALU_WRITEBACK: begin
      mem_wr_ena = 0;
      PC_ena = 0;
      reg_write = 1;
      alu_src_a = ALU_SRC_A_RF;
      alu_src_b = ALU_SRC_B_RF;
      IR_write = 0;
      ALU_ena = 0;
      mem_data_ena = 0;
      mem_src = MEM_SRC_PC;
      result_src = RESULT_SRC_ALU_LAST;
      alu_control = ALU_INVALID;
    end
    S_MEM_ADDR: begin
      mem_wr_ena = 0;
      PC_ena = 0;
      reg_write = 0;
      alu_src_a = ALU_SRC_A_RF;
      alu_src_b = ALU_SRC_B_IMM;
      IR_write = 0;
      ALU_ena = 1;
      mem_data_ena = 0;
      mem_src = MEM_SRC_RESULT;
      result_src = RESULT_SRC_ALU;
      alu_control = ALU_ADD;
    end
    S_MEM_READ: begin
      mem_wr_ena = 0;
      PC_ena = 0;
      reg_write = 0;
      alu_src_a = ALU_SRC_A_RF;
      alu_src_b = ALU_SRC_B_IMM;
      IR_write = 0;
      ALU_ena = 0;
      mem_data_ena = 1;
      mem_src = MEM_SRC_RESULT;
      result_src = RESULT_SRC_ALU_LAST;
      alu_control = ALU_INVALID;
    end
    S_MEM_WRITE: begin
      mem_wr_ena = 1;
      PC_ena = 0;
      reg_write = 0;
      alu_src_a = ALU_SRC_A_RF;
      alu_src_b = ALU_SRC_B_IMM;
      IR_write = 0;
      ALU_ena = 0;
      mem_data_ena = 1;
      mem_src = MEM_SRC_RESULT;
      result_src = RESULT_SRC_ALU_LAST; // TODO: check mux here
      alu_control = ALU_INVALID;
    end
    S_MEM_WRITEBACK: begin
      mem_wr_ena = 0;
      PC_ena = 0;
      reg_write = 1;
      alu_src_a = ALU_SRC_A_RF;
      alu_src_b = ALU_SRC_B_IMM;
      IR_write = 0;
      ALU_ena = 1;
      mem_data_ena = 0;
      mem_src = MEM_SRC_PC;
      result_src = RESULT_SRC_MEM_DATA;
      alu_control = ALU_INVALID;
    end
    S_BRANCH: begin
      mem_wr_ena = 0;
      // This is the readable version, you can do it far more elegantly by muxing equal and alu_result[0] intelligently using the funct3 bits.
      case(funct3)
        FUNCT3_BEQ: PC_ena = equal;
        FUNCT3_BNE: PC_ena = ~equal;
        FUNCT3_BLT, FUNCT3_BLTU: PC_ena = alu_result[0];
        FUNCT3_BGE, FUNCT3_BGEU: PC_ena = ~alu_result[0];
        default: PC_ena = 0;
      endcase
      reg_write = 0;
      alu_src_a = ALU_SRC_A_RF;
      alu_src_b = ALU_SRC_B_RF;
      IR_write = 0;
      ALU_ena = 1;
      mem_data_ena = 0;
      mem_src = MEM_SRC_PC;
      result_src = RESULT_SRC_ALU_LAST;
      if(funct3[1]) alu_control = ALU_SLTU;
      else alu_control = ALU_SLT;
    end
    S_JAL: begin
      mem_wr_ena = 0;
      PC_ena = 1;
      reg_write = 0;
      alu_src_a = ALU_SRC_A_OLD_PC;
      alu_src_b = ALU_SRC_B_IMM;
      IR_write = 0;
      ALU_ena = 0;
      mem_data_ena = 0;
      mem_src = MEM_SRC_PC;
      result_src = RESULT_SRC_ALU;
      alu_control = ALU_ADD;
    end
    S_JALR: begin
      mem_wr_ena = 0;
      PC_ena = 1;
      reg_write = 0;
      alu_src_a = ALU_SRC_A_RF;
      alu_src_b = ALU_SRC_B_IMM;
      IR_write = 0;
      ALU_ena = 0;
      mem_data_ena = 0;
      mem_src = MEM_SRC_PC;
      result_src = RESULT_SRC_ALU;
      alu_control = ALU_ADD;
    end
    S_JUMP_WRITEBACK : begin
      mem_wr_ena = 0;
      PC_ena = 0;
      reg_write = 1;
      alu_src_a = ALU_SRC_A_OLD_PC;
      alu_src_b = ALU_SRC_B_4;
      IR_write = 0;
      ALU_ena = 0;
      mem_data_ena = 0;
      mem_src = MEM_SRC_PC;
      result_src = RESULT_SRC_ALU; //TODO check this one
      alu_control = ALU_ADD;
    end
    default: begin
      mem_wr_ena = 0;
      PC_ena = 0;
      reg_write = 0;
      alu_src_a = ALU_SRC_A_RF;
      alu_src_b = ALU_SRC_B_RF;
      IR_write = 0;
      ALU_ena = 0;
      mem_data_ena = 0;
      mem_src = MEM_SRC_PC;
      result_src = RESULT_SRC_ALU;
      alu_control = ALU_INVALID;
    end
  endcase
end

endmodule
