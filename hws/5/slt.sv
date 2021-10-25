module slt(a, b, out);
parameter N = 32;
input wire signed [N-1:0] a, b;
output logic out;

// Using only *structural* combinational logic, make a module that computes if a is less than b!
// Note: this assumes that the two inputs are signed: aka should be interpreted as two's complement.

// Copy any other modules you use into this folder and update the Makefile accordingly.

// Gati helped me out with figuring out that I declared the adder inside always_comb

logic c_in = 1'b1;
logic signed [N-1:0] sum;
wire c_out;

add32 adder(.a(a), .b(~b), .c_in(c_in), .sum(sum), .c_out(c_out));

always_comb begin
    out = ((a[N-1] ~^ b[N-1]) & sum[N-1]) | (a[N-1] & ~b[N-1]);
end

endmodule