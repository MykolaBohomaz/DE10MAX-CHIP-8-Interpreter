`default_nettype none
module vga_timing (
    input wire        clk,
    input wire        rst,
    output reg        [9:0] hcount,
    output reg        [9:0] vcount,
    output wire        hsync,
    output wire        vsync,
    output wire        active,
    output wire        tick60
);

reg pix_en;
//25MHz tick 
always@(posedge clk) begin 
  if(rst)
    pix_en <= 1'b1;
  else
    pix_en <=~pix_en;
end 

always@(posedge clk) begin
  if(!rst) begin
    if(pix_en == 1) begin 
      //increase hcount
      if(hcount < 799) begin
        hcount <= hcount + 1;
      end
      //increase vcount only when hcount resets
      else begin
        hcount <= 0;
        if(vcount < 524) vcount <= vcount + 1;
        //reset vcount
        else vcount <= 0;
      end

    end

  end

  else begin 
    hcount <= 0;
    vcount <= 0;
  end

end

//active low sync
assign hsync = !(hcount > 655 && hcount < 752);
assign vsync = !(vcount > 489 && vcount < 492);

assign active = hcount < 640 && vcount < 480;
assign tick60 = vcount == 480 && hcount == 0 && pix_en == 1;

endmodule

`default_nettype wire
