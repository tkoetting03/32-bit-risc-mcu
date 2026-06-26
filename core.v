module core(
    input wire clock,
    input wire reset,
    output wire [31:0] output_core
);
    wire[31:0] pc;
    wire[31:0] pc_mux;
    wire[31:0] pc_next;
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
    wire[31:0] register_mux;
    wire[31:0] immediate;
    wire[31:0] alu_input_mux;
    wire[31:0] alu_output;
    wire[31:0] data_memory_read;

    wire alu_zero = (alu_output == 32'b0);
    reg branch_decision;
    
    always @(*) begin
        if (branch) begin
            case (instruction[14:12])
                3'b000: branch_decision = alu_zero;
                3'b001: branch_decision = !alu_zero;
                default: branch_decision = 1'b0;
            endcase
        end else begin
            branch_decision = 1'b0;
    end
end

assign pc_mux = (branch_decision) ? pc_branch : pc_next;

assign alu_input_mux = (alu_source) ? immediate : register_data_2;

assign register_mux = (memory_register) ? data_memory_read : alu_output;

assign pc_branch = pc + immediate;

pc_register pc_reg (
    .clock(clock),
    .reset(reset),
    .add_in(pc_mux),
    .add_out(pc)
);

pc_adder pc_adder (
    .add_in(pc),
    .add_out(pc_next)
);

i_memory i_memory (
    .pc_add(pc),
    .instruction(instruction)
);

register register (
    .write_enable(register_write),
    .clock(clock),
    .instruction(instruction),
    .data_in(register_mux),
    .data_1(register_data_1),
    .data_2(register_data_2)
);

immediate immediate_module (
    .instruction(instruction),
    .immediate_out(immediate)
);

main main (
    .opcode(instruction[6:0]),
    .branch(branch),
    .memory_read(memory_read),
    .memory_register(memory_register),
    .alu_operation(alu_operation),
    .memory_write(memory_write),
    .alu_source(alu_source),
    .register_write(register_write)
);

alu_control alu_cont (
    .alu_operation(alu_operation),
    .funct3(instruction[14:12]),
    .funct7_30b(instruction[30]),
    .alu_control_out(alu_control)
);

alu alu (
    .in_1(register_data_1),
    .in_2(alu_input_mux),
    .control(alu_control),
    .out(alu_output)
);

d_memory d_memory (
    .clock(clock),
    .memory_write(memory_write),
    .memory_read(memory_read),
    .address(alu_output),
    .data_write(register_data_2),
    .data_read(data_memory_read)
);

branch_comparator branch_comparator (
    .data_1(register_data_1),
    .data_2(register_data_2),
    .instruction(instruction),
    .branch_control(branch),
    .branch_decision(branch_decision)
);


endmodule