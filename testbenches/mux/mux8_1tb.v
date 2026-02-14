`timescale 1ns / 1ps

module testbench;

// Testbench signals
reg [2:0] sel;
reg [7:0] in;
wire out;

// Instantiate the mux8_1 module
mux8_1 uut (
    .sel(sel),
    .in(in),
    .out(out)
);

// Test procedure
initial begin
    // Initialize inputs
    sel = 0;
    in = 8'b1100_1010; // Example input pattern

    // Test 0: sel = 000, expected output: in[0]
    #10 sel = 3'b000;
    #10 if (out == in[0]) $display("Test 0 passed");

    // Test 1: sel = 001, expected output: in[1]
    #10 sel = 3'b001;
    #10 if (out == in[1]) $display("Test 1 passed");

    // Test 2: sel = 010, expected output: in[2]
    #10 sel = 3'b010;
    #10 if (out == in[2]) $display("Test 2 passed");

    // Test 3: sel = 011, expected output: in[3]
    #10 sel = 3'b011;
    #10 if (out == in[3]) $display("Test 3 passed");

    // Test 4: sel = 100, expected output: in[4]
    #10 sel = 3'b100;
    #10 if (out == in[4]) $display("Test 4 passed");

    // Test 5: sel = 101, expected output: in[5]
    #10 sel = 3'b101;
    #10 if (out == in[5]) $display("Test 5 passed");

    // Test 6: sel = 110, expected output: in[6]
    #10 sel = 3'b110;
    #10 if (out == in[6]) $display("Test 6 passed");

    // Test 7: sel = 111, expected output: in[7]
    #10 sel = 3'b111;
    #10 if (out == in[7]) $display("Test 7 passed!");

    // End of tests
    #10 $finish;
end

endmodule

