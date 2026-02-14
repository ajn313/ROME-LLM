module tb_decoder_2_to_4;

    // Declare inputs and outputs
    reg [1:0] in;
    wire [3:0] out;

    // Instantiate the decoder
    decoder_2_to_4 uut (
        .in(in),
        .out(out)
    );

    // Initial block for test cases
    initial begin
        // Test 0
        in = 2'b00; #10;
        if (out == 4'b0001) $display("Test 0 passed");
        else $display("Test 0 failed!");

        // Test 1
        in = 2'b01; #10;
        if (out == 4'b0010) $display("Test 1 passed");
        else $display("Test 1 failed!");

        // Test 2
        in = 2'b10; #10;
        if (out == 4'b0100) $display("Test 2 passed");
        else $display("Test 2 failed!");

        // Test 3
        in = 2'b11; #10;
        if (out == 4'b1000) $display("Test 3 passed!");
        else $display("Test 3 failed!");

        // End simulation
        $stop;
    end

endmodule
