`timescale 1ns / 1ps

module sign_extend_tb;

    reg  [6:0] imm_in;
    wire [15:0] imm_out;

    reg all_passed;
    reg [15:0] expected;

    Sign_Extend uut (
        .imm_in(imm_in),
        .imm_out(imm_out)
    );

    initial begin
        all_passed = 1'b1;

        // Test 1: Zero
        imm_in   = 7'b0000000;
        expected = 16'h0000;
        #5;
        if (imm_out === expected)
            $display("Test 1 passed");
        else begin
            $display("Test 1 failed");
            $display("  imm_in = %b, Expected = %h, Got = %h", imm_in, expected, imm_out);
            all_passed = 1'b0;
        end

        // Test 2: Small positive value
        imm_in   = 7'b0000101;
        expected = 16'h0005;
        #5;
        if (imm_out === expected)
            $display("Test 2 passed");
        else begin
            $display("Test 2 failed");
            $display("  imm_in = %b, Expected = %h, Got = %h", imm_in, expected, imm_out);
            all_passed = 1'b0;
        end

        // Test 3: Largest positive 7-bit signed value (+63)
        imm_in   = 7'b0111111;
        expected = 16'h003F;
        #5;
        if (imm_out === expected)
            $display("Test 3 passed");
        else begin
            $display("Test 3 failed");
            $display("  imm_in = %b, Expected = %h, Got = %h", imm_in, expected, imm_out);
            all_passed = 1'b0;
        end

        // Test 4: Most negative 7-bit signed value (-64)
        imm_in   = 7'b1000000;
        expected = 16'hFFC0;
        #5;
        if (imm_out === expected)
            $display("Test 4 passed");
        else begin
            $display("Test 4 failed");
            $display("  imm_in = %b, Expected = %h, Got = %h", imm_in, expected, imm_out);
            all_passed = 1'b0;
        end

        // Test 5: -1
        imm_in   = 7'b1111111;
        expected = 16'hFFFF;
        #5;
        if (imm_out === expected)
            $display("Test 5 passed");
        else begin
            $display("Test 5 failed");
            $display("  imm_in = %b, Expected = %h, Got = %h", imm_in, expected, imm_out);
            all_passed = 1'b0;
        end

        // Test 6: Another negative value
        imm_in   = 7'b1010101;
        expected = 16'hFFD5;
        #5;
        if (imm_out === expected)
            $display("Test 6 passed");
        else begin
            $display("Test 6 failed");
            $display("  imm_in = %b, Expected = %h, Got = %h", imm_in, expected, imm_out);
            all_passed = 1'b0;
        end

        // Test 7: Another positive value
        imm_in   = 7'b0011010;
        expected = 16'h001A;
        #5;
        if (imm_out === expected)
            $display("Test 7 passed");
        else begin
            $display("Test 7 failed");
            $display("  imm_in = %b, Expected = %h, Got = %h", imm_in, expected, imm_out);
            all_passed = 1'b0;
        end

        if (all_passed)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule