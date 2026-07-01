`timescale 1ns / 1ps

module core_tb;
    reg clock;
    reg reset;
    wire[31:0] core_output;
    
    core core_tb (
        .clock(clock),
        .reset(reset),
        .output_core(core_output)
    );

initial begin
    clock = 0;
    forever #5 clock = ~clock;
end

initial begin
    begin
        reset = 1;
        #20;
        reset = 0;
        #1000;
        $display("Finished");    
        $finish;
    end
end


endmodule
