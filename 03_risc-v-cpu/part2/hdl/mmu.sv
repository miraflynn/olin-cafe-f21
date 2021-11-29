`timescale 1ns/1ps
`default_nettype none
module mmu(
  clk, rst, 
  rd_addr, rd_data, wr_ena, wr_addr, wr_data
);

input wire  clk, rst;
input wire wr_ena;
input wire [31:0] rd_addr, wr_addr, wr_data;
output logic [31:0] rd_data;




endmodule