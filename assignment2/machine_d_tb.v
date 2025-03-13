`timescale 1ns / 1ps

module machine_d_tb;
    reg x, CLK, RESET;
    wire F;
    wire [2:0] S;

    // Instantiate the machine_d module
    machine_d machine_inst (
        .x(x),
        .CLK(CLK),
        .RESET(RESET),
        .F(F),
        .S(S)
    );

    // Clock generation
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end

    initial begin
        $display("Test Case 1: Normal operation");
        RESET = 0;
        x = 0;
        #10;
        x = 1;
        #10;
        x = 0;
        #10;
        x = 1;
        #10;
        x = 0;
        #20 $stop;
    end

    initial begin
        $display("Test Case 2: Reset operation");
        RESET = 1;
        x = 0;
        #10;
        RESET = 0;
        #10;
        x = 1;
        #10;
        x = 0;
        #20 $stop;
    end
endmodule
