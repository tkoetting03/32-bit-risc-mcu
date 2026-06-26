module pc_adder (
    input wire[31:0] add_in,
    output wire[31:0] add_out
);

    assign add_out = add_in + 32'b4;

endmodule
