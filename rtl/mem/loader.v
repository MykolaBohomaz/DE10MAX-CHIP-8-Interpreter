`default_nettype none

module loader (
  input wire    clk,
  input wire    rst,
  input wire    [2:0] bank_sel,
  output reg    [14:0] rom_addr,
  input wire    [7:0] rom_rdata,
  output reg    [11:0] ram_addr,
  output wire   ram_we,
  output reg    [7:0] ram_wdata,
  output reg    [10:0] fb_addr,
  output wire   fb_we,
  output wire   fb_wdata,
  output wire   loading
);

wire [11:0] cnt;


endmodule

`default_nettype wire
