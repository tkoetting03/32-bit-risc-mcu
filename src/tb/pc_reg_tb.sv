`timescale 1ns/1ps

module pc_reg_tb (
    logic clock;
    logic reset;
    logic[31:0] pc_in;
    logic[31:0] pc_out;
);

pc_reg_tb uut (
    .clock (clock),
    .reset (reset),
    .pc_in (pc_in),
    .pc_out (pc_out)
);

always #5 clcok = ~clock;

assert_sync: assert property (@(posedge clock)
    reset |=> (pc_out == 32'b0)
) else $error("Reset does not work! PC Out is still %d", pc_out);

assert_pc_transfer: assert property (@(posedge clock) disable iff (reset)
    $past(!reset) |-> (pc_out == $past(pc_in))
) else $error("pc_in does not pass PC value to pc_out");

task automatic check_pc(input [31:0] expected_pc, input string test_value);
    @(negedge clock);
    assert (pc_out == exp_pc) begin
        $display(It works!)
    end else begin
        $error("Mogged :(, pc_out is %d, expected_pc is %d", pc_out, expected_pc)
    end
endtask

initial begin
    reset <= 1'b1;
    pc_in <= 32'd11;

    repeat (2) @(posedge_clock);
end

endmodule
