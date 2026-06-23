module i_memory (
    input wire[31:0] pc_add,
    output wire[31:0] instruction
);

reg [31:0] rom [0:255];

integer i;

initial begin
    for (i = 0; i < 256; i = i + 1) begin
        rom[i] <= 32'b0;
    end
end

assign instruction = rom[pc_add[31:2]];

endmodule

