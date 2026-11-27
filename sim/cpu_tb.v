`timescale 1ns / 1ps

// this tb currently only test the fetch part of the cpu

module cpu_tb;

    parameter CLK_PERIOD = 10;
    parameter N_INSTR    = 15;      // instructions in the 0123 program

    localparam EXECUTE = 4'b0100;   // same code as in control_unit.v

    // signals
    reg         clk;
    reg         rst_n;
    reg         cpu_en;

    wire [11:0] mem_addr;
    wire [7:0]  mem_rdata;
    wire [11:0] pc;
    wire [15:0] ir;
    wire [3:0]  state;

    integer errors = 0;
    integer checks = 0;
    integer k;
    integer wait_clocks;

    // expected values, typed by hand from mem/rom.hex
    reg [15:0] exp_ir [0:N_INSTR-1];
    reg [11:0] exp_pc [0:N_INSTR-1];

    // dut and mem
    cpu dut (
        .clk(clk),
        .rst_n(rst_n),
        .cpu_en(cpu_en),
        .mem_rdata(mem_rdata),
        .mem_addr(mem_addr),
        .pc(pc),
        .ir(ir),
        .state(state)
    );

    chip8_mem mem (
        .clk(clk),
        .addr(mem_addr),
        .write_en(1'b0),              // no writes yet
        .data_in(8'h00),
        .data_out(mem_rdata)
    );

    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // waveform dump
    initial begin
        $dumpfile("cpu_tb.vcd");
        $dumpvars(0, cpu_tb);
        $timeformat(-9, 0, " ns", 0);
    end

    // expected values
    // After each fetch, IR holds the instruction and PC is already +2.
    initial begin
        exp_ir[0]  = 16'h00E0;  exp_pc[0]  = 12'h202;  // clear screen
        exp_ir[1]  = 16'h600A;  exp_pc[1]  = 12'h204;  // V0 = 10
        exp_ir[2]  = 16'h610C;  exp_pc[2]  = 12'h206;  // V1 = 12
        exp_ir[3]  = 16'hA050;  exp_pc[3]  = 12'h208;  // I = font "0"
        exp_ir[4]  = 16'hD015;  exp_pc[4]  = 12'h20A;  // draw
        exp_ir[5]  = 16'h7005;  exp_pc[5]  = 12'h20C;  // V0 += 5
        exp_ir[6]  = 16'hA055;  exp_pc[6]  = 12'h20E;  // I = font "1"
        exp_ir[7]  = 16'hD015;  exp_pc[7]  = 12'h210;  // draw
        exp_ir[8]  = 16'h7005;  exp_pc[8]  = 12'h212;  // V0 += 5
        exp_ir[9]  = 16'hA05A;  exp_pc[9]  = 12'h214;  // I = font "2"
        exp_ir[10] = 16'hD015;  exp_pc[10] = 12'h216;  // draw
        exp_ir[11] = 16'h7005;  exp_pc[11] = 12'h218;  // V0 += 5
        exp_ir[12] = 16'hA05F;  exp_pc[12] = 12'h21A;  // I = font "3"
        exp_ir[13] = 16'hD015;  exp_pc[13] = 12'h21C;  // draw
        exp_ir[14] = 16'h121C;  exp_pc[14] = 12'h21E;  // jump to self
    end

    // helper functions
    task step;                       // wait one clock return after the falling edge
        begin
            @(negedge clk);
        end
    endtask

    task check_value;                // compare one 16 bit value count errors
        input [8*12:1] what;
        input [15:0]   got;
        input [15:0]   expected;
        begin
            checks = checks + 1;
            if (got !== expected) begin
                errors = errors + 1;
                $display("  FAIL @ %0t: %0s expected %h, got %h", $time, what, expected, got);
            end
        end
    endtask

    // test
    initial begin
        rst_n  = 0;
        cpu_en = 0;

        // Test 1: reset values
        $display("Test 1: reset");
        step; step;
        rst_n = 1;
        step;
        check_value("PC", {4'h0, pc}, 16'h0200);
        check_value("IR", ir, 16'h0000);

        // Test 2: fetch the whole program, one instruction per cpu_en pulse
        $display("Test 2: fetch %0d instructions", N_INSTR);
        for (k = 0; k < N_INSTR; k = k + 1) begin
            // one-clock cpu_en pulse
            cpu_en = 1;
            step;
            cpu_en = 0;

            // wait until the FSM reaches EXECUTE (with a timeout)
            wait_clocks = 0;
            while (state !== EXECUTE && wait_clocks < 20) begin
                step;
                wait_clocks = wait_clocks + 1;
            end

            if (state !== EXECUTE) begin
                errors = errors + 1;
                $display("  FAIL @ %0t: instruction %0d never reached EXECUTE (state = %b)",
                         $time, k + 1, state);
            end else begin
                $display("  #%0d  PC=%h  IR=%h", k + 1, pc, ir);
                check_value("IR", ir, exp_ir[k]);
                check_value("PC", {4'h0, pc}, {4'h0, exp_pc[k]});
            end

            step; step;              // back to IDLE before the next pulse
        end

        $display("");
        if (errors == 0)
            $display("PASS: all %0d checks passed", checks);
        else
            $display("FAIL: %0d of %0d checks failed", errors, checks);
        $finish;
    end

endmodule