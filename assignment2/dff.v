module dff (
    input wire [2:0] D,    // Input data (3 bits)
    input wire CLK,        // Clock
    input wire RESET,      // Reset
    output reg [2:0] Q      // Output data (3 bits)
);
    // Instantiating three D flip-flops
       always @(posedge CLK or posedge RESET) begin
        if (RESET)
            Q <= 1'b0;
        else
            Q <= D;
    end
endmodule