`default_nettype none

module sprite_engine (
    input  wire        clk,
    input  wire        rst_n,          

    // from the CPU
    input  wire        start_draw,     
    input  wire        start_clear,   
    input  wire [7:0]  x,              
    input  wire [7:0]  y,              
    input  wire [3:0]  n,              
    input  wire [11:0] sprite_addr,    

    output wire        busy,           
    output reg         collision,      

    // program RAM
    output reg  [11:0] ram_addr,
    input  wire [7:0]  ram_rdata,      

    // framebuffer port A
    output reg  [10:0] fb_addr,        
    output reg         fb_we,
    output reg         fb_wdata,
    input  wire        fb_rdata        
);

    localparam IDLE      = 3'd0;
    localparam ROW_ADDR  = 3'd1;       
    localparam ROW_LATCH = 3'd2;       
    localparam PIX       = 3'd3;      
    localparam RMW       = 3'd4;     
    localparam CLEAR     = 3'd5;      

    reg [2:0]  state;

    reg [5:0]  x0;                     
    reg [4:0]  y0;                    
    reg [3:0]  n_reg;
    reg [11:0] addr_reg;
    reg [3:0]  row;                   
    reg [2:0]  bitn;                  
    reg [7:0]  sprite;                
    reg [10:0] clr_cnt;               

    wire [6:0] px = x0 + bitn;
    wire [5:0] py = y0 + row;
    wire       off_right  = px[6];
    wire       off_bottom = py[5];

    wire       sprite_bit = sprite[3'd7 - bitn];   

    assign busy = (state != IDLE);

    always @(*) begin
        ram_addr = addr_reg + row;
        fb_addr  = {py[4:0], px[5:0]};
        fb_we    = 1'b0;
        fb_wdata = 1'b0;

        case (state)
            RMW: begin
                fb_we    = 1'b1;
                fb_wdata = ~fb_rdata;     
            end
            CLEAR: begin
                fb_addr  = clr_cnt;
                fb_we    = 1'b1;
                fb_wdata = 1'b0;
            end
            default: ;
        endcase
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            state     <= IDLE;
            collision <= 1'b0;
            x0        <= 6'd0;
            y0        <= 5'd0;
            n_reg     <= 4'd0;
            addr_reg  <= 12'd0;
            row       <= 4'd0;
            bitn      <= 3'd0;
            sprite    <= 8'd0;
            clr_cnt   <= 11'd0;
        end else begin
            case (state)
                IDLE: begin
                    if (start_draw) begin
                        x0        <= x[5:0];       // wrap: mod 64
                        y0        <= y[4:0];       // wrap: mod 32
                        n_reg     <= n;
                        addr_reg  <= sprite_addr;
                        row       <= 4'd0;
                        collision <= 1'b0;
                        state     <= ROW_ADDR;
                    end else if (start_clear) begin
                        clr_cnt   <= 11'd0;
                        state     <= CLEAR;
                    end
                end

                ROW_ADDR: begin
                    if (row == n_reg || off_bottom)
                        state <= IDLE;             
                    else
                        state <= ROW_LATCH;
                end

                ROW_LATCH: begin
                    sprite <= ram_rdata;
                    bitn   <= 3'd0;
                    state  <= PIX;
                end

                PIX: begin
                    if (sprite_bit && !off_right)
                        state <= RMW;              
                    else if (bitn == 3'd7) begin   
                        row   <= row + 4'd1;
                        state <= ROW_ADDR;
                    end else begin
                        bitn  <= bitn + 3'd1;
                        state <= PIX;
                    end
                end

                RMW: begin
                    if (fb_rdata)
                        collision <= 1'b1;        
                    if (bitn == 3'd7) begin       
                        row   <= row + 4'd1;
                        state <= ROW_ADDR;
                    end else begin
                        bitn  <= bitn + 3'd1;
                        state <= PIX;
                    end
                end

                CLEAR: begin
                    if (clr_cnt == 11'd2047)
                        state <= IDLE;
                    else
                        clr_cnt <= clr_cnt + 11'd1;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule

`default_nettype wire
