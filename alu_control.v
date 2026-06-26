module alu_control (
    input wire [1:0] alu_operation, // Operation type Identifier
    input wire [2:0] funct3, // Opcode
    input wire       funct7_30b, // Bit 30 in funct7
    output reg [3:0] alu_control_out // ALU Control 
);

always @(*) begin
    case (alu_operation)
        2'b00: begin // Memory Access
            alu_control_out = 4'b0000; 
        end 
        2'b01: begin // Branching
            alu_control_out = 4'b0001; 
        end
        2'b10: begin // Arithmetic
            case (funct3)
                3'b000: alu_control_out = (funct7_30b) ? 4'b0001 : 4'b0000; 
                3'b001: alu_control_out = 4'b0010; // SLL
                3'b010: alu_control_out = 4'b0011; // SLT
                3'b011: alu_control_out = 4'b0100; // SLTU
                3'b100: alu_control_out = 4'b0101; // XOR
                3'b101: alu_control_out = 4'b0110; // OR
                3'b110: alu_control_out = 4'b0110; // AND
                3'b111: alu_control_out = (funct7_30b) ? 4'b1000 : 4'b1001; 
                default: alu_control_out = 4'b0000;
            endcase
        end
        default: begin
            alu_control_out = 4'b0000;
        end
    endcase
end

endmodule
