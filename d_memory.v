module d_memory (
    input wire clock,
    input wire memory_write,
    input wire memory_read,
    input wire[31:0] address,
    input wire[31:0] data_write,
    output wire[31:0] data_read,
);

reg [31:0] ram [0:255]; // Roughly 1 KB
integer i;

initial begin
    for (i = 0; i < 256; i = i + 1) begin
        ram[i] = 32'b0;
    end
end

always @(posedge clock) begin
    if (memory_write) begin
        ram[address[31:2]] <= data_write;
    end
end

assign data_read = (memory_read) ? ram[address[31:2]] : 32'b0;

endmodule