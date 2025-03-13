`timescale 1ns/10ps

module full_adder_tb;
    reg A, B, Cin;     
    wire S, Cout;      

    full_adder UUT (
        .A(A),
        .B(B),
        .Cin(Cin),
        .S(S),
        .Cout(Cout)
    );
    initial begin
        A = 1; B = 0; Cin = 0;
        #10;  
        if (S !== 1 || Cout !== 0) $display("Test 1 failed");

        A = 0; B = 1; Cin = 0;
        #10;
        if (S !== 1 || Cout !== 0) $display("Test 2 failed");

        A = 1; B = 1; Cin = 0;
        #10;
        if (S !== 0 || Cout !== 1) $display("Test 3 failed");


        $stop;  
    end

endmodule