`default_nettype none

module rom_bank (
    input wire        clk,
    input wire        [14:0] addr,
    output reg        [7:0] data_out 

);

reg [7:0] bank [0:32767];

    initial $readmemh("mem/rom_bank.hex", bank);

    always @(posedge clk) begin
            data_out <= bank[addr];
    end

endmodule

`default_nettype wire
