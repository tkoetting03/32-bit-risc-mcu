module branch_comparator (
    input wire[31:0] data_1,
    input wire[31:0] data_2,
    input wire[2:0] funct3,
    input wire branch_control,
    output reg branch_decision
);

always @(*) begin
    if (branch_control) begin
        case (funct3)
            3'b000: begin
                branch_decision = (data_1 == data_2);
            end
            3'b001: begin
                branch_decision = (data_1 != data_2);
            end
            3'b100: begin
                branch_decision = ($signed(data_1) < $signed(data_2));
            end
            3'b101: begin
                branch_decision = ($signed(data_1) >= $signed(data_2)); 
            end
            3'b110: begin
                branch_decision = (data_1 < data_2); 
            end
            3'b111: begin
                branch_decision = (data_1 >= data_2); 
            end
            default: begin
                branch_decision = 1'b0;
            end
        endcase
    end else begin
        branch_decision = 1'b0;
    end
end

endmodule