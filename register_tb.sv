`timescale 1ns/1ps

module register_tv (
    logic clock;
    logic write_enable;
    logic[31:0] data_in;
    logic[31:0] instruction;
    logic[31:0] data_out1;
    logic[31:0] data_out2;

    register uut (
        .clock(clock),
        .write_enable(write_enable),
        .data_in(data_in),
        .instruction(instruction),
        .data_1(data_out1),
        .data_2(data_out2)
    )
);
    
    always #5 clock = ~clock;



endmodule