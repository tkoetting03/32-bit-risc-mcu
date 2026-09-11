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
    always #5 clock = ~clock;

    function [31:0] instruction_concatenator;
        input [4:0] rs2;
        input [4:0] rs1;
        input [4:0] rd;
        begin
            instruction_concatenator = {7'b0, rs2, rs1, 3'b0, rd, 7'b0};
        end
    endfunction


    task verify_outputs;
        input [31:0] expected_data_out1;
        input [31:0] expected_data_out2;
        input [8*40:1] string;
        begin
            #1;
            if (data_out1 !== expected_data_out1 || data_out2 !== expected_data_out2) begin
                $display("[Mogged :()] | %0s | %0t | data_out1=0x%32b (s/b 0x%32b) | data_out2=0x%32b (s/b 0x%32b)", 
                string, $time, data_out1, expected_data_out1, data_out2, expected_data_out2);
            end else begin
                $display("[Looks Maxxer :)] | %0s | %0t | data_out1=0x%32b | data_out2=0x%32b", 
                string, $time, data_out1, data_out2);
            end
        end
    endtask
    
endmodule