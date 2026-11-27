`default_nettype none
module display_logic (
    input wire        [9:0] hcount,
    input wire        [9:0] vcount,
    input wire        hsync,
    input wire        vsync,
    input wire        active,
    output wire       [10:0] fb_b_addr, 
    input wire        fb_b_data,
    output wire       [3:0] vga_r,
    output wire       [3:0] vga_b,
    output wire       [3:0] vga_g,
    output wire       vga_hs,
    output wire       vga_vs
);

//check if in the scaled window
wire in_window = hcount > 63 && hcount < 576 && vcount > 111 && vcount < 368;
//find a chip8 pixel
wire [5:0] chip8_pixel_x = (hcount - 64) >> 3;
wire [4:0] chip8_pixel_y = (vcount - 112) >> 3;

assign fb_b_addr = (chip8_pixel_y << 6) | chip8_pixel_x;

//assgin colours
assign vga_r = (in_window && active && fb_b_data) ? 4'hF : 4'h0;
assign vga_b = (in_window && active && fb_b_data) ? 4'hF : 4'h0;
assign vga_g = (in_window && active && fb_b_data) ? 4'hF : 4'h0;

//assign delay
assign vga_hs = hsync;
assign vga_vs = vsync;

endmodule

`default_nettype wire
