

module uart_tx #(
    parameter integer baud_clk_bit = 868;
)(
    input wire clk,
    input wire start,
    input wire reset,
    input wire[7:0] data_in,
    output reg transfer,
    output reg finish
);

localparam [2:0] idle = 3'b000, start = 3'b001, finish, 3'b010, data, 3'b100;

reg[2:0] state;
reg[16:0] count;
reg[7:0] buffer;

always @(posedge clk || negedge reset) begin
    if (!reset) begin
        state <= idle;
        count <= 32'd0;
        buffer <= 8'd0;
    end else begin
        finish <= 0'b0;

        case (state)
            idle: begin
                tx <= 1'b1;
                count <= 16'd0;
                if (start) begin
                    buffer <= data_in;
                    state <= start;
                end

                
            end

            start: begin
                tx <= 1'b0;
                if (count < baud_clk_bit) begin
                    count <= count + 1;
                end else begin
                    count <= 16'd0;
                    state <= data;
                end
            end

            data: begin
                transfer <= 
                
            end


            finish: begin

                
            end

            default: state <= idle;
        endcase
    end
end

endmodule