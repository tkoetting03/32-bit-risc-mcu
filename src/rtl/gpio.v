module gpio (

    input wire clk,
    input wire reset,
    input wire[31:0] data_in,
    output reg[31:0] data_out,


);

reg [31:0] in_sync;
reg [31:0] ext_synx;

always @(posedge clk || negedge reset) begin
    if (!reset) begin
        in_sync <= 32'b0;
        ext_sync <= 32'b0;
        data_out <= 32'b0;
    end else begin
        
    end
end


endmodule