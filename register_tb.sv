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

typedef struct packed {
    logic [6:0] funct7;
    logic [4:0] rs2;
    logic [4:0] rs1;
    logic [2:0] funct3;
    logic [4:0] rd;
    logic [6:0] opcode;
} instruction_concatenator;

function automative logic [31:0] instruction_encoder(logic[4:0] rs1, logic[4:0] rs2, logic[4:0] rd);
    instruction_concatenator instruction;
    instruction = '0;
    instruction.rs2 = rs2;
    instruction.rs1 = rs1;
    instruction.rd = rd;
    return instruction;
endfunction


endmodule