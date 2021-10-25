`timescale 1ns/1ps
`default_nettype none
module test_mux;


int errors = 0;
logic [31:0] correct = 0;

logic [31:0] d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23, d24, d25, d26, d27, d28, d29, d30, d31;
logic [4:0] s;
wire [31:0] y;

mux32 UUT(
    .d0(d0),
    .d1(d1),
    .d2(d2),
    .d3(d3),
    .d4(d4),
    .d5(d5),
    .d6(d6),
    .d7(d7),
    .d8(d8),
    .d9(d9),
    .d10(d10),
    .d11(d11),
    .d12(d12),
    .d13(d13),
    .d14(d14),
    .d15(d15),
    .d16(d16),
    .d17(d17),
    .d18(d18),
    .d19(d19),
    .d20(d20),
    .d21(d21),
    .d22(d22),
    .d23(d23),
    .d24(d24),
    .d25(d25),
    .d26(d26),
    .d27(d27),
    .d28(d28),
    .d29(d29),
    .d30(d30),
    .d31(d31),
    .s(s),
    .y(y));

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
// logic [N+1:0] sum_and_carry;
// logic correct_carry_out;
// logic [N-1:0] correct_sum;

// always_comb begin : behavioural_solution_logic
//   sum_and_carry = a + b + c_in;
//   correct_sum = sum_and_carry[N-1:0];
//   correct_carry_out = |sum_and_carry[N+1:N];
// end

// You can make "tasks" in testbenches. Think of them like methods of a class, 
// they have access to the member variables.
task print_io;
    $display("*****************************************************************************");
    $display("s: %d, y: %d", s, y);
    $display("ds: %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d", d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23, d24, d25, d26, d27, d28, d29, d30, d31);
endtask


// 2) the test cases
initial begin
  //$dumpfile("adder_n.vcd");
  //$dumpvars(0, UUT);
  
//   $display("Specific interesting tests.");
  
//   // Zero + zero 
//   c_in = 0;
//   a = 0;
//   b = 0;
//   #1 print_io();

//   // Two + Two
//   c_in = 0;
//   a = 2;
//   b = 2;
//   #1 print_io();

//   // -1 + -1
//   c_in = 0;
//   a = -1;
//   b = 1;
//   #1 print_io();

//   // Overflow case with carry in.
//   c_in = 1;
//   a = (1 << (N-1)) -1;
//   b = (1 << (N-1));
//   #1 print_io();
  
  $display("Random testing.");
  for (int i = 0; i < 32; i = i + 1) begin : random_testing
    d0 = $random();
    d1 = $random();
    d2 = $random();
    d3 = $random();
    d4 = $random();
    d5 = $random();
    d6 = $random();
    d7 = $random();
    d8 = $random();
    d9 = $random();
    d10 = $random();
    d11 = $random();
    d12 = $random();
    d13 = $random();
    d14 = $random();
    d15 = $random();
    d16 = $random();
    d17 = $random();
    d18 = $random();
    d19 = $random();
    d20 = $random();
    d21 = $random();
    d22 = $random();
    d23 = $random();
    d24 = $random();
    d25 = $random();
    d26 = $random();
    d27 = $random();
    d28 = $random();
    d29 = $random();
    d30 = $random(); 
    d31 = $random();
    // d0 = 0;
    // d1 = 1;
    // d2 = 2;
    // d3 = 3;
    // d4 = 4;
    // d5 = 5;
    // d6 = 6;
    // d7 = 7;
    // d8 = 8;
    // d9 = 9;
    // d10 = 10;
    // d11 = 11;
    // d12 = 12;
    // d13 = 13;
    // d14 = 14;
    // d15 = 15;
    // d16 = 16;
    // d17 = 17;
    // d18 = 18;
    // d19 = 19;
    // d20 = 20;
    // d21 = 21;
    // d22 = 22;
    // d23 = 23;
    // d24 = 24;
    // d25 = 25;
    // d26 = 26;
    // d27 = 27;
    // d28 = 28;
    // d29 = 29;
    // d30 = 30; 
    // d31 = 31;
    s = i;
    #1 print_io();
  end
//   if (errors !== 0) begin
//     $display("---------------------------------------------------------------");
//     $display("-- FAILURE                                                   --");
//     $display("---------------------------------------------------------------");
//     $display(" %d failures found, try again!", errors);
//   end else begin
//     $display("---------------------------------------------------------------");
//     $display("-- SUCCESS                                                   --");
//     $display("---------------------------------------------------------------");
//   end
  $finish;
end

// Note: the triple === (corresponding !==) check 4-state (e.g. 0,1,x,z) values.
//       It's best practice to use these for checkers!
always @(d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23, d24, d25, d26, d27, d28, d29, d30, d31, s, y) begin
  correct = (s==0 ? d0 :
  (s==1 ? d1 :
  (s==2 ? d2 :
  (s==3 ? d3 :
  (s==4 ? d4 :
  (s==5 ? d5 :
  (s==6 ? d6 :
  (s==7 ? d7 :
  (s==8 ? d8 :
  (s==9 ? d9 :
  (s==10 ? d10 :
  (s==11 ? d11 :
  (s==12 ? d12 :
  (s==13 ? d13 :
  (s==14 ? d14 :
  (s==15 ? d15 :
  (s==16 ? d16 :
  (s==17 ? d17 :
  (s==18 ? d18 :
  (s==19 ? d19 :
  (s==20 ? d20 :
  (s==21 ? d21 :
  (s==22 ? d22 :
  (s==23 ? d23 :
  (s==24 ? d24 :
  (s==25 ? d25 :
  (s==26 ? d26 :
  (s==27 ? d27 :
  (s==28 ? d28 :
  (s==29 ? d29 :
  (s==30 ? d30 : 
  (s==31 ? d31 : 100000000))))))))))))))))))))))))))))))));

//   assert(y === correct) else begin
//     errors = errors + 1;
//     $display("  ERROR: y should be %d, is %d with s %d, d0 %d", correct, y, s, d0);
    
//     // $display("s: %d \n", s);
//     // errors = errors + 1;
//   end
//   assert(c_out === correct_carry_out) else begin
//     $display("  ERROR: sum should be %d", correct_sum);
//     errors = errors + 1;
//   end
end

endmodule
