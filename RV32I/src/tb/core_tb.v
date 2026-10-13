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
        $monitor("%0t | %b | %d", $time, uut.instruction, uut.output_core);
        #1;
        uut.i_memory.rom[0] = 32'b00000000101000000000000010010011;
        uut.i_memory.rom[1] = 32'b00000000010100000000001100010011;
        reset = 1;
        #20;
        reset = 0;
        #200;
        $finish;
    end
end


endmodule
