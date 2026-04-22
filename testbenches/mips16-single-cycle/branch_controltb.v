`timescale 1ns / 1ps

module branch_control_tb;

    reg  branch;
    reg  zero;
    wire pc_src;

    reg all_passed;
    reg expected;

    Branch_Control uut (
        .branch(branch),
        .zero(zero),
        .pc_src(pc_src)
    );

    initial begin
        all_passed = 1'b1;

        // Test 1: branch=0, zero=0 -> pc_src=0
        branch   = 1'b0;
        zero     = 1'b0;
        expected = 1'b0;
        #5;
        if (pc_src === expected)
            $display("Test 1 passed");
        else begin
            $display("Test 1 failed");
            $display("  branch = %b, zero = %b, Expected = %b, Got = %b",
                     branch, zero, expected, pc_src);
            all_passed = 1'b0;
        end

        // Test 2: branch=0, zero=1 -> pc_src=0
        branch   = 1'b0;
        zero     = 1'b1;
        expected = 1'b0;
        #5;
        if (pc_src === expected)
            $display("Test 2 passed");
        else begin
            $display("Test 2 failed");
            $display("  branch = %b, zero = %b, Expected = %b, Got = %b",
                     branch, zero, expected, pc_src);
            all_passed = 1'b0;
        end

        // Test 3: branch=1, zero=0 -> pc_src=0
        branch   = 1'b1;
        zero     = 1'b0;
        expected = 1'b0;
        #5;
        if (pc_src === expected)
            $display("Test 3 passed");
        else begin
            $display("Test 3 failed");
            $display("  branch = %b, zero = %b, Expected = %b, Got = %b",
                     branch, zero, expected, pc_src);
            all_passed = 1'b0;
        end

        // Test 4: branch=1, zero=1 -> pc_src=1
        branch   = 1'b1;
        zero     = 1'b1;
        expected = 1'b1;
        #5;
        if (pc_src === expected)
            $display("Test 4 passed");
        else begin
            $display("Test 4 failed");
            $display("  branch = %b, zero = %b, Expected = %b, Got = %b",
                     branch, zero, expected, pc_src);
            all_passed = 1'b0;
        end

        // Test 5: Toggle zero low while branch stays high
        branch   = 1'b1;
        zero     = 1'b0;
        expected = 1'b0;
        #5;
        if (pc_src === expected)
            $display("Test 5 passed");
        else begin
            $display("Test 5 failed");
            $display("  branch = %b, zero = %b, Expected = %b, Got = %b",
                     branch, zero, expected, pc_src);
            all_passed = 1'b0;
        end

        // Test 6: Toggle branch low while zero stays high
        branch   = 1'b0;
        zero     = 1'b1;
        expected = 1'b0;
        #5;
        if (pc_src === expected)
            $display("Test 6 passed");
        else begin
            $display("Test 6 failed");
            $display("  branch = %b, zero = %b, Expected = %b, Got = %b",
                     branch, zero, expected, pc_src);
            all_passed = 1'b0;
        end

        if (all_passed)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule