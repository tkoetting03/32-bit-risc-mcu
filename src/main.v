module main (
    input wire[6:0] opcode,
    output reg branch,
    output reg memory_read,
    output reg memory_register,
    output reg[1:0] alu_operation,
    output reg memory_write,
    output reg alu_source,
    output reg register_write
);

always @(*) begin
    case (opcode)
        7'b0110011: begin // R-type
            branch = 1'b0;
            memory_read = 1'b0;
            memory_register = 1'b0;
            alu_operation = 2'b10;
            memory_write = 1'b0;
            alu_source = 1'b0;
            register_write = 1'b1;
        end 
        7'b0010011: begin // I-type
            branch = 1'b0;
            memory_read = 1'b0;
            memory_register = 1'b0;
            alu_operation = 2'b10;
            memory_write = 1'b0;
            alu_source = 1'b1;
            register_write = 1'b1;
        end 
        7'b0000011: begin // lw
            branch = 1'b0;
            memory_read = 1'b1;
            memory_register = 1'b1;
            alu_operation = 2'b00;
            memory_write = 1'b0;
            alu_source = 1'b1;
            register_write = 1'b1;
        end 
        7'b0110011: begin // sw
            branch = 1'b0;
            memory_read = 1'b0;
            memory_register = 1'b0;
            alu_operation = 2'b00;
            memory_write = 1'b1;
            alu_source = 1'b1;
            register_write = 1'b0;
        end 
        7'b0110011: begin // Branching
            branch = 1'b1;
            memory_read = 1'b0;
            memory_register = 1'b0;
            alu_operation = 2'b01;
            memory_write = 1'b0;
            alu_source = 1'b0;
            register_write = 1'b0;
        end 
        default: begin // 
            branch = 1'b0;
            memory_read = 1'b0;
            memory_register = 1'b0;
            alu_operation = 2'b00;
            memory_write = 1'b0;
            alu_source = 1'b0;
            register_write = 1'b0;
        end 
        
    endcase
end

endmodule