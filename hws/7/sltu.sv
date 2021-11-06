module sltu(a, b, out);
parameter N = 32;
input wire [N-1:0] a, b;
wire signed [N:0] x = {1'b0, a[N-1:0]};
wire signed [N:0] y = {1'b0, b[N-1:0]};
output logic out;

// Using only *structural* combinational logic, make a module that computes if a is less than b!
// Note: this assumes that the two inputs are unsigned

// Copy any other modules you use into this folder and update the Makefile accordingly.

// Remember that you can make a subtractor with a 32 bit adder if you set the carry_in bit high, and invert one of the inputs.


logic [N:0] not_y;
always_comb not_y = ~y;
wire c_out;
wire [N:0] difference; 
adder_n #(.N(N+1)) SUBTRACTOR(
  .a(x), .b(not_y), .c_in(1'b1),
  .c_out(c_out), .sum(difference[N:0])
);


always_comb begin
    out = difference[N];
end

endmodule


