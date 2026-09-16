module alu (
    input wire[31:0] in_1,
    input wire[31:0] in_2,
    input wire[3:0] control,
    output reg[31:0] out
);

always @(*) begin
    case (control)
        4'b0000: begin // ADD
            out = in_1 + in_2;
        end
        4'b0001: begin // SUB
            out = in_1 - in_2;
        end
        4'b0010: begin // SLL
            out = in_1 << in_2[4:0];
        end
        4'b0011: begin // SLT
            out = ($signed(in_1) < $signed(in_2)) ? 1 : 0;
        end
        4'b0100: begin // SLTU
            out = (in_1 < in_2) ? 1 : 0;
        end
        4'b0101: begin // XOR
            out = in_1 ^ in_2;
        end
        4'b0110: begin // OR
            out = in_1 | in_2;
        end
        4'b0111: begin // AND
            out = in_1 & in_2;
        end
        4'b1000: begin // SRL
            out = in_1 >> in_2[4:0];
        end
        4'b1001: begin // SRA
            out = $signed(in_1) >>> in_2[4:0];
        end
        default: begin // Default
            out = 32'b0;
        end

    endcase
end

endmodule
