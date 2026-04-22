`timescale 1ns / 1ps

module next_pc_logic_tb;

    reg  [15:0] pc_plus_1;
    reg  [15:0] branch_addr;
    reg  [15:0] jump_target;
    reg         pc_src;
    reg         jump;
    wire [15:0] pc_next;

    reg all_passed;
    reg [15:0] expected;

    Next_PC_Logic uut (
        .pc_plus_1(pc_plus_1),
        .branch_addr(branch_addr),
        .jump_target(jump_target),
        .pc_src(pc_src),
        .jump(jump),
        .pc_next(pc_next)
    );

    initial begin
        all_passed = 1'b1;

        // Test 1: Normal sequential execution
        pc_plus_1   = 16'h0001;
        branch_addr = 16'h0010;
        jump_target = 16'h00F0;
        pc_src      = 1'b0;
        jump        = 1'b0;
        expected    = 16'h0001;
        #5;
        if (pc_next === expected)
            $display("Test 1 passed");
        else begin
            $display("Test 1 failed");
            $display("  Expected pc_next = %h, Got = %h", expected, pc_next);
            all_passed = 1'b0;
        end

        // Test 2: Branch taken
        pc_plus_1   = 16'h0002;
        branch_addr = 16'h0020;
        jump_target = 16'h00F1;
        pc_src      = 1'b1;
        jump        = 1'b0;
        expected    = 16'h0020;
        #5;
        if (pc_next === expected)
            $display("Test 2 passed");
        else begin
            $display("Test 2 failed");
            $display("  Expected pc_next = %h, Got = %h", expected, pc_next);
            all_passed = 1'b0;
        end

        // Test 3: Jump taken
        pc_plus_1   = 16'h0003;
        branch_addr = 16'h0030;
        jump_target = 16'h0A00;
        pc_src      = 1'b0;
        jump        = 1'b1;
        expected    = 16'h0A00;
        #5;
        if (pc_next === expected)
            $display("Test 3 passed");
        else begin
            $display("Test 3 failed");
            $display("  Expected pc_next = %h, Got = %h", expected, pc_next);
            all_passed = 1'b0;
        end

        // Test 4: Jump has priority over branch
        pc_plus_1   = 16'h0004;
        branch_addr = 16'h0040;
        jump_target = 16'h0B00;
        pc_src      = 1'b1;
        jump        = 1'b1;
        expected    = 16'h0B00;
        #5;
        if (pc_next === expected)
            $display("Test 4 passed");
        else begin
            $display("Test 4 failed");
            $display("  Expected pc_next = %h, Got = %h", expected, pc_next);
            all_passed = 1'b0;
        end

        // Test 5: Different sequential value
        pc_plus_1   = 16'h1235;
        branch_addr = 16'h2222;
        jump_target = 16'h3333;
        pc_src      = 1'b0;
        jump        = 1'b0;
        expected    = 16'h1235;
        #5;
        if (pc_next === expected)
            $display("Test 5 passed");
        else begin
            $display("Test 5 failed");
            $display("  Expected pc_next = %h, Got = %h", expected, pc_next);
            all_passed = 1'b0;
        end

        // Test 6: Different branch value
        pc_plus_1   = 16'h1236;
        branch_addr = 16'h3456;
        jump_target = 16'h4444;
        pc_src      = 1'b1;
        jump        = 1'b0;
        expected    = 16'h3456;
        #5;
        if (pc_next === expected)
            $display("Test 6 passed");
        else begin
            $display("Test 6 failed");
            $display("  Expected pc_next = %h, Got = %h", expected, pc_next);
            all_passed = 1'b0;
        end

        // Test 7: Different jump value
        pc_plus_1   = 16'h1237;
        branch_addr = 16'h4567;
        jump_target = 16'h5678;
        pc_src      = 1'b0;
        jump        = 1'b1;
        expected    = 16'h5678;
        #5;
        if (pc_next === expected)
            $display("Test 7 passed");
        else begin
            $display("Test 7 failed");
            $display("  Expected pc_next = %h, Got = %h", expected, pc_next);
            all_passed = 1'b0;
        end

        // Test 8: All-zero inputs
        pc_plus_1   = 16'h0000;
        branch_addr = 16'h0000;
        jump_target = 16'h0000;
        pc_src      = 1'b0;
        jump        = 1'b0;
        expected    = 16'h0000;
        #5;
        if (pc_next === expected)
            $display("Test 8 passed");
        else begin
            $display("Test 8 failed");
            $display("  Expected pc_next = %h, Got = %h", expected, pc_next);
            all_passed = 1'b0;
        end

        if (all_passed)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule