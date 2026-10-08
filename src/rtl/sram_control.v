module sram_controller(

    input wire clk,
    input wire reset,
    input wire memory_req,
    input wire[17:0] memory_addr,
    input wire[31:0] data_in,

    output reg[31:0] data_out,
    output reg[17:0] sram_addr,
    output reg finished,
    output reg select,
    output reg output_enable,
    output reg write_enable,

    inout wire[17:0] sram_dp

);

endmodule