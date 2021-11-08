`timescale 1ns/1ps
`default_nettype none

`include "alu_types.sv"

module alu(a, b, control, result, overflow, zero, equal);
parameter N = 32; // Don't need to support other numbers, just using this as a constant.

input wire [N-1:0] a, b; // Inputs to the ALU.
input alu_control_t control; // Sets the current operation.
output logic [N-1:0] result; // Result of the selected operation.

output logic overflow; // Is high if the result of an ADD or SUB wraps around the 32 bit boundary.
output logic zero;  // Is high if the result is ever all zeros.
output logic equal; // is high if a == b.

// Use *only* structural logic and previously defined modules to implement an 
// ALU that can do all of operations defined in alu_types.sv's alu_op_code_t!


// AND
logic [N-1:0] and_result;
always_comb begin
    and_result = a & b;
end
// OR
logic [N-1:0] or_result;
always_comb begin
    or_result = a | b;
end
// XOR
logic [N-1:0] xor_result;
always_comb begin 
    xor_result = a ^ b;
end

// SHIFTERS

// NOTE: My solution here returns all 0s for b = 32. The alu_behavioural works 
// for b = 32. The assignment document states to return all 0s for b >= 32, 
// which is what mine does.
wire [$clog2(N)-1:0] shamt = b[$clog2(N)-1:0];
logic [N-1:0] shift_result;
logic [N-1:0] shift_result_temp;
// SLL
logic [N-1:0] sll_result;
shift_left_logical #(.N(N)) SLL(.in(a), .shamt(shamt), .out(sll_result));
// SRL
logic [N-1:0] srl_result;
shift_right_logical #(.N(N)) SRL(.in(a), .shamt(shamt), .out(srl_result));
// SRA
logic [N-1:0] sra_result;
shift_right_arithmetic #(.N(N)) SRA(.in(a), .shamt(shamt), .out(sra_result));

mux4 #(.N(N)) SHIFT_MUX(
    .in0(0),
    .in1(sll_result),
    .in2(srl_result),
    .in3(sra_result),
    .switch(control[1:0]),
    .out(shift_result_temp)
);
always_comb begin
    shift_result = (shamt == b) ? shift_result_temp : 0;
    // This is a bit strange but it seems that comparing two values with 
    // different numbers of bits works by filling the shorter one with zeros on 
    // the left
end


// ADD and SUB
logic [N-1:0] add_result;
wire add_c_out;
logic [N-1:0] add_b;
logic c_in;

always_comb begin
    add_b = control[2] ? ~b : b;
    c_in = control[2] ? 1'b1 : 1'b0;
end

adder_n #(.N(N)) ADDER(
  .a(a), .b(add_b), .c_in(c_in),
  .c_out(add_c_out), .sum(add_result)
);

// SLT
logic [N-1:0] slt_result;
slt #(.N(N)) SLT(.a(a), .b(b), .out(slt_result));
// SLTU
logic [N-1:0] sltu_result;
sltu #(.N(N)) SLTU(.a(a), .b(b), .out(sltu_result));

// ALU_AND  = 4'b0001, // 1
// ALU_OR   = 4'b0010, // 2
// ALU_XOR  = 4'b0011, // 3
// ALU_SLL  = 4'b0101, // 5
// ALU_SRL  = 4'b0110, // 6
// ALU_SRA  = 4'b0111, // 7
// ALU_ADD  = 4'b1000, // 8
// ALU_SUB  = 4'b1100, // 12
// ALU_SLT  = 4'b1101, // 13
// ALU_SLTU = 4'b1111  // 15

logic [N-1:0] error = 0;

mux16 #(.N(N)) CONTROL_MUX(
    .in0(error),
    .in1(and_result),
    .in2(or_result),
    .in3(xor_result),
    .in4(error),
    .in5(shift_result),
    .in6(shift_result),
    .in7(shift_result),
    .in8(add_result),
    .in9(error),
    .in10(error),
    .in11(error),
    .in12(add_result),
    .in13(slt_result),
    .in14(error),
    .in15(sltu_result),
    .switch(control),
    .out(result)
    );

logic [N-1:0] zero_check = 0;
always_comb begin
    zero = result == zero_check;
    equal = a == b;

    overflow = 
    ((control == 4'b1000) & 
    (a[N-1] == b[N-1]) &
    (a[N-1] != add_result[N-1])) |

    // This throws an overflow error for SLTU even though my SLTU does not 
    // overflow
    // Also sorry for the unholy parenthesis, there was some priority stuff 
    // going on in my code so I added parenthesis everywhere possible
    (((control == 4'b1100) | (control == 4'b1101) | (control == 4'b1111)) & 
    ((a[N-1] != b[N-1]) & 
    a[N-1] != add_result[N-1]));
end

endmodule