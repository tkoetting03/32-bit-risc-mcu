module pc_register (
    input wire clock,
    input wire reset, 
    input wire[31:0] pc_in, // PC MUX Output
    output reg[31:0] pc_out // Program Count
);

always @(posedge clock) begin
    if (reset) begin
        pc_out <= 32'b0; // Set Program Count to 32'b0
    end else begin
        pc_out <= pc_in; // Set Program Count to PC MUX Output
    end
end 

endmodule