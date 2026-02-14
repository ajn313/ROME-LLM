module tb_decoder_3_to_8;

    // Declare inputs and outputs
    reg [2:0] in;
    wire [7:0] out;

    // Instantiate the decoder
    decoder_3_to_8 uut (
        .in(in),
        .out(out)
    );

    // Initial block for test cases
    initial begin
        // Test 0
        in = 3'b000; #10;
        if (out == 8'b00000001) $display("Test 0 passed!");
        else $display("Test 0 failed!");

        // Test 1
        in = 3'b001; #10;
        if (out == 8'b00000010) $display("Test 1 passed!");
        else $display("Test 1 failed!");

        // Test 2
        in = 3'b010; #10;
        if (out == 8'b00000100) $display("Test 2 passed!");
        else $display("Test 2 failed!");

        // Test 3
        in = 3'b011; #10;
        if (out == 8'b00001000) $display("Test 3 passed!");
        else $display("Test 3 failed!");

        // Test 4
        in = 3'b100; #10;
        if (out == 8'b00010000) $display("Test 4 passed!");
        else $display("Test 4 failed!");

        // Test 5
        in = 3'b101; #10;
        if (out == 8'b00100000) $display("Test 5 passed!");
        else $display("Test 5 failed!");

        // Test 6
        in = 3'b110; #10;
        if (out == 8'b01000000) $display("Test 6 passed!");
        else $display("Test 6 failed!");

        // Test 7
        in = 3'b111; #10;
        if (out == 8'b10000000) $display("Test 7 passed!");
        else $display("Test 7 failed!");

        // End simulation
        $stop;
    end

endmodule
