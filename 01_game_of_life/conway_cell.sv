`default_nettype none

module conway_cell(clk, rst, ena, state_0, state_d, state_q, neighbors);
  input wire clk;
  input wire rst;
  input wire ena;

  input wire state_0;
  output logic state_d;
  output logic state_q;

  input wire [7:0] neighbors;
  logic [3:0] living_neighbors;
  logic [1:0] a1;
  logic [1:0] b1;
  logic [1:0] c1;
  logic [1:0] d1;
  logic [2:0] a2;
  logic [2:0] b2;
  logic [3:0] a3;
  always_comb begin    
    // hierarchial design (binary tree minimum number of adders)
    // can never overflow because most significant bit is the AND of previous location bit
    // (4x) 1-bit input, 2-bit output
    a1[1] = neighbors[0] & neighbors[1];
    a1[0] = neighbors[0] ^ neighbors[1];
    
    b1[1] = neighbors[2] & neighbors[3];
    b1[0] = neighbors[2] ^ neighbors[3];
    
    c1[1] = neighbors[4] & neighbors[5];
    c1[0] = neighbors[4] ^ neighbors[5];

    d1[1] = neighbors[6] & neighbors[7];
    d1[0] = neighbors[6] ^ neighbors[7];
    
    // (2x) 2-bit input, 3-bit output
    a2[2] = a1[1] & b1[1];
    a2[1] = (a1[0] & b1[0]) | (a1[1]) ^ (b1[1]);
    a2[0] = a1[0] ^ b1[0];

    b2[2] = c1[1] & d1[1];
    b2[1] = (c1[0] & d1[0]) | (c1[1]) ^ (d1[1]);
    b2[0] = c1[0] ^ d1[0];
    
    // (1x) 3-bit input, 4-bit output
    a3[3] = a2[2] & b2[2];
    a3[2] = (a2[1] & b2[1]) | (a2[2]) ^ (b2[2]); 
    a3[1] = (a2[0] & b2[0]) | (a2[1]) ^ (b2[1]);
    a3[0] = a2[0] ^ b2[0];
    
    // $display("%b, %b", state_0, a3);

    state_d = (state_0 & ~a3[3] & ~a3[2] & a3[1] & ~a3[0]) | (~a3[3] & ~a3[2] & a3[1] & a3[0]);
    state_q = ~state_d;
  end

endmodule