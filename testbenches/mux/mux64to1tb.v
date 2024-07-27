`timescale 1ns / 1ps

module testbench;

// Testbench signals
reg [5:0] sel;
reg [63:0] in;
wire out;

// Instantiate the mux64_1 module
mux64_1 uut (
    .sel(sel),
    .in(in),
    .out(out)
);

// Test procedure
initial begin
    // Initialize inputs
    sel = 0;
    in = 64'hA5A5_A5A5_F0F0_0F0F; // Example input pattern, hexadecimal for clarity

    // Initialize the test loop
    integer i;
    for (i = 0; i < 64; i = i + 1) begin
        #10 sel = i;  // Set selection to current index
        #10 if (out == in[sel])  // Check if the output matches the expected input
            $display("Test %d passed!", i);
    end

    // End of tests
    #10 $finish;
end

endmodule
