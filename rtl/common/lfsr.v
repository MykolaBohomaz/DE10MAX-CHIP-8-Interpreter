`default_nettype none

module lfsr (
  input wire  clk,
  input wire  rst,
  output wire  [7:0] rnd 
);

reg [15:0]lfsr;

always@(posedge clk) begin
  if(!rst) begin
    lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
  end
  else begin 
    lfsr <= 16'hACE1;
  end

end

assign rnd = lfsr[7:0];


endmodule

`default_nettype wire
