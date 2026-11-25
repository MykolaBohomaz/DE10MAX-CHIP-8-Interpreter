module chip8_mem (
    input wire        clk,
    input wire        rst_n,
    input wire [11:0] addr,
    input wire [7:0]  data_in,
    input wire        write_en,
    output reg [7:0]  data_out
);

    reg [7:0] mem [0:4095]; // 4k memory for chip 8

    initial $readmemh("../../mem/rom.hex", mem);

    always @(posedge clk) begin
        if (write_en)
            mem[addr] <= data_in;
        else
            data_out <= mem[addr];
    end
endmodule
