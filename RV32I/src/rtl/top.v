`timescale 1ns/1ps

module mcu_top (
    input  wire        clk,
    input  wire        reset,          
    inout  wire [31:0] gpio_io,        
    input  wire        uart_rx,        
    output wire        uart_tx,        
    output wire        gpio_interrupt, 
    output wire [31:0] debug           
);

    wire rst_n = ~reset;

    wire [31:0] memory_addr;
    wire [31:0] memory_data_read;
    wire [31:0] memory_data_write;
    wire        memory_write;
    wire        memory_read;

    wire d_memory_select = (memory_addr[31:28] == 4'h0);
    wire gpio_select     = (memory_addr[31:28] == 4'h1);
    wire uart_select     = (memory_addr[31:28] == 4'h2);

    wire d_memory_we = memory_write & d_memory_select;
    wire d_memory_re = memory_read  & d_memory_select;
    wire gpio_we     = memory_write & gpio_select;

    wire [31:0] d_memory_read;
    wire [31:0] gpio_read;
    reg  [31:0] uart_read;
    reg  [31:0] data_bus_mux;

    always @(*) begin
        if (d_memory_select)
            data_bus_mux = d_memory_read;
        else if (gpio_select)
            data_bus_mux = gpio_read;
        else if (uart_select)
            data_bus_mux = uart_read;
        else
            data_bus_mux = 32'h0000_0000;    
    end

    assign memory_data_read = data_bus_mux;

    wire       uart_tx_finished;
    wire       uart_rx_finished;
    wire [7:0] uart_rx_data;

    reg        uart_tx_busy;
    reg        uart_rx_ready;
    reg  [7:0] uart_rx_buffer;

    wire uart_tx_start = (uart_select && memory_write && (memory_addr[3:0] == 4'h0) && !uart_tx_busy);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            uart_tx_busy <= 1'b0;
        end else begin
            if (uart_tx_start)
                uart_tx_busy <= 1'b1;
            else if (uart_tx_finished)
                uart_tx_busy <= 1'b0;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            uart_rx_ready  <= 1'b0;
            uart_rx_buffer <= 8'h00;
        end else begin
            if (uart_rx_finished) begin
                uart_rx_ready  <= 1'b1;
                uart_rx_buffer <= uart_rx_data;
            end else if (uart_select && memory_read && (memory_addr[3:0] == 4'h0)) begin
                uart_rx_ready  <= 1'b0;
            end
        end
    end

    always @(*) begin
        case (memory_addr[3:0])
            4'h0:    uart_read = {24'h000000, uart_rx_buffer};
            4'h4:    uart_read = {30'h00000000, uart_rx_ready, ~uart_tx_busy};
            default: uart_read = 32'h0000_0000;
        endcase
    end

    core cpu_core (
        .clock(clk),
        .reset(reset),
        .mem_addr(memory_addr),
        .mem_wdata(memory_data_write),
        .mem_we(memory_write),
        .mem_re(memory_read),
        .mem_rdata(memory_data_read),
        .output_core(debug)
    );

    d_memory data_memory (
        .clock(clk),
        .memory_write(d_memory_we),
        .memory_read(d_memory_re),
        .address(memory_addr),
        .data_write(memory_data_write),
        .data_read(d_memory_read)
    );

    gpio gpio_controller (
        .clk(clk),
        .reset(rst_n),
        .data_in(memory_data_write),
        .offset(memory_addr[3:0]),
        .write_enable(gpio_we),
        .select(gpio_select),
        .data_out(gpio_read),
        .interrupt_signal(gpio_interrupt),
        .gpio_io(gpio_io)
    );

    uart_tx #(
        .baud_clk_bit (868)
    ) uart_transmitter (
        .clk(clk),
        .reset(rst_n),
        .start(uart_tx_start),
        .data_in(memory_data_write[7:0]),
        .transfer(uart_tx),
        .finish(uart_tx_finished)
    );

    uart_rx #(
        .baud_clk_bit (868)
    ) uart_receiver (
        .clk(clk),
        .reset(rst_n),
        .received(uart_rx),
        .data_out(uart_rx_data),
        .finished(uart_rx_finished)
    );

endmodule