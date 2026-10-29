module core(
    input wire clock,
    input wire reset,
    output wire [31:0] output_core

    inout wire [31:0] gpio_io,
    input wire uart_rx,
    output wire uart_tx,
    output wire interrupt_signal
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
    wire[31:0] rs1;
    wire[31:0] rs2;
    wire[31:0] register_mux;
    wire[31:0] immediate;
    wire[31:0] alu_input_mux;
    wire[31:0] alu_output;

    wire branch_decision;

    wire rst_n = ~reset;

    wire d_memory_select = (alu_output[31:28] == 4'b0000);
    wire gpio_select = (alu_output[31:28] == 4'b0001);
    wire uart_select = (alu_output[31:28] == 4'b0010);

    wire[31:0] d_memory_write = memory_write & d_memory_select;
    wire[31:0] d_memory_read = memory_read & d_memory_select;
    wire[31:0] gpio_write = memory_write & gpio_select;

    wire[31:0] d_memory_read_data;
    wire[31:0] gpio_read_data;
    wire[31:0] uart_read_data;
    wire[31:0] mmio_read_data;

    wire uart_tx_finished;
    wire[7:0] uart_rx_data;
    wire uart_rx_finished;

    reg uart_tx_busy;
    reg uart_rx_ready;
    reg [7:0] uart_rx_buffer;

    wire uart_tx_start = (uart_select && memory_write && (alu_output[3:0] == 4'b0000) && !uart_tx_busy);

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            uart_tx_busy <= 1'b0;
        end else begin
            if (uart_tx_start)
                uart_tx_busy <= 1'b1;
            else if (uart_tx_finished)
                uart_tx_busy <= 1'b0;
        end
    end

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            uart_rx_ready <= 1'b0;
            uart_rx_buffer <= 8'b0;
        end else begin
            if (uart_rx_finished) begin
                uart_rx_ready <= 1'b1;
                uart_rx_buffer <= uart_rx_data;
            end else if (memory_read && uart_select && (alu_output[3:0] == 4'b0000)) begin
                uart_rx_ready <= 1'b0;
            end
        end
    end

    always @(*) begin
        case (alu_output[3:0])
            4'b0000: uart_read_data = {24'b0, uart_rx_buffer};
            4'b0100: uart_read_data = {30'b0, uart_rx_ready, ~uart_tx_busy};
            default: uart_read_data = 32'b0;
        endcase
    end

assign output_core = alu_output;    

assign pc_mux = (branch_decision) ? pc_branch : pc_next;

assign alu_input_mux = (alu_source) ? immediate : rs2;

assign register_mux = (memory_register) ? data_memory_read : alu_output;

assign pc_branch = pc + immediate;


always @(*) begin
    if (d_memory_select) 
        mmio_read_data = d_memory_read_data;
    else if (gpio_select) 
        mmio_read_data = gpio_read_data;
    else if (uart_select) 
        mmio_read_data = uart_read_data;
    else 
        mmio_read_data = 32'b0;
end



pc_register pc_reg (
    .clock(clock),
    .reset(reset),
    .pc_in(pc_mux),
    .pc_out(pc)
);

pc_adder pc_adder (
    .add_in(pc),
    .add_out(pc_next)
);

i_memory i_memory (
    .pc_in(pc),
    .instruction(instruction)
);

register register (
    .write_enable(register_write),
    .clock(clock),
    .reset(reset),
    .instruction(instruction),
    .data_in(register_mux),
    .data_1(rs1),
    .data_2(rs2)
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
    .instruction(instruction),
    .alu_control_out(alu_control)
);

alu alu (
    .in_1(rs1),
    .in_2(alu_input_mux),
    .control(alu_control),
    .out(alu_output)
);

d_memory d_memory (
    .clock(clock),
    .memory_write(memory_write),
    .memory_read(memory_read),
    .address(alu_output),
    .data_write(rs2),
    .data_read(data_memory_read)
);

branch_comparator branch_comparator (
    .data_1(rs1),
    .data_2(rs2),
    .instruction(instruction),
    .branch_control(branch),
    .branch_decision(branch_decision)
);

d_memory d_memory_inst (
        .clock        (clock),
        .memory_write (d_memory_write),
        .memory_read  (d_memory_read),
        .address      (alu_output),
        .data_write   (rs2),
        .data_read    (d_memory_read_data)
    );

    gpio gpio_inst (
        .clk              (clock),
        .reset            (rst_n),
        .data_in          (rs2),
        .offset           (alu_output[3:0]),
        .write_enable     (gpio_write),
        .select           (gpio_select),
        .data_out         (gpio_read_data),
        .interrupt_signal (interrupt_signal),
        .gpio_io          (gpio_io)
    );

    uart_tx #(
        .baud_clk_bit (868)
    ) uart_tx_inst (
        .clk      (clock),
        .reset    (rst_n),
        .start    (uart_tx_start),
        .data_in  (rs2[7:0]),
        .transfer (uart_tx),
        .finish   (uart_tx_finished)
    );

    uart_rx #(
        .baud_clk_bit (868)
    ) uart_rx_inst (
        .clk      (clock),
        .reset    (rst_n),
        .received (uart_rx),
        .data_out (uart_rx_data),
        .finished (uart_rx_finished)
    );


endmodule