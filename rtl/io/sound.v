`default_nettype none

module sound (
input wire        clk,
input wire        rst,
input wire        sound_on,
output wire       tone
);

reg square;
reg [15:0] tone_cont;


always@(posedge clk) begin
  if(!rst) begin
      if(tone_cont < 56817) begin
        tone_cont <= tone_cont + 1;
      end
      else begin
        square <= ~square;
        tone_cont <= 0;
      end

  end
  else begin 
    square <= 0;
    tone_cont <= 0;
  end

end

  assign tone = square && sound_on;


endmodule

`default_nettype wire
