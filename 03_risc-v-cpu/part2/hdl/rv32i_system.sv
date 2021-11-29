`timescale 1ns/1ps
`default_nettype none

module rv32i_system(
  clk, rst, ena
);

parameter RAM_L = 65536; //64k RAM, enough for a video buffer and change.
`ifndef INITIAL_MEMORY
initial begin 
  $display("ERROR! Initial memory was not set, don't expect the simulation to work!");
  $finish;
end
`endif

input wire clk, rst, ena;
// inout wire [39:0] pio; // TODO(avinash)

wire core_mem_wr_ena;
wire [31:0] core_mem_addr, core_mem_wr_data, core_mem_rd_data;

rv32i_multicycle_core CORE (
  .clk(clk), .rst(rst), .ena(ena),
  .mem_addr(core_mem_addr), .mem_rd_data(core_mem_rd_data),
  .mem_wr_ena(core_mem_wr_ena), .mem_wr_data(core_mem_wr_data),
  .PC()
);

// Memory Management Unit
// Note - will eventually be its own module.
logic [$clog2(RAM_L)-1:0] mem_addr0, mem_addr1;
always_comb begin : mmu_address_mapping
  mem_addr0 = core_mem_addr[$clog2(RAM_L)-1:0];
end

distributed_ram #(.W(32), .L(RAM_L), .INIT(`INITIAL_MEMORY)) 
RAM(
  .clk(clk),
  .wr_ena(core_mem_wr_ena), .addr(mem_addr0),
  .wr_data(core_mem_wr_data), .rd_data(core_mem_rd_data)
);

endmodule
