module core(
    input wire clock,
    input wire reset,

);
    wire[31:0] pc;
    wire[31:0] pc_next;
    wire[31:0] pc_pfour;
    wire[31:0] pc_branch;
    wire[31:0] instruction;
    
    wire branch;
    wire memory_read;
    wire memory_register;
    wire memory_write;
    wire alu_source;
    wire register_write;
    wire[1:0] alu_operation;
    wire[3:0] alu_control;
    wire[31:0] register_data_1;
    wire[31:0] register_data_2;
    wire[31:0] register_write_data;
    wire[31:0] immediate;
    wire[31:0] alu_operand;
    wire[31:0] alu_output;
    wire[31:0] data_memory_read;

    wire zero = (alu_output == 32'b0);
    reg branch_decision;
    
    always @(*) begin
        if (branch) begin
            case (instruction[14:12])
                3'b000: branch_decision = zero;
                3'b001: branch_decision = !zero;
                default: branch_decision = 1'b0;
            endcase
        end else begin
            branch_decision = 1'b0;
    end


endmodule