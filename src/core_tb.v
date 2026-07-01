`timescale 1ns / 1ps

module core_tb;
    reg clock;
    reg reset;
    wire[31:0] core_output;
    
    core uut (
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
        $monitor("%0t | %h | %d", $time, uut.instruction, uut.alu_output);
        uut.i_memory.rom[0] = 32'00000000001000001000000110110011;
        reset = 1;
        #20;
        reset = 0;
        #1000;
        $display("Finished");    
        $finish;
    end
end


endmodule
