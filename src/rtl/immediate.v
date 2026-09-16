module immediate (
    input wire[31:0] instruction,
    output reg[31:0] immediate_out
);

wire [6:0] opcode = instruction[6:0];

always @(*) begin
    case (opcode)
    7'b0010011, 7'b0000011, 7'b1100111: begin
        immediate_out = {{20{instruction[31]}}, instruction[31:20]}; // I-type
    end
    7'b0100011: begin
        immediate_out = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; // S-Type
    end
    7'b1100011: begin
        immediate_out = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0}; // B-type
    end
    7'b0110111: begin
        immediate_out = {instruction[31:12], 12'b0}; // U-type
    end
    7'b1101111: begin
        immediate_out = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0}; // J-type
    end
    default: begin
        immediate_out = 32'b0;
    end
    endcase

end
endmodule

