module gpio (

    input wire clk,
    input wire reset,
    input wire[31:0] data_in,
    input wire[3:0] offset,
    input wire write_enable,
    input wire select,
    output reg[31:0] data_out,
    output reg interrupt_signal,

    inout wire[31:0] gpio_io

);

reg [31:0] reg_data_out;
reg [31:0] reg_direction;
reg [31:0] reg_interrupt;


reg [31:0] in_sync;
reg [31:0] ext_sync;
reg [31:0] sync_history;

genvar i;
generate
    for (i = 0; i < 32; i = i + 1) begin
        assign gpio_io[i] = reg_direction[i] ? reg_data_out[i] : 1'bz;
    end
endgenerate

always @(posedge clk or negedge reset) begin
    if (!reset) begin
        in_sync <= 32'b0;
        ext_sync <= 32'b0;
        sync_history <= 32'b0;
    end else begin
        ext_sync <= gpio_io;
        in_sync <= ext_sync;
        sync_history <= in_sync;
    end
end

localparam [3:0] ro_data_in = 4'b0000, rw_data_out = 4'b0100, rw_direction = 4'b1000, rw_interrupt = 4'b1100;

always @(posedge clk or negedge reset) begin
    if (!reset) begin
        reg_data_out <= 32'b0;
        reg_direction <= 32'b0;
        reg_interrupt <= 32'b0;
    end else if (select && write_enable) begin
        case (offset)
            rw_data_out: reg_data_out <= data_in;
            rw_direction: reg_direction <= data_out;
            rw_interrupt: reg_interrupt <= data_out;
        endcase 
    end
end

always @(posedge clk or negedge reset) begin
    if (!reset) begin
        data_out <= 32'b0;
    end else if (select && !write_enable) begin
        case (offset)
            ro_data_in: data_out <= in_sync;
            rw_data_out: data_out <= reg_data_out;
            rw_direction: data_out <= reg_direction;
            rw_interrupt: data_out <= reg_interrupt;
            default: data_out <= 32'b0; 
        endcase
    end else begin
        data_out <= 32'b0;
    end
end

wire[31:0] rising_edge = (~sync_history) & in_sync;

always @(posedge clk or or negedge reset) begin
    if (!reset) begin
        interrupt_signal <= 1'b0;
    end else begin
        interrupt_signal <=| (rising_edge & reg_interrupt & ~reg_direction);
    end
end


endmodule