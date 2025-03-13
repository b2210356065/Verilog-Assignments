`timescale 1ns/10ps

module full_adder(
    input A, B, Cin,
    output S, Cout
);
wire toplam1;
wire toplam2;
wire cikti1;
wire cikti;

    half_adder half_adder_1(.A(A),.B(B),.C(cikti1),.S(toplam1));
    half_adder half_adder_2(.A(toplam1),.B(Cin),.C(cikti),.S(S));
    or(Cout , cikti1 , cikti);

    

endmodule