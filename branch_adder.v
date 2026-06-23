module branch_adder (
    input wire[31:0] pc_address,
    input wire[31:0] immediate,
    output wire[31:0] target,
);

assign target = pc_address + immediate;

endmodule