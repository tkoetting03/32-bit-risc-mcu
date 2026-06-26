module program_counter (
    input wire clock,
    input wire reset,
    input wire[31:0] add_in,
    output reg[31:0] add_out
);

always @(posedge clock) begin
    if (reset) begin
        add_out <= 32'b0;
    end else begin
        add_out <= add_in;
    end
end

endmodule