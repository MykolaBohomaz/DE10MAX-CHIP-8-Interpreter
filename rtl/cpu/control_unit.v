module control_unit(
    input wire clk,
    input wire rst_n,
    input wire cpu_en,

    output reg [3:0] state,
    output reg mem_addr_sel,
    output reg ir_hi_ld,
    output reg ir_lo_ld,
    output reg pc_sel
);

    localparam IDLE =    4'b0000;
    localparam FETCH1 =  4'b0001;
    localparam FETCH2 =  4'b0010;
    localparam FETCH3 =  4'b0011;
    localparam EXECUTE = 4'b0100;

    always @(*) begin
        mem_addr_sel = 1'b0;
        ir_hi_ld =     1'b0;
        ir_lo_ld =     1'b0;
        pc_sel =      1'b0;

        case (state)
            IDLE: ;                          // no control signals asserted, default values are already set
            FETCH1: ;                        // no control signals asserted, default values are already set           end
            FETCH2: begin
                mem_addr_sel = 1'b1;
                ir_hi_ld =     1'b1;
            end
            FETCH3: begin
                ir_lo_ld =     1'b1;
                pc_sel =      1'b1;
            end
            EXECUTE: ;                      // no control signals asserted, default values are already set
        endcase
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    if (cpu_en) begin
                        state <= FETCH1;
                    end else begin
                        state <= IDLE;
                    end
                end
                FETCH1: begin
                    state <= FETCH2;
                end
                FETCH2: begin
                    state <= FETCH3;
                end
                FETCH3: begin
                    state <= EXECUTE;
                end
                EXECUTE: begin
                    state <= IDLE;
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
