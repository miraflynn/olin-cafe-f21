`timescale 1ns / 1ps
`default_nettype none

`define SIMULATION

module test_conway_cell;

  logic clk, rst, ena, state_0;
  logic [7:0] neighbors;
  wire state_d, state_q;

  conway_cell UUT(
    .clk(clk), .rst(rst), .ena(ena),
    .neighbors(neighbors),
    .state_0(1'b1), .state_d(state_d), .state_q(state_q)
  );

  always #5 clk = ~clk; // Toggle a clock every 5 time units.
	

  /*
    Initial blocks are one of the few things in Verilog that actually
    executes sequentially like normal code, and runs at the top of a 
    simulation. This can sometimes work in synthesis... but it's much
    better practice to use proper synchronous reset logic instead!
  */
  initial begin
    // Initialize modules input.
    clk = 0;
    rst = 1; // Start reset in active state.
    ena = 1; // Not testing the ena function in this example (though you should try!)
    state_0 = 0; //literally what the fuck does this do
    
    // Collect all internal variables for waveforms.
    $dumpfile("conway_cell.vcd");
    $dumpvars(0, UUT);
    
    // Wait at least one clock cycle before deasserting reset.
    repeat (2) @(posedge clk);
    rst = 0;
    
    $display("lrud : d : q");
    for (int i = 0; i < 256; i = i + 1) begin
      // Change inputs at a negative edge to avoid setup issues.
      @(negedge clk);
      neighbors = i[7:0];
      @(posedge clk);
      $display("%b : %b: %b", neighbors, state_d, state_q);
    end

    #10;
    $finish; // End the simulation.
	end

endmodule
