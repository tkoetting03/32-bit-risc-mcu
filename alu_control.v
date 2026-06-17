module alu_control (
    input wire [1:0] alu_operation,
    input wire [2:0] funct3,
    input wire       funct7_30b,
    output reg [3:0] alu_control_out,
);

always @(*) begin
    case (alu_operation)
        2'b00: begin // Memory Access
            alu_control_out = 4'b0000; // Address offset addition
        end 
        2'b01: begin // Branching
            alu_control_out = 4'b0001; // Branching condition validation
        end
        2'b10:
        default: 
    endcase
end

endmodule
