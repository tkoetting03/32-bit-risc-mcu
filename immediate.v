module immediate (
    input wire[31:0] instruction,
    output reg[31:0] immediate_out
);

wire [6:0] opcode = instruction[6:0];

always @(*) begin
    case (opcode)

end
endmodule

