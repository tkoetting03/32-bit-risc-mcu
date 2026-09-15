`timescale 1ns/1ps

module register_tb;
    reg clock;
    reg write_enable;
    reg[31:0] data_in;
    reg[31:0] instruction;
    wire[31:0] data_out1;
    wire[31:0] data_out2;

    register uut (
        .clock(clock),
        .write_enable(write_enable),
        .data_in(data_in),
        .instruction(instruction),
        .data_1(data_out1),
        .data_2(data_out2)
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

    initial begin
        clock = 0;
        write_enable = 0;
        data_in = 32'b0;
        instruction = 32'b0;

        #10;

        instruction = instruction_concatenator(5'b0, 5'b1, 5'b0);
        verify_outputs(32'b0, 32'b0, "Peter Griffin Family Guy");

        @(posedge clock);
        write_enable = 1;
        data_in = 32'h9;
        instruction = instruction_concatenator(5'b1, 5'b0, 5'b1);

        @(posedge clock);
        write_enable = 0;
        instruction = instruction_concatenator(5'b1, 5'b1, 5'b0);
        
        verify_outputs(32'h9, 32'h9, "Did it put in x1?");

        @(posedge clock);
        write_enable = 1;
        data_in = 32'h11;
        instruction = instruction_concatenator(5'b0, 5'b0, 5'b0);

        @(posedge clock);
        write_enable = 0;
        instruction = instruction_concatenator(5'b0, 5'b0, 5'b0);
        verify_outputs(32'h11, 32'h11, "Did it put it in x0?");


        @(posedge clock);
        write_enable = 0;
        data_in = 32'h13;
        instruction = instruction_concatenator(5'b0, 5'b0, 5'b1);
        
        @(posedge clock);
        write_enable = 0;
        instruction = instruction_concatenator(5'b1, 5'b1, 5'b0);
        
        verify_outputs(32'h13, 32'h13, "I said NO WRITING");

        $finish;
        
    end
endmodule