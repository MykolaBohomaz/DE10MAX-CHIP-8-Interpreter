`timescale 1ns/1ps
`default_nettype none

module fb_mem (
    input wire        clk,
    input wire        [10:0] a_addr,
    input wire        a_we,
    input wire        a_wdata,
    output reg       a_rdata,
    input wire        [10:0] b_addr, 
    output reg       b_rdata 

);

    reg buffer [0:2047]; 

    always @(posedge clk) begin
        if (a_we)
            buffer[a_addr] <= a_wdata;
        else
            a_rdata <= buffer[a_addr];
    end

    always @(posedge clk) begin
        b_rdata <= buffer[b_addr];
    end

endmodule

`default_nettype wire
