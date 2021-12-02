`default_nettype none
`timescale 1ns/1ps

module test_distributed_ram;

parameter L = 64;
parameter W = 32;

logic clk;

// Write channel
logic wr_ena;
logic [$clog2(L)-1:0] addr;
logic [W-1:0] wr_data;
wire [W-1:0] rd_data;

distributed_ram #(.W(W), .L(L), .INIT("asm/itypes.memh")) UUT(
  .clk(clk), .wr_ena(wr_ena), .addr(addr), .wr_data(wr_data), .rd_data(rd_data)
);



initial begin
  clk = 0;
  wr_ena = 0;
  addr = 0;
  
  $dumpfile("distributed_ram.fst");
  $dumpvars(0, UUT);

  for(int i = 0; i < 32; i = i + 1) begin
    @(negedge clk);
    wr_ena = 0;
    addr = i[$clog2(L)-1:0];
    @(posedge clk);
    $display("RAM[%d] = 0x %h", addr, rd_data);
  end

  $finish;

end

always #5 clk = ~clk; // clock generator

endmodule