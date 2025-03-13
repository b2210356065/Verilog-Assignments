module jkff (
    input J,      // Data input
    input K,      // Data input
    input CLK,    // Clock input
    input RESET,  // Asynchronous reset, active high
    output reg Q  // Output
);
    // JK flip-flop implementation
    always @(posedge CLK or posedge RESET) begin
        if (RESET)
            Q <= 1'b0;
        else begin
            case ({J, K})
                2'b01: Q <= 1'b0;  // J=0, K=1 (Clear)
                2'b10: Q <= 1'b1;  // J=1, K=0 (Set)
                2'b11: Q <= ~Q;   
                default: Q <= Q;  
            endcase
        end
    end
endmodule
