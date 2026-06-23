module alu_mux (
    input wire[31:0] in_1,
    input wire[31:0] in_2,
    input wire switch,
    output wire[31:0] out

);

assign out switch ? in_1 : in_2;

endmodule