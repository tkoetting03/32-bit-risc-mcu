module register (
    input wire clk,
    input wire[4:0] add_1,
    input wire[4:0] add_2,
    input wire[4:0] dest_add,
    input wire[31:0] data_in,
    output wire[31:0] data_1,
    output wire[31:0] data_2,

);

reg [31:0] registers [0:31];
integer i;
initial begin
    for (i = 0; i < 32; i = i + 1) begin
        registers[i] = 32'b0; 
    end
end

assign data_1 = (data_1 == 5'b00000) ? 32'b0 : registers[add_1];
assign data_2 = (data_2 == 5'b00000) ? 32'b0 : registers[add_2];


endmodule
