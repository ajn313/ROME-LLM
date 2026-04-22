`timescale 1ns / 1ps

module pc_adder_tb;

    reg  [15:0] pc_current;
    wire [15:0] pc_plus_1;

    reg all_passed;
    reg [15:0] expected;

    PC_Adder uut (
        .pc_current(pc_current),
        .pc_plus_1(pc_plus_1)
    );

    initial begin
        all_passed = 1'b1;

        // Test 1: Zero input
        pc_current = 16'h0000;
        expected   = 16'h0001;
        #5;
        if (pc_plus_1 === expected)
            $display("Test 1 passed");
        else begin
            $display("Test 1 failed");
            $display("  pc_current = %h, Expected = %h, Got = %h", pc_current, expected, pc_plus_1);
            all_passed = 1'b0;
        end

        // Test 2: Small positive value
        pc_current = 16'h0001;
        expected   = 16'h0002;
        #5;
        if (pc_plus_1 === expected)
            $display("Test 2 passed");
        else begin
            $display("Test 2 failed");
            $display("  pc_current = %h, Expected = %h, Got = %h", pc_current, expected, pc_plus_1);
            all_passed = 1'b0;
        end

        // Test 3: Mid-range value
        pc_current = 16'h0010;
        expected   = 16'h0011;
        #5;
        if (pc_plus_1 === expected)
            $display("Test 3 passed");
        else begin
            $display("Test 3 failed");
            $display("  pc_current = %h, Expected = %h, Got = %h", pc_current, expected, pc_plus_1);
            all_passed = 1'b0;
        end

        // Test 4: Larger value
        pc_current = 16'h00FF;
        expected   = 16'h0100;
        #5;
        if (pc_plus_1 === expected)
            $display("Test 4 passed");
        else begin
            $display("Test 4 failed");
            $display("  pc_current = %h, Expected = %h, Got = %h", pc_current, expected, pc_plus_1);
            all_passed = 1'b0;
        end

        // Test 5: Near upper limit
        pc_current = 16'hFFFE;
        expected   = 16'hFFFF;
        #5;
        if (pc_plus_1 === expected)
            $display("Test 5 passed");
        else begin
            $display("Test 5 failed");
            $display("  pc_current = %h, Expected = %h, Got = %h", pc_current, expected, pc_plus_1);
            all_passed = 1'b0;
        end

        // Test 6: Overflow wraparound
        pc_current = 16'hFFFF;
        expected   = 16'h0000;
        #5;
        if (pc_plus_1 === expected)
            $display("Test 6 passed");
        else begin
            $display("Test 6 failed");
            $display("  pc_current = %h, Expected = %h, Got = %h", pc_current, expected, pc_plus_1);
            all_passed = 1'b0;
        end

        if (all_passed)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule