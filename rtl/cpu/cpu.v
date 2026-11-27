module cpu(
    input wire clk,
    input wire rst_n,
    input wire cpu_en,
    input wire [7:0] mem_rdata,                 // the byte coming back from memory to be loaded into the IR

    output wire [11:0] mem_addr,
    output reg  [11:0] pc,
    output reg  [15:0] ir,
    output wire [3:0]  state                     // for debugging purposes only
);

    wire mem_addr_sel;
    wire ir_hi_ld;
    wire ir_lo_ld;
    wire pc_sel;

    control_unit cu (
        .clk(clk),
        .rst_n(rst_n),
        .cpu_en(cpu_en),
        .state(state),
        .mem_addr_sel(mem_addr_sel),
        .ir_hi_ld(ir_hi_ld),
        .ir_lo_ld(ir_lo_ld),
        .pc_sel(pc_sel)
    );

    assign mem_addr = (mem_addr_sel) ? pc + 12'd1 : pc;

    always @(posedge clk) begin
        if (!rst_n) begin
            pc <= 12'h200;                       // start of program memory NOT 0!
            ir <= 16'h0000;
        end else begin
            if (pc_sel) begin
                pc <= pc + 12'd2;
            end
            if (ir_hi_ld) begin
                ir[15:8] <= mem_rdata;
            end
            if (ir_lo_ld) begin
                ir[7:0] <= mem_rdata;
            end
        end
    end

endmodule