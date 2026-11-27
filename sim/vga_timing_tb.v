`timescale 1ns / 1ps

module vga_timing_tb

//clock
reg clk = 1'b1;
always #10 clk = ~clk;

//in and outs for DUT
    input wire        rst,
    output reg        [9:0] hcount,
    output reg        [9:0] vcount,
    output wire        hsync,
    output wire        vsync,
    output wire        active,
    output wire        tick60

//DUT
  vga_timing(
    .clk(clk),
    .rst(rst),
    .hcount(hcount),
    .vcount(vcount),
    .hsync(hsync),
    .active(vsync),
    .tick60(tick60)
  )
//display tests
    integer errors = 0;

    task check;
        input integer   test_no;
        input [8*12:1]  port_name;
        input [10:0]    addr;
        input           actual;
        input           expected;
        begin
            if (actual !== expected) begin
                $display("FAIL  test %0d  %0s  addr %0d  got %b  expected %b  (t=%0t)",
                         test_no, port_name, addr, actual, expected, $time);
                errors = errors + 1;
            end else begin
                $display("pass  test %0d  %0s  addr %0d  = %b",
                         test_no, port_name, addr, actual);
            end
        end
    endtask


//TODO  finish the testbench 


endmodule
