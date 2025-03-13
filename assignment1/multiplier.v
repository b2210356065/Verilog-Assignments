`timescale 1ns/10ps

module multiplier (
    input [2:0] A, B,
    output [5:0] P
);

    reg [5:0] P_internal; 

    always @* begin
        P_internal = A * B;
    end

	assign P = P_internal;

endmodule
