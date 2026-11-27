`timescale 1ns / 1ps

module control_unit_tb;

    parameter CLK_PERIOD = 10;

    localparam IDLE    = 4'b0000;
    localparam FETCH1  = 4'b0001;
    localparam FETCH2  = 4'b0010;
    localparam FETCH3  = 4'b0011;
    localparam EXECUTE = 4'b0100;

    reg clk;
    reg rst_n;
    reg cpu_en;

    wire [3:0] state;
    wire mem_addr_sel;
    wire ir_hi_ld;
    wire ir_lo_ld;
    wire pc_incr;

    control_unit dut (
        .clk(clk),
        .rst_n(rst_n),
        .cpu_en(cpu_en),
        .state(state),
        .mem_addr_sel(mem_addr_sel),
        .ir_hi_ld(ir_hi_ld),
        .ir_lo_ld(ir_lo_ld),
        .pc_incr(pc_incr)
    );

    integer errors = 0;
    integer checks = 0;

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // waveform dump
    initial begin
        $dumpfile("control_unit_tb.vcd");
        $dumpvars(0, control_unit_tb);
        $timeformat(-9, 0, " ns", 0);
    end

    // helper functions

    task step;
        begin
            @(negedge clk);
        end
    endtask

    function [8*7:1] name;                      // turn a state code into a readable name for messages.
        input [3:0] s;
        begin
            case (s)
                IDLE:    name = "IDLE";
                FETCH1:  name = "FETCH1";
                FETCH2:  name = "FETCH2";
                FETCH3:  name = "FETCH3";
                EXECUTE: name = "EXECUTE";
                default: name = "???";
            endcase
        end
    endfunction

    task check;                                 // compare the state and all four control signals with expected values.
        input [3:0] exp_state;
        input       exp_sel;
        input       exp_hi;
        input       exp_lo;
        input       exp_pc;
        begin
            checks = checks + 1;
            if (state        !== exp_state ||
                mem_addr_sel !== exp_sel   ||
                ir_hi_ld     !== exp_hi    ||
                ir_lo_ld     !== exp_lo    ||
                pc_incr      !== exp_pc) begin
                errors = errors + 1;
                $display("  FAIL @ %0t: expected %-7s sel=%b hi=%b lo=%b pc=%b",
                         $time, name(exp_state), exp_sel, exp_hi, exp_lo, exp_pc);
                $display("                       got %-7s sel=%b hi=%b lo=%b pc=%b",
                         name(state), mem_addr_sel, ir_hi_ld, ir_lo_ld, pc_incr);
            end
        end
    endtask

    // Pulse cpu_en for exactly one clock, then check a whole fetch.
    task run_one_instruction;
        begin
            cpu_en = 1;
            step;  cpu_en = 0;
            check(FETCH1,  0, 0, 0, 0);
            step;  check(FETCH2,  1, 1, 0, 0);
            step;  check(FETCH3,  0, 0, 1, 1);
            step;  check(EXECUTE, 0, 0, 0, 0);
            step;  check(IDLE,    0, 0, 0, 0);
        end
    endtask

    // test sequence
    initial begin
        rst_n  = 0;
        cpu_en = 0;

        // test 1: reset puts the FSM in IDLE with all outputs off
        $display("Test 1: reset");
        step; step;
        check(IDLE, 0, 0, 0, 0);
        rst_n = 1;

        // test 2: with cpu_en low, the FSM stays in IDLE
        $display("Test 2: stay in IDLE while cpu_en = 0");
        step; check(IDLE, 0, 0, 0, 0);
        step; check(IDLE, 0, 0, 0, 0);
        step; check(IDLE, 0, 0, 0, 0);

        // test 3: one cpu_en pulse runs exactly one fetch
        $display("Test 3: one instruction");
        run_one_instruction;

        // test 4: afterwards it stays in IDLE
        $display("Test 4: stay in IDLE after EXECUTE");
        step; check(IDLE, 0, 0, 0, 0);
        step; check(IDLE, 0, 0, 0, 0);

        // test 5: a second pulse repeats the same sequence
        $display("Test 5: second instruction");
        run_one_instruction;

        // test 6: cpu_en arriving in the middle of a fetch is ignored
        $display("Test 6: cpu_en during FETCH2 is ignored");
        cpu_en = 1;
        step;  cpu_en = 0;           check(FETCH1,  0, 0, 0, 0);
        step;  cpu_en = 1;           check(FETCH2,  1, 1, 0, 0);
        step;  cpu_en = 0;           check(FETCH3,  0, 0, 1, 1);
        step;                        check(EXECUTE, 0, 0, 0, 0);
        step;                        check(IDLE,    0, 0, 0, 0);
        step;                        check(IDLE,    0, 0, 0, 0);

        // test 7: reset in the middle of a fetch returns to IDLE at once
        $display("Test 7: reset during FETCH2");
        cpu_en = 1;
        step;  cpu_en = 0;           check(FETCH1,  0, 0, 0, 0);
        step;                        check(FETCH2,  1, 1, 0, 0);
        rst_n = 0;
        step;                        check(IDLE,    0, 0, 0, 0);
        rst_n = 1;
        step;                        check(IDLE,    0, 0, 0, 0);

        // test 8: and it still works normally after that reset
        $display("Test 8: instruction after mid-fetch reset");
        run_one_instruction;

        $display("");
        if (errors == 0)
            $display("PASS: all %0d checks passed", checks);
        else
            $display("FAIL: %0d of %0d checks failed", errors, checks);
        $finish;
    end



endmodule