`timescale 1ns/1ps

module tb_mcu_top;
    logic        clk = 0;
    logic        reset;
    wire  [31:0] gpio_io;
    logic        uart_rx;
    wire         uart_tx;
    wire         gpio_interrupt;
    wire  [31:0] debug;

    logic [31:0] tb_gpio_data_out;
    logic [31:0] tb_gpio_dir;
    assign gpio_io = tb_gpio_dir ? tb_gpio_data_out : 32'bz;

    always #5 clk = ~clk;

    localparam int BAUD_CLKS = 868;

    mcu_top dut (
        .clk            (clk),
        .reset          (reset),
        .gpio_io        (gpio_io),
        .uart_rx        (uart_rx),
        .uart_tx        (uart_tx),
        .gpio_interrupt (gpio_interrupt),
        .debug          (debug)
    );

    assert_reset_pc: assert property (@(posedge clk)
        reset |=> (dut.cpu_core.pc == 32'h0000_0000)
    ) else $error("Reset failed");

    assert_x0_zero: assert property (@(posedge clk)
        (dut.cpu_core.register.registers[0] == 32'h0)
    ) else $error("x0 is not zero");

    assert_pc_aligned: assert property (@(posedge clk) disable iff (reset)
        (dut.cpu_core.pc[1:0] == 2'b00)
    ) else $error("PC is not aligned: 0x%08h", dut.cpu_core.pc);

    assert_uart_idle_high: assert property (@(posedge clk) disable iff (reset)
        (!dut.uart_tx_busy) |-> (uart_tx == 1'b1)
    ) else $error("UART TX low while idle");

    assert_dmem_isolation: assert property (@(posedge clk) disable iff (reset)
        (dut.gpio_select || dut.uart_select) |-> (!dut.d_memory_we)
    ) else $error("Data memory write signal sent during MMIO peripheral access");

    task automatic check_uart_tx_byte(input logic [7:0] exp_byte);
        logic [7:0] captured_byte;
        @(negedge uart_tx);
        repeat (BAUD_CLKS / 2) @(posedge clk);
        assert (uart_tx === 1'b0)
            else $fatal(1, "UART TX false start bit");
        for (int i = 0; i < 8; i++) begin
            repeat (BAUD_CLKS) @(posedge clk);
            captured_byte[i] = uart_tx;
        end
        repeat (BAUD_CLKS) @(posedge clk);
        assert (uart_tx === 1'b1)
            else $fatal(1, "UART TX framing error on Stop bit");

        assert (captured_byte === exp_byte) begin
            $display("UART TX: 0x%02h ('%c') at %0t", captured_byte, captured_byte, $time);
        end else begin
            $display("UART TX Mismatch: got 0x%02h, s/b 0x%02h at %0t", captured_byte, exp_byte, $time);
            $fatal(1, "UART TX failed.");
        end
    endtask

    task automatic send_uart_rx_byte(input logic [7:0] rx_byte);
        uart_rx <= 1'b0;
        repeat (BAUD_CLKS) @(posedge clk);
        for (int i = 0; i < 8; i++) begin
            uart_rx <= rx_byte[i];
            repeat (BAUD_CLKS) @(posedge clk);
        end

        uart_rx <= 1'b1;
        repeat (BAUD_CLKS) @(posedge clk);
        $display("UART RX: 0x%02h ('%c') at %0t", rx_byte, rx_byte, $time);
    endtask
    initial begin
        uart_rx          = 1'b1;
        tb_gpio_dir      = 32'h0000_0000;
        tb_gpio_data_out = 32'h0000_0000;
        reset            = 1'b1;
        dut.cpu_core.i_memory.rom[0]  = 32'h00A0_0093;
        dut.cpu_core.i_memory.rom[1]  = 32'h0010_2223;
        dut.cpu_core.i_memory.rom[2]  = 32'h0040_2103;
        dut.cpu_core.i_memory.rom[3]  = 32'h0010_0193;
        dut.cpu_core.i_memory.rom[4]  = 32'h01C1_9193;
        dut.cpu_core.i_memory.rom[5]  = 32'h0FF0_0213;
        dut.cpu_core.i_memory.rom[6]  = 32'h0041_A423;
        dut.cpu_core.i_memory.rom[7]  = 32'h0A50_0293;
        dut.cpu_core.i_memory.rom[8]  = 32'h0051_A223;
        dut.cpu_core.i_memory.rom[9]  = 32'h0011_9313;
        dut.cpu_core.i_memory.rom[10] = 32'h0053_2023;
        dut.cpu_core.i_memory.rom[11] = 32'h0000_0063;

        repeat (3) @(posedge clk);
        @(negedge clk);
        reset = 1'b0;
        $display("Reset at %0t", $time);

        @(negedge clk);
        assert (dut.data_memory.ram[1] === 32'd10)
            else $fatal(1, "S/b 10 in RAM[1]");
        assert (dut.cpu_core.register.registers[2] === 32'd10)
            else $fatal(1, "S/b 10 in register x2");
        $display("RAM write and read works.");

        repeat (4) @(posedge clk);
        @(negedge clk);
        assert (dut.gpio_controller.reg_direction === 32'h0000_00FF)
            else $fatal(1, "GPIO Error: reg_direction != 0x000000FF");

        repeat (2) @(posedge clk);
        @(negedge clk);
        assert (gpio_io[7:0] === 8'hA5)
            else $fatal(1, "GPIO Error: [7:0] s/b 0xA5, got 0x%02h", gpio_io[7:0]);
        assert (gpio_io[31:8] === 24'bzzzzzzzzzzzzzzzzzzzzzzzz)
            else $fatal(1, "GPIO Error: [31:8] not floating high");
        $display("MMIO GPIO direction and output works");

        repeat (2) @(posedge clk);
        fork
            check_uart_tx_byte(8'hA5);
        join
        $display("MMIO UART TX transmission works");

        send_uart_rx_byte(8'h3C);

        repeat (10) @(posedge clk);
        @(negedge clk);

        assert (dut.uart_rx_ready === 1'b1)
            else $fatal(1, "UART RX Error: uart_rx_ready flag not asserted");
        assert (dut.uart_rx_buffer === 8'h3C)
            else $fatal(1, "UART RX Error: s/b 0x3C in rx_buffer, got 0x%02h", dut.uart_rx_buffer);

        $display("It works! :)");
        $finish;
    end

endmodule