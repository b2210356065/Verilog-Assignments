`timescale 1ns/10ps

module multiplier_tb;

    reg [2:0] A, B;
    wire [5:0] P;

    multiplier UUT (
        .A(A),
        .B(B),
        .P(P)
    );

    initial begin
        A = 3'b101;  
        B = 3'b010; 
        initial
        #10; 
        if (P !== (A * B)) $display("Test failed. P: %b, Expected: %b", P, A * B);
        else $display("Test passed.");

        $stop; 
    end

endmodule
