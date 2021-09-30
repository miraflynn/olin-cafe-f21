/*
2 bits full adder daisy chaining 2 1 bit adders
*/

module adder_1(a, b, c_in, sum, c_out);

input wire [1:] a, b
input wire c_in;

output logic [1:0] sum
output logic c_out;

wire carry
adder_1 ADDER_0(
    .a(a[0]),
    .b(b[0]),
    .c_in(c_in),
    .sum(sum[0])
    .c_out(carry)
);

endmodule