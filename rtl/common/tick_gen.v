
`default_nettype none

module tick_gen (
  input wire  clk,
  input wire  rst,
  output wire  tick
);

reg [16:0] tick_cnt;
//when testing change the limit here, so clock is faster
parameter LIM = 71428;


always@(posedge clk) begin
  if(!rst) begin
      if(tick_cnt < LIM) begin
        tick_cnt <= tick_cnt + 1;
      end
      else begin
        tick_cnt <= 0;
      end

  end
  else begin 
    tick_cnt <= 0;
  end

end

  assign tick = !tick_cnt;

endmodule

`default_nettype wire
