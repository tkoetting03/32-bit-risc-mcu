module sram_controller(

    input wire clk,
    input wire reset,
    input wire memory_req,
    input wire memory_write ,
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

reg[31:0] reg_data_in;
reg reg_enable;

reg[3:0] state;
reg[3:0] next_state;

localparam [3:0] idle = 4'b000, wait_read = 4'b0001, write = 4'b0010, hold_write = 4'b0011;

assign sram_dp = reg_enable ? reg_data_in : 32'bz;

always @(posedge clk or negedge reset) begin
    if (!reset) begin
        state <= idle;
    end else begin
        state <= next_state;
    end
end

always @(*) begin
    next_state = state;

    case (state)
        idle: begin
            if (memory_req) begin
                if (memory_write)
                    next_state = write;
                else
                    next_state = wait_read; 
            end    
        end
        

        wait_read: begin
            next_state = idle;
        end

        write: begin
            next_state = hold_write;
        end

        hold_write: begin
            next_state = idle;
        end

        default: next_state = idle;
    endcase
end


always @(posedge clk or negedge reset) begin
    if (!reset) begin
        sram_addr <= 18'b0;
        reg_data_in <= 32'b0;
        data_out <= 32'b0;
        finished <= 1'b0;
        reg_enable <= 1'b0;
        select <= 1'b1;
        output_enable <= 1'b1;
        write_enable <= 1'b1;
    end else begin
        finished <= 1'b0;

        case (state)
        idle: begin
            reg_enable <= 1'b0;
            select <= 1'b1;
            output_enable <= 1'b1;
            write_enable <= 1'b1;

            if (memory_req) begin
                sram_addr <= memory_addr;
               if (memory_write) begin
                    reg_data_in <= data_in;
                    reg_enable <= 1'b1;
                    select <= 1'b0;
                    output_enable <= 1'b1;
                    write_enable <= 1'b0;
               end else begin
                    reg_enable <= 1'b0;
                    select <= 1'b0;
                    output_enable <= 1'b0;
                    write_enable <= 1'b1;
               end
            end
        end

        wait_read: begin
            data_out <= sram_dp;
            finished <= 1'b1;
            select <= 1'b1;
            output_enable <= 1'b1;
        end
        
        write: begin
            write_enable <= 1'b1;
        end

        hold_write: begin
            reg_enable <= 1'b0;
            select <= 1'b1;
            finished <= 1'b1;
        end
        
        default: begin
            select <= 1'b1;
            output_enable <= 1'b1;
            write_enable <= 1'b1;
            reg_enable <= 1'b0;
        end
        endcase
    end
end

endmodule