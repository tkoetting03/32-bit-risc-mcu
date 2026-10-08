module gpio (

    input wire clk,
    input wire reset,
    input wire[31:0] data_in,
    input wire[3:0] offset,
    input wire write_enable,
    input wire select,
    output reg[31:0] data_out,

    inout wire[31:0] gpio_io

);

reg [31:0] reg_data_out;
reg [31:0] reg_direction;
reg [31:0] reg_interrupt;


reg [31:0] in_sync;
reg [31:0] ext_sync;
reg [31:0] sync_history;

genvari i;
generate
    for (i = 0; i < 32; i = i + 1) begin
        assign gpio_io[i] = reg_direction[i] ? reg_data_out[i] : 1'b0;
    end
endgenerate

always @(posedge clk || negedge reset) begin
    if (!reset) begin
        in_sync <= 32'b0;
        ext_sync <= 32'b0;
        sync_history <= 32'b0;
    end else begin
        ext_synx <= gpio_io;
        in_sync <= ext_synx;
        sync_history <= in_sync;
    end
end

localparam [3:0] = ro_data_in = 4'b0000, rw_data_out = 4'b0100, rw_direction = 4'b1000, rw_interrupt = 4'b1100;

always @(posedge clk || negedge reset) begin
    if (!reset) begin
        reg_data_out <= 32'b0;
        reg_direction <= 32'b0;
        reg_interrupt <= 32'b0;
    end else if (select && write_enable) begin
        case (offset)
            rw_data_out: reg_data_out <= data_out;
            rw_direction: reg_direction <= data_out;
            rw_interrupt: reg_interrupt <= data_out;
        endcase 
    end
end





endmodule