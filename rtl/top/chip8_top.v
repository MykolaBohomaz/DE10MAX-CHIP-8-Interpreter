module chip8_top (
    input  wire       MAX10_CLK1_50,   // 50 MHz board clock
    input  wire [1:0] KEY,             // push buttons, active low
    output wire [3:0] VGA_R, VGA_G, VGA_B,
    output wire       VGA_HS, VGA_VS
);
    wire rst = ~KEY[0];
    // instantiate vga_timing, fb_mem, display_logic here
    // and wire them together (display_logic's vga_* -> the VGA_* ports)
endmodule