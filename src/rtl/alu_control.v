module alu_control (
    input wire[1:0] alu_operation, // Operation type Identifier
    input wire[31:0] instruction,
    output reg[3:0] alu_control_out // ALU Control 
);

wire[2:0] funct3 = instruction[14:12];
wire funct7_30b = instruction[30];

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
                3'b110: alu_control_out = 4'b0110; // OR
                3'b111: alu_control_out = 4'b0111; // AND
                3'b101: alu_control_out = (funct7_30b) ? 4'b1000 : 4'b1001; 
                default: alu_control_out = 4'b0000;
            endcase
        end
        2'b11: begin
            case (funct3)
                3'b000: alu_control_out = 4'b0000; // ADDI
                3'b001: alu_control_out = 4'b0010; // SLLI
                3'b010: alu_control_out = 4'b0011; // SLTI
                3'b011: alu_control_out = 4'b0100; // SLTIU
                3'b100: alu_control_out = 4'b0101; // XORI
                3'b110: alu_control_out = 4'b0110; // ORI
                3'b111: alu_control_out = 4'b0111; // ANDI
                3'b101: begin
                    case (instruction[30])
                        1'b1: alu_control_out = 4'b1001; // SRAI
                        1'b0: alu_control_out = 4'b1000; // SRLI
                    endcase
                end  
                default: alu_control_out = 4'b0000;
            endcase
        end
        default: begin
            alu_control_out = 4'b0000;
        end
    endcase
end

endmodule
