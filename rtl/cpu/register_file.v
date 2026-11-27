module register_file(
    input wire clk,
    input wire rst_n,
    input wire write_en,
    input wire vfwrite_en,
    input wire [3:0] waddr,
    input wire [3:0] raddr_a,
    input wire [3:0] raddr_b,
    input wire [7:0] wdata,
    input wire [7:0] vf_wdata,

    output reg [7:0] rdata_a,
    output reg [7:0] rdata_b,
    output reg [7:0] v0
);

    begin

        // assign ...

        // always @(posedge clk) begin
        // end

    end

endmodule