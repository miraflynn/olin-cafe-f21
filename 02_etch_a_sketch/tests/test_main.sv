`timescale 1ns / 100ps
`default_nettype none

module test_main;
parameter CLK_HZ = 12_000_000;
parameter CLK_PERIOD_NS = (1_000_000_000/CLK_HZ); // Approximation.
//Module I/O and parameters
logic clk;
logic [1:0] buttons;
wire [1:0] leds;
wire [2:0] rgb;

main #(.PWM_WIDTH(4)) UUT(
    .clk(clk), .buttons(buttons), .leds(leds), .rgb(rgb)
);

logic [63:0] cycles_to_run = CLK_HZ/10; // Run for 100ms real time. Warning, this will make a large (~170MB) log file, be careful!

// Run our main clock.
always #(CLK_PERIOD_NS/2) clk = ~clk;

initial begin
  // Collect waveforms
  $dumpfile("main.vcd");
  $dumpvars(0, UUT);
  // $dumplimit(100_000_000); // Enable this if you are low on space!
  // Initialize module inputs.
  clk = 0;
  buttons = 2'b11; //using button[0] as reset.
  // Assert reset for long enough.
  repeat(2) @(negedge clk);
  buttons = 2'b00;
  $display("Running for %d clock cycles. ", cycles_to_run);
  repeat (cycles_to_run) @(posedge clk); 

  $finish;
end



endmodule
