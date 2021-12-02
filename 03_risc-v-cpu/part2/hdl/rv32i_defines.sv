`ifndef RV32I_DEFINES
`define RV32I_DEFINES

// Memory Map (based on Fig. 6.31 in H&H)
`define MEM_MAP_TEXT_START    32'h00010000
`define MEM_MAP_GLOBALS_START 32'h10000000
`define MEM_MAP_HEAP_START    32'h10001000
`define MEM_MAP_STACK_TOP     32'hBFFFFFF0
`define MEM_MAP_OS_START      32'hC0000000

// addi x0, x0, 0 aka NOP (no operation)
`define RV32_NOP 32'h0000_0013 

typedef enum logic [6:0] {
  OP_LTYPE = 7'b0000011,
  OP_ITYPE = 7'b0010011,
  OP_AUIPC = 7'b0010111,
  OP_STYPE = 7'b0100011,
  OP_RTYPE = 7'b0110011,
  OP_LUI   = 7'b0110111,
  OP_BTYPE = 7'b1100011,
  OP_JALR  = 7'b1100111,
  OP_JAL   = 7'b1101111
} op_type_t;

typedef enum logic [2:0] {
  FUNCT3_LOAD_LB  = 3'b000,
  FUNCT3_LOAD_LH  = 3'b001,
  FUNCT3_LOAD_LW  = 3'b010,
  FUNCT3_LOAD_LBU = 3'b100,
  FUNCT3_LOAD_LHU = 3'b101
} funct3_load_t;

typedef enum logic [2:0] {
  FUNCT3_ADDI = 3'b000,
  FUNCT3_SLLI = 3'b001,
  FUNCT3_SLTI = 3'b010,
  FUNCT3_SLTIU = 3'b011,
  FUNCT3_XORI = 3'b100,
  FUNCT3_SHIFT_RIGHT = 3'b101, // Needs a funct7 bit to determine!
  FUNCT3_ORI = 3'b110,
  FUNCT3_ANDI = 3'b111
} funct3_itype_t;


`endif // RV32I_DEFINES