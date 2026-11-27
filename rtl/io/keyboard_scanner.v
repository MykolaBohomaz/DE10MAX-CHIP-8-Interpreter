`default_nettype none

module keyboard_scanner (
input wire        clk,
input wire        rst,
input wire        [15:0] btn_n,
output reg        [15:0] keys
);

wire sample_pulse;
reg [17:0] sample_cnt;

//temp regs
reg [15:0] temp1;
reg [15:0] temp2;

always@(posedge clk) begin
  if(!rst) begin
      if(sample_cnt < 249999) begin
        sample_cnt <= sample_cnt + 1;
      end
      else begin
        sample_cnt <= 0;
      end

  end
  else begin 
    sample_cnt <= 0;
  end

end

  assign sample_pulse = !sample_cnt;

always@(posedge clk)begin
    temp1 <= btn_n;
    temp2 <= temp1;
end

always@(posedge clk)begin
  if(rst) begin
      keys <= 16'b0;
  end
  else begin
    if(sample_pulse) begin 
      keys <= ~temp2;
    end
  end
end

endmodule

`default_nettype wire
