`timescale 1ns / 1ps

module testbench;

// Testbench signals
reg [1:0] sel;
reg [3:0] in;
wire out;

// Instantiate the mux4_1 module
mux4_1 uut (
    .sel(sel),
    .in(in),
    .out(out)
);

// Test procedure
initial begin
    // Initialize inputs
    sel = 0;
    in = 4'b1010; // Example input pattern

    // Test 0: sel = 00, expected output: in[0]
    #10 sel = 2'b00;
    #10 if (out == in[0]) $display("Test 0 passed");

    // Test 1: sel = 01, expected output: in[1]
    #10 sel = 2'b01;
    #10 if (out == in[1]) $display("Test 1 passed");

    // Test 2: sel = 10, expected output: in[2]
    #10 sel = 2'b10;
    #10 if (out == in[2]) $display("Test 2 passed");

    // Test 3: sel = 11, expected output: in[3]
    #10 sel = 2'b11;
    #10 if (out == in[3]) $display("Test 3 passed!");

    // End of tests
    #10 $finish;
end

endmodule

