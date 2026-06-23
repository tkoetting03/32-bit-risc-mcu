module register_mux (
    input wire[31:0] alu_result,
    input wire[31:0] memory_read,
    input wire memory_register,
    output wire[31:0] write_data
);

assign write_data (memory_register) ? memory_read : alu_result;

endmodule