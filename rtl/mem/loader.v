`default_nettype none

module loader (
  input wire    clk,
  input wire    rst,
  input wire    [2:0] bank_sel,
  output wire    [14:0] rom_addr,
  input wire    [7:0] rom_rdata,
  output wire    [11:0] ram_addr,
  output wire   ram_we,
  output wire    [7:0] ram_wdata,
  output wire    [10:0] fb_addr,
  output wire   fb_we,
  output wire   fb_wdata,
  output reg   loading
);

reg [12:0] cnt;
reg [2:0] bank;
wire [13:0] cnt_minus = cnt - 1;

always@(posedge clk) begin 
  if(rst) begin cnt <= 0;
    loading <= 1'b1;
    bank <= bank_sel;
  end

  else if(loading) begin
    if(cnt == 4096) begin
      loading <= 0;
    end
    else begin 
      cnt <= cnt + 1;
    end
  end

  else begin
  end

end

assign rom_addr = {bank, cnt[11:0]};
assign ram_we = (loading && cnt) != 0;
assign ram_addr = cnt_minus[11:0];
assign ram_wdata = rom_rdata;
assign fb_we = loading && (cnt < 2048);
assign fb_addr = cnt[10:0];
assign fb_wdata = 0;

endmodule

`default_nettype wire
