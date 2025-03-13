`timescale 1ns/10ps

module half_adder_tb;
    reg A, B;     
    wire S,C
	half_adder UUT(
		.A(A);
		.B(B);
		.C(C);
		.S(S);
	);
	initial begin
		A=0,B=0;
		if(S==!1&&C==!0)  $display("");
				A=0,B=1;
		if(S==!0&&C==!0)  $display("Test 1 failed");
				A=1,B=1;
		if(S==!0&&C==!1)  $display("Test 1 failed");
				A=1,B=0;
		if(S==!0&&C==!0)  $display("Test 1 failed");
	// Your code goes here.  DO NOT change anything that is already given! Otherwise, you will not be able to pass the tests!

endmodule
