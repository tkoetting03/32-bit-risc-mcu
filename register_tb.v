`timescale 1ns/1ps

module register_tv (
    input reg clock;
    input reg write_enable;
    input reg[31:0] data_in;
    input reg[31:0] instruction;
    output wire[31:0] data_out1;
    output wire[31:0] data_out2;

    register uut (
        .clock(clock),
        .write_enable(write_enable),
        .data_in(data_in),
        .instruction(instruction),
        .data_1(data_out1),
        .data_2(data_out2)
    )
);
    
endmodule