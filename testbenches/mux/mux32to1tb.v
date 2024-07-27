`timescale 1ns / 1ps

module testbench;

// Testbench signals
reg [4:0] sel;
reg [31:0] in;
wire out;

// Instantiate the mux32_1 module
mux32_1 uut (
    .sel(sel),
    .in(in),
    .out(out)
);

// Test procedure
initial begin
    // Initialize inputs
    sel = 0;
    in = 32'hCAFEBABE; // Example input pattern, hexadecimal for clarity

    // Test cases for each select signal
    #10 sel = 5'b00000; // Test 0
    #10 if (out == in[0]) $display("Test 0 passed!");

    #10 sel = 5'b00001; // Test 1
    #10 if (out == in[1]) $display("Test 1 passed!");

    // Continue with similar pattern
    repeat (30) begin
        #10 sel = sel + 1; // Increment select to test next input
        #10 if (out == in[sel]) $display("Test %d passed!", sel);
    end

    // End of tests
    #10 $finish;
end

endmodule
