`timescale 1ns/1ps

module d_memory_tb (
    logic clock;
    logic memory_write;
    logic memory_read;
    logic [31:0] address;
    logic [31:0] data_write;
    logic [31:0] data_read;
);

d_memory uut (
    .clock(clock),
    .memory_write(memory_write),
    .memory_read(memory_read),
    .address(address),
    .data_write(data_write),
    .data_read(data_read)
);

always #5 clcok = ~clock;

assert_no_reading: assert property (@(posedge clock)
    !memory_read |-> (data_read = 32'b0)
) else $error("data_read does not equal 0 when memory_read is low")

task automatic check_read(input [31:0] expected_data, input string test_value);
    @(negedge clock);
    assert (data_read == exp_data) begin
        $display(It works!);
    end else begin
        $error("Mogged :(, pc_out is %d, expected_pc is %d", pc_out, expected_pc);
        $fatal(1);
    end
endtask

initial begin
        memory_write <= 1'b0;
        memory_read  <= 1'b0;
        address      <= 32'b0;
        data_write   <= 32'b0;

        repeat (2) @(posedge clock);

        @(posedge clock);
        memory_read <= 1'b1;
        address     <= 32'd0;
        check_read(32'd0, "Read 0");

        @(posedge clock);
        memory_read <= 1'b0;
        check_read(32'b0, "Nothing being read");

        @(posedge clock);
        memory_write <= 1'b1;
        memory_read  <= 1'b0;
        address      <= 32'd4;
        data_write   <= 32'd1;

        @(posedge clock);
        memory_write <= 1'b0;
        memory_read  <= 1'b1;
        address      <= 32'd4;
        check_read(32'd1, "Read word from 0x4");

        @(posedge clock);
        address <= 32'd5;
        check_read(32'd1, "Wrong address offset");

        @(posedge clock);
        address <= 32'd6;
        check_read(32'd1, "Wrong address offset");

        @(posedge clock);
        address <= 32'd7;
        check_read(32'd1, "Wrong address offset");

        @(posedge clock);
        memory_write <= 1'b0;
        memory_read  <= 1'b0;
        address      <= 32'd4;
        data_write   <= 32'd2;

        @(posedge clock);
        memory_read <= 1'b1;
        check_read(32'd1, "Should still be 1");

        @(posedge clock);
        memory_write <= 1'b1;
        memory_read  <= 1'b0;
        address      <= 32'd30;
        data_write   <= 32'd3;

        @(posedge clock);
        memory_write <= 1'b0;
        memory_read  <= 1'b1;
        check_read(32'd3, "Read word from 0x30");

        @(posedge clock);
        memory_write <= 1'b1;
        memory_read  <= 1'b0;
        address      <= 32'd31;
        data_write   <= 32'd4;

        @(posedge clock);
        memory_write <= 1'b0;
        memory_read  <= 1'b1;
        check_read(32'd4, "Read word from 0x31)");

        $finish;
end

endmodule
