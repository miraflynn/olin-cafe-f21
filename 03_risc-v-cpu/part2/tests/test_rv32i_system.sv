`timescale 1ns/1ps
`default_nettype none

module test_rv32i_system;

localparam MAX_CYCLES = 10;

logic clk, rst, ena;

rv32i_system UUT(.clk(clk), .rst(rst), .ena(ena));

initial begin
  $dumpfile("rv32i_system.fst");
  $dumpvars(0, UUT);
  clk = 0;
  rst = 1;
  ena = 1;

  repeat (2) @(negedge clk);
  rst = 0;
  repeat (MAX_CYCLES) @(posedge clk);
  @(negedge clk);
  
  $display("Ran %d cycles, finishing.", MAX_CYCLES);

  $finish;
end

always #5 clk = ~clk;

endmodule
