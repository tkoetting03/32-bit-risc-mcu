

module uart_tx #(
    parameter integer baud_clk_bit = 868
)(
    input wire clk,
    input wire start_tx,
    input wire reset,
    input wire[7:0] data_in,
    output reg transfer,
    output reg finished
);

localparam [2:0] idle = 3'b000, start = 3'b001, data = 3'b010, stop = 3'b100;

reg[2:0] state;
reg[16:0] count;
reg[7:0] buffer;
reg[2:0] index;

always @(posedge clk or negedge reset) begin
    if (!reset) begin
        state <= idle;
        count <= 32'd0;
        buffer <= 8'd0;
        transfer <= 1'b1;
        index <= 2'b0;
        finished <= 1'b0;
    end else begin
        finished <= 1'b0;

        case (state)
            idle: begin
                transfer <= 1'b1;
                count <= 16'd0;
                if (start_tx) begin
                    buffer <= data_in;
                    state <= start;
                end

                
            end

            start: begin
                transfer <= 1'b0;
                if (count < baud_clk_bit - 1) begin
                    count <= count + 1'b1;
                end else begin
                    count <= 16'd0;
                    state <= data;
                    index <= 3'b000;
                end
            end

            data: begin
                transfer <= buffer[index];
                if (count < baud_clk_bit - 1) begin
                    count <= count + 1'b1;
                end else begin
                    count <= 16'd0;
                    if (index < 3'b111) begin
                        index <= index + 1'b1;
                    end else begin
                        state <= stop;
                    end
                end
                
            end


            stop: begin
                transfer <= 1'b1;
                if (count < baud_clk_bit - 1) begin
                    count <= count + 1'b1;
                end else begin  
                    count <= 16'd0;
                    state <= idle;
                    finished <= 1'b1;
                end

                
            end

            default: state <= idle;
        endcase
    end
end

endmodule