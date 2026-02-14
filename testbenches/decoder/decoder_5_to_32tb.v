module tb_decoder_5_to_32;

    // Declare inputs and outputs
    reg [4:0] in;
    wire [31:0] out;

    // Instantiate the decoder
    decoder_5_to_32 uut (
        .in(in),
        .out(out)
    );

    // Initial block for test cases
    initial begin
        // Test 0
        in = 5'b00000; #10;
        if (out == 32'b00000000000000000000000000000001) $display("Test 0 passed!");
        else $display("Test 0 failed!");

        // Test 1
        in = 5'b00001; #10;
        if (out == 32'b00000000000000000000000000000010) $display("Test 1 passed!");
        else $display("Test 1 failed!");

        // Test 2
        in = 5'b00010; #10;
        if (out == 32'b00000000000000000000000000000100) $display("Test 2 passed!");
        else $display("Test 2 failed!");

        // Test 3
        in = 5'b00011; #10;
        if (out == 32'b00000000000000000000000000001000) $display("Test 3 passed!");
        else $display("Test 3 failed!");

        // Test 4
        in = 5'b00100; #10;
        if (out == 32'b00000000000000000000000000010000) $display("Test 4 passed!");
        else $display("Test 4 failed!");

        // Test 5
        in = 5'b00101; #10;
        if (out == 32'b00000000000000000000000000100000) $display("Test 5 passed!");
        else $display("Test 5 failed!");

        // Test 6
        in = 5'b00110; #10;
        if (out == 32'b00000000000000000000000001000000) $display("Test 6 passed!");
        else $display("Test 6 failed!");

        // Test 7
        in = 5'b00111; #10;
        if (out == 32'b00000000000000000000000010000000) $display("Test 7 passed!");
        else $display("Test 7 failed!");

        // Test 8
        in = 5'b01000; #10;
        if (out == 32'b00000000000000000000000100000000) $display("Test 8 passed!");
        else $display("Test 8 failed!");

        // Test 9
        in = 5'b01001; #10;
        if (out == 32'b00000000000000000000001000000000) $display("Test 9 passed!");
        else $display("Test 9 failed!");

        // Test 10
        in = 5'b01010; #10;
        if (out == 32'b00000000000000000000010000000000) $display("Test 10 passed!");
        else $display("Test 10 failed!");

        // Test 11
        in = 5'b01011; #10;
        if (out == 32'b00000000000000000000100000000000) $display("Test 11 passed!");
        else $display("Test 11 failed!");

        // Test 12
        in = 5'b01100; #10;
        if (out == 32'b00000000000000000001000000000000) $display("Test 12 passed!");
        else $display("Test 12 failed!");

        // Test 13
        in = 5'b01101; #10;
        if (out == 32'b00000000000000000010000000000000) $display("Test 13 passed!");
        else $display("Test 13 failed!");

        // Test 14
        in = 5'b01110; #10;
        if (out == 32'b00000000000000000100000000000000) $display("Test 14 passed!");
        else $display("Test 14 failed!");

        // Test 15
        in = 5'b01111; #10;
        if (out == 32'b00000000000000001000000000000000) $display("Test 15 passed!");
        else $display("Test 15 failed!");

        // Test 16
        in = 5'b10000; #10;
        if (out == 32'b00000000000000010000000000000000) $display("Test 16 passed!");
        else $display("Test 16 failed!");

        // Test 17
        in = 5'b10001; #10;
        if (out == 32'b00000000000000100000000000000000) $display("Test 17 passed!");
        else $display("Test 17 failed!");

        // Test 18
        in = 5'b10010; #10;
        if (out == 32'b00000000000001000000000000000000) $display("Test 18 passed!");
        else $display("Test 18 failed!");

        // Test 19
        in = 5'b10011; #10;
        if (out == 32'b00000000000010000000000000000000) $display("Test 19 passed!");
        else $display("Test 19 failed!");

        // Test 20
        in = 5'b10100; #10;
        if (out == 32'b00000000000100000000000000000000) $display("Test 20 passed!");
        else $display("Test 20 failed!");

        // Test 21
        in = 5'b10101; #10;
        if (out == 32'b00000000001000000000000000000000) $display("Test 21 passed!");
        else $display("Test 21 failed!");

        // Test 22
        in = 5'b10110; #10;
        if (out == 32'b00000000010000000000000000000000) $display("Test 22 passed!");
        else $display("Test 22 failed!");

        // Test 23
        in = 5'b10111; #10;
        if (out == 32'b00000000100000000000000000000000) $display("Test 23 passed!");
        else $display("Test 23 failed!");

        // Test 24
        in = 5'b11000; #10;
        if (out == 32'b00000001000000000000000000000000) $display("Test 24 passed!");
        else $display("Test 24 failed!");

        // Test 25
        in = 5'b11001; #10;
        if (out == 32'b00000010000000000000000000000000) $display("Test 25 passed!");
        else $display("Test 25 failed!");

        // Test 26
        in = 5'b11010; #10;
        if (out == 32'b00000100000000000000000000000000) $display("Test 26 passed!");
        else $display("Test 26 failed!");

        // Test 27
        in = 5'b11011; #10;
        if (out == 32'b00001000000000000000000000000000) $display("Test 27 passed!");
        else $display("Test 27 failed!");

        // Test 28
        in = 5'b11100; #10;
        if (out == 32'b00010000000000000000000000000000) $display("Test 28 passed!");
        else $display("Test 28 failed!");

        // Test 29
        in = 5'b11101; #10;
        if (out == 32'b00100000000000000000000000000000) $display("Test 29 passed!");
        else $display("Test 29 failed!");

        // Test 30
        in = 5'b11110; #10;
        if (out == 32'b01000000000000000000000000000000) $display("Test 30 passed!");
        else $display("Test 30 failed!");

        // Test 31
        in = 5'b11111; #10;
        if (out == 32'b10000000000000000000000000000000) $display("Test 31 passed!");
        else $display("Test 31 failed!");

        // End simulation
        $stop;
    end

endmodule
