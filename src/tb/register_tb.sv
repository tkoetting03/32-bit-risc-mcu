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

function automatic logic [31:0] instruction_encoder(logic[4:0] rs1, logic[4:0] rs2, logic[4:0] rd);
    instruction_concatenator instruction;
    instruction = '0;
    instruction.rs2 = rs2;
    instruction.rs1 = rs1;
    instruction.rd = rd;
    return instruction;
endfunction

assert_cannot_read_x0_1: assert property (@(posedge clock)
    (instruction[19:15] == 5'b0) |-> (data_1 == '0)
) else $error("Mogged :( Non-zero value read from x0 through data out 1.");

assert_cannot_read_x0_2: assert property (@(posedge clock)
    (instruction[19:15] == 5'b0) |-> (data_2 == '0)
) else $error("Mogged :( Non-zero value read from x0 through data out 2.");

assert_cannot_write_x0: assert property (@(posedge clock)
    (write_enable && (instruction[11:7] == 5'b0)) |-> (data_1 == '0 && data_2 == '0)
) else $error("Mogged :( Data in x0 was overwritten.");

initial begin
    write_enable <= '0;
    data_in <= '0;
    instruction <= '0;

    repeat (2) @(posedge clock);

    @(posedge clock);
    write_enable <= 1'b1;
    data_in <= 32'd9;
    instruction <= instruction_encoder(5'd0, 5'd0, 5'd1);

    @(posedge clock);
    write_enable <= 1'b1;
    data_in <= 32'd10;
    instruction <= instruction_encoder(5'd1, 5'd0, 5'd2);

    @(negedge clock);
    assert (data_out1 == 32'd9)
    else $error("Mogged :( It should be 9 but instead it was %01d.", data_out1);)

    @(posedge clock);
    write_enable <= 1'b0;
    instruction <= instruction_encoder(5'd1, 5'd2, 5'd0);

    @(negedge clock);
    assert (data_out1 == 32'd9 && data_out2 == 32'd10)
    else $error("Mogged :( It should be 9 and 10 but instead it was %01d and %01d", data_out1, data_out2);

    @(posedge clock);
    write_enable <= 1'b1;
    data_in <= 32'd11;
    instruction <= instruction_encoder(5'd0, 5'd0, 5'd0);

    @(negedge clock);
    assert (data_out1 == '0)
    else $error("Mogged :( x0 was overwritten with the value %01d", data_out1);

    $display("Looksmaxxer :)");
    $finish
end    


endmodule