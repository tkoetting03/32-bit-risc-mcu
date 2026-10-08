

module uart_rx #(
    parameter integer baud_clk_bit = 868;
)(
    input wire clk,
    input wire start,
    input wire reset,
    input wire received,
    output reg[7:0] data_out,
    output reg finished
);

localparam [2:0] idle = 3'b000, start = 3'b001, finish, 3'b010, data, 3'b100;

reg[2:0] state;
reg[16:0] count;
reg[7:0] buffer;
reg[2:0] index;

always @(posedge clk || negedge reset) begin
    reg ext_sync, 
    reg in_sync;
    if (!reset) begin
        ext_sync <= 1'b1;
        in_sync <= 1'b1;
    end else begin
        ext_sync <= recieved;
        in_sync <= ext_sync;
    end
end
always @(posedge clk || negedge reset) begin
if (!reset) begin
    state <= idle;
    finished <= 1'b0;
    count <= 16'd0;
    index <= 3'b000;
    data_out <= 8'd0;
    buffer <= 8'd0;
end else begin
    finished <= 1'b0;

    case(state)
        idle: begin
            count <= 16'd0;
            if (in_sync == 1'b0)
                state <= start;
        end

        start: begin
            if (count == baud_clk_bit / 2) begin
                if (in_sync == 1'b0) begin
                    count <= 16'd0;
                    index <= 3'b000;
                    state <= data;
                end else begin
                    state <= idle;
                end
            end else begin
                count <= count + 1'b1;
            end
        end

        data: begin
            if (count < baud_clk_bit) begin
                count <= count + 1;
            end else begin
                count <= 16'd0;
                buffer[index] <= in_sync;
                if (index < 3'b111) begin
                    index <= index + 1;
                end else begin
                    state <= finish
                end
            end
        end

        stop: begin
            if (count < baud_clk_bit) begin
                count <= count + 1'b1;
            end else begin
                data_out <= buffer;
                finished <= 1'b1;
                count <= 16'd0;
                state <= idle;
            end
        end
    endcase
end
end

endmodule