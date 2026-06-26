module pc_adder (
    input wire[31:0] add_in, // Program Count
    output wire[31:0] add_out // Program Count + 4
);

    assign add_out = add_in + 32'd4;

endmodule
