// =============================================================================
// fb_mem_tb.v - self-checking testbench for fb_mem (2048 x 1 bit, dual port)
//
// Run from the repo root:   make sim-fb
// (same as: iverilog -g2005 -Wall -o sim/fb_mem_tb.vvp sim/fb_mem_tb.v rtl/mem/fb_mem.v
//           vvp sim/fb_mem_tb.vvp)
// Wave:  surfer sim/fb_mem_tb.vcd
//
// Timing rule used everywhere in this file:
//   - the testbench CHANGES inputs on the FALLING edge of clk
//   - fb_mem reacts on the RISING edge
//   - the testbench CHECKS outputs on the next FALLING edge
// Driving and checking half a cycle away from the rising edge avoids races
// where the testbench and the design both act "at the same instant".
// =============================================================================
`timescale 1ns/1ps
`default_nettype none

module fb_mem_tb;

    // ---------------------------------------------------------------- clock
    reg clk = 1'b0;
    always #10 clk = ~clk;             

    // ------------------------------------------------- signals to/from DUT
    reg  [10:0] a_addr  = 11'd0;
    reg         a_we    = 1'b0;
    reg         a_wdata = 1'b0;
    wire        a_rdata;
    reg  [10:0] b_addr  = 11'd0;
    wire        b_rdata;

    // ------------------------------------------- device under test (DUT)
    fb_mem dut (
        .clk     (clk),
        .a_addr  (a_addr),
        .a_we    (a_we),
        .a_wdata (a_wdata),
        .a_rdata (a_rdata),
        .b_addr  (b_addr),
        .b_rdata (b_rdata)
    );

    // ------------------------------------------------------------ checking
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

    // ------------------------------------------------------ helper tasks
    // Write one pixel through port a
    task write_a;
        input [10:0] addr;
        input        value;
        begin
            @(negedge clk);
            a_addr  = addr;
            a_wdata = value;
            a_we    = 1'b1;
            @(negedge clk);             
            a_we    = 1'b0;
        end
    endtask

    // Put an address on port b, wait one rising edge, then check b_rdata
    task read_b_and_check;
        input integer test_no;
        input [10:0]  addr;
        input         expected;
        begin
            @(negedge clk);
            b_addr = addr;
            @(negedge clk);             
            check(test_no, "b_rdata", addr, b_rdata, expected);
        end
    endtask

    // ------------------------------------------------------------ the tests
    initial begin
        $dumpfile("sim/fb_mem_tb.vcd");
        $dumpvars(0, fb_mem_tb);

        // Test 1: read before anything was written.
        @(negedge clk);
        b_addr = 11'd5;
        @(negedge clk);
        $display("info  test 1  b_rdata  addr 5 before any write = %b (x expected in sim)",
                 b_rdata);

        // Test 2: write 1 to pixel 5 on port A, read it back on port B.
        write_a(11'd5, 1'b1);
        read_b_and_check(2, 11'd5, 1'b1);

        // Test 3: both ports read pixel 5 in the same cycle.
        @(negedge clk);
        a_addr = 11'd5;                 
        b_addr = 11'd5;
        @(negedge clk);
        check(3, "a_rdata", 11'd5, a_rdata, 1'b1);
        check(3, "b_rdata", 11'd5, b_rdata, 1'b1);

        // Test 4: write 0 back (this is how the sprite engine erases a pixel).
        write_a(11'd5, 1'b0);
        read_b_and_check(4, 11'd5, 1'b0);

        // Test 5: first and last addresses.
        write_a(11'd0,    1'b1);
        write_a(11'd2047, 1'b1);
        read_b_and_check(5, 11'd0,    1'b1);
        read_b_and_check(5, 11'd2047, 1'b1);
        write_a(11'd1, 1'b0);
        read_b_and_check(5, 11'd1, 1'b0);

        // Test 6: port A writes pixel 7 in the SAME cycle port B reads it.
        write_a(11'd7, 1'b0);           
        @(negedge clk);
        a_addr  = 11'd7;
        a_wdata = 1'b1;
        a_we    = 1'b1;
        b_addr  = 11'd7;
        @(negedge clk);                 
        a_we    = 1'b0;
        $display("info  test 6  same-cycle write/read: b_rdata = %b (0 = old value, 1 = new value)",
                 b_rdata);
        @(negedge clk);                 
        check(6, "b_rdata", 11'd7, b_rdata, 1'b1);   

        // Test 7: the two ports are independent.
        write_a(11'd10, 1'b1);
        write_a(11'd20, 1'b0);
        @(negedge clk);
        a_addr = 11'd20;
        b_addr = 11'd10;
        @(negedge clk);
        check(7, "a_rdata", 11'd20, a_rdata, 1'b0);
        check(7, "b_rdata", 11'd10, b_rdata, 1'b1);

        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("%0d TEST(S) FAILED", errors);
        $finish;
    end

endmodule

`default_nettype wire
