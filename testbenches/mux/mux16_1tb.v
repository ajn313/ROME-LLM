`timescale 1ns / 1ps

module testbench;

// Testbench signals
reg [3:0] sel;
reg [15:0] in;
wire out;

// Instantiate the mux16_1 module
mux16_1 uut (
    .sel(sel),
    .in(in),
    .out(out)
);

// Test procedure
initial begin
    // Initialize inputs
    sel = 0;
    in = 16'b1100_1010_1111_0001; // Example input pattern

    // Run test cases for each select signal
    #10 sel = 4'b0000; // Test 0
    #10 if (out == in[0]) $display("Test 0 passed");
    
    #10 sel = 4'b0001; // Test 1
    #10 if (out == in[1]) $display("Test 1 passed");

    #10 sel = 4'b0010; // Test 2
    #10 if (out == in[2]) $display("Test 2 passed");

    #10 sel = 4'b0011; // Test 3
    #10 if (out == in[3]) $display("Test 3 passed");

    #10 sel = 4'b0100; // Test 4
    #10 if (out == in[4]) $display("Test 4 passed");

    #10 sel = 4'b0101; // Test 5
    #10 if (out == in[5]) $display("Test 5 passed");

    #10 sel = 4'b0110; // Test 6
    #10 if (out == in[6]) $display("Test 6 passed");

    #10 sel = 4'b0111; // Test 7
    #10 if (out == in[7]) $display("Test 7 passed");

    #10 sel = 4'b1000; // Test 8
    #10 if (out == in[8]) $display("Test 8 passed");

    #10 sel = 4'b1001; // Test 9
    #10 if (out == in[9]) $display("Test 9 passed");

    #10 sel = 4'b1010; // Test 10
    #10 if (out == in[10]) $display("Test 10 passed");

    #10 sel = 4'b1011; // Test 11
    #10 if (out == in[11]) $display("Test 11 passed");

    #10 sel = 4'b1100; // Test 12
    #10 if (out == in[12]) $display("Test 12 passed");

    #10 sel = 4'b1101; // Test 13
    #10 if (out == in[13]) $display("Test 13 passed");

    #10 sel = 4'b1110; // Test 14
    #10 if (out == in[14]) $display("Test 14 passed");

    #10 sel = 4'b1111; // Test 15
    #10 if (out == in[15]) $display("Test 15 passed!");

    // End of tests
    #10 $finish;
end

endmodule

