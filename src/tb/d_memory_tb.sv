`timescale 1ns/1ps

module d_memory_tb (
    logic clock;
    logic memory_write;
    logic memory_read;
    logic [31:0] address;
    logic [31:0] data_write;
    logic [31:0] data_read;
);

d_memory uut (
    .clock(clock),
    .memory_write(memory_write),
    .memory_read(memory_read),
    .address(address),
    .data_write(data_write),
    .data_read(data_read)
);

always #5 clcok = ~clock;



endmodule
