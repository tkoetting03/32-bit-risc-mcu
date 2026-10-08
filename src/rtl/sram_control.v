module sram_controller(

    input wire clk,
    input wire reset,
    input wire memory_req,
    input wire[17:0] memory_addr,
    input wire[31:0] data_in,

    output reg[31:0] data_out,
    output reg[17:0] sram_addr,
    output reg finished,
    output reg select,
    output reg output_enable,
    output reg write_enable,

    inout wire[31:0] sram_dp

);

reg[17:0] reg_address;
reg[31:0] reg_data_in;
reg reg_enable;

reg[3:0] state;
reg[3:0] next_state;

localparam [3:0] = idle = 4'b000, wait_read = 4'b0001, write = 4'b0010, hold_write = 4'b0011;

assign data_dp = reg_enable ? reg_data_in : 32'b0;

always @(posedge clk || negedge reset) begin
    if (!reset) begin
        state <= idle;
    end else begin
        state <= next_state;
    end
end

always @(*) begin
    next_state = state;

    case (state)
        idle: if (memory_req) begin
            if (write_enable) begin
                next_state <= write;
            end else begin
                next_state <= wait_read;
            end
        end

        wait_read: begin
            next_state <= idle;
        end

        write: begin
            next_state <= hold_write;
        end

        write_hold:begin
            next_state <= idle;
        end

        default: next_state <= idle;
    endcase
end


always @(posedge clk || negedge reset) begin
    if (!reset) begin
        reg_address <= 18'b0;
        reg_data_in <= 32'b0;
        data_in <= 32'b0;
        memory_req <= 1'b0;
        reg_enable <= 1'b0;
        sram_addr <= 18'b0;
        select <= 1'b1;
        output_enable <= 1'b1;
        write_enable <= 1'b1;
    end else begin
        memory_req <= 1'b0;

        case (next_state)
        idle: begin
            data_dp <= 1'b0;
            select <= 1'b1;
            output_enable <= 1'b1;
            write_enable <= 1'b1;
        end

        wait_read: begin
            sram_addr <= memory_addr;
            select <= 1'b0;
            output_enable <= 1'b0;
            write_enable <= 1'b1;
            data_dp <=  1'b0;
        end
        
        write: begin
            reg_address <= memory_addr;
            reg_data_in <= data_in;
            sram_addr <= memory_addr;
            select <= 1'b0;
            output_enable <= 1'b1;
            write_enable <= 1'b0;
            data_dp <= 1'b1;
        end

        hold_write: begin
            write_enable <= 1'b1;
            select <= 1'b0;
            output_enable <= 1'b1;
            data_dp <= 1'b1;
            memory_req <= 1'b1;
        end

        endcase

        if (current_state == wait_read) begin
            data_out <= sram_dp;
            memory_req <= 1'b1;
        end

    end
end

endmodule