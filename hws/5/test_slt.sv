`timescale 1ns/1ps
`default_nettype none
module test_slt;

parameter N = 32;

int errors = 0;

logic signed [N-1:0] a, b; // Adding the 'signed' keyword here makes the behavioural logic computes a signed slt.
wire out;

slt #(.N(N)) UUT(.a(a), .b(b), .out(out));

/*
It's impossible to exhaustively test all inputs as N gets larger, there are just
too many possibilities. Instead we can use a combination of testing interesting 
specified edge cases (e.g. adding by zero, seeing what happens on an overflow)
and some random testing! SystemVerilog has a lot of capabilities for this 
that we'll explore in further testbenches.
  1) the tester: sets inputs
  2) checker(s): verifies that the functionality of our HDL is correct
                 using higher level programming constructs that don't translate*
                 to real hardware.
*Okay, many of them do, but we're trying to learn here, right?
*/


// Some behavioural comb. logic that computes correct values.
logic correct_out;

always_comb begin : behavioural_solution_logic
  correct_out = a < b;
end

// You can make "tasks" in testbenches. Think of them like methods of a class, 
// they have access to the member variables.
task print_io;
  $display("%d < %d (%d)", a, b, out, correct_out);
endtask


// 2) the test cases
initial begin
  $dumpfile("slt.vcd");
  $dumpvars(0, UUT);
  
  $display("Specific interesting tests.");

  a = 0;
  b = 0;
  #1 print_io();
  
  a = -1;
  b = 1;
  #1 print_io();

  a = -1;
  b = 1;
  #1 print_io();

  // Overflow case with carry in.
  a = (1 << (N-1)) -1;
  b = (1 << (N-1));
  #1 print_io();
  
  $display("Random testing.");
  for (int i = 0; i < 100; i = i + 1) begin : random_testing
    a = $random();
    b = $random();
    #1 print_io();
  end
  if (errors !== 0) begin
    $display("---------------------------------------------------------------");
    $display("-- FAILURE                                                   --");
    $display("---------------------------------------------------------------");
    $display(" %d failures found, try again!", errors);
  end else begin
    $display("---------------------------------------------------------------");
    $display("-- SUCCESS                                                   --");
    $display("---------------------------------------------------------------");
  end
  $finish;
end

// Note: the triple === (corresponding !==) check 4-state (e.g. 0,1,x,z) values.
//       It's best practice to use these for checkers!
always @(a or b) begin
  #1;
  assert(out === correct_out) else begin
    $display("  ERROR: sum should be %b, is %b", out, correct_out);
    errors = errors + 1;
  end
end

endmodule
