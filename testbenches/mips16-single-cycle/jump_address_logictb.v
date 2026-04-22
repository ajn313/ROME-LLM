`timescale 1ns / 1ps

module jump_address_logic_tb;

    reg  [15:0] pc_plus_1;
    reg  [11:0] jump_addr;
    wire [15:0] jump_target;

    reg all_passed;
    reg [15:0] expected;

    Jump_Address_Logic uut (
        .pc_plus_1(pc_plus_1),
        .jump_addr(jump_addr),
        .jump_target(jump_target)
    );

    initial begin
        all_passed = 1'b1;

        // Test 1: All zeros
        pc_plus_1 = 16'h0000;
        jump_addr = 12'h000;
        expected  = 16'h0000;
        #5;
        if (jump_target === expected)
            $display("Test 1 passed");
        else begin
            $display("Test 1 failed");
            $display("  pc_plus_1 = %h, jump_addr = %h, Expected = %h, Got = %h",
                     pc_plus_1, jump_addr, expected, jump_target);
            all_passed = 1'b0;
        end

        // Test 2: Nonzero upper PC bits, zero jump address
        pc_plus_1 = 16'hA123;
        jump_addr = 12'h000;
        expected  = 16'hA000;
        #5;
        if (jump_target === expected)
            $display("Test 2 passed");
        else begin
            $display("Test 2 failed");
            $display("  pc_plus_1 = %h, jump_addr = %h, Expected = %h, Got = %h",
                     pc_plus_1, jump_addr, expected, jump_target);
            all_passed = 1'b0;
        end

        // Test 3: Zero upper PC bits, nonzero jump address
        pc_plus_1 = 16'h0123;
        jump_addr = 12'hABC;
        expected  = 16'h0ABC;
        #5;
        if (jump_target === expected)
            $display("Test 3 passed");
        else begin
            $display("Test 3 failed");
            $display("  pc_plus_1 = %h, jump_addr = %h, Expected = %h, Got = %h",
                     pc_plus_1, jump_addr, expected, jump_target);
            all_passed = 1'b0;
        end

        // Test 4: Mixed values
        pc_plus_1 = 16'h3456;
        jump_addr = 12'h789;
        expected  = 16'h3789;
        #5;
        if (jump_target === expected)
            $display("Test 4 passed");
        else begin
            $display("Test 4 failed");
            $display("  pc_plus_1 = %h, jump_addr = %h, Expected = %h, Got = %h",
                     pc_plus_1, jump_addr, expected, jump_target);
            all_passed = 1'b0;
        end

        // Test 5: All ones jump field
        pc_plus_1 = 16'h4FED;
        jump_addr = 12'hFFF;
        expected  = 16'h4FFF;
        #5;
        if (jump_target === expected)
            $display("Test 5 passed");
        else begin
            $display("Test 5 failed");
            $display("  pc_plus_1 = %h, jump_addr = %h, Expected = %h, Got = %h",
                     pc_plus_1, jump_addr, expected, jump_target);
            all_passed = 1'b0;
        end

        // Test 6: Verify only top nibble of pc_plus_1 is used
        pc_plus_1 = 16'h9AAA;
        jump_addr = 12'h123;
        expected  = 16'h9123;
        #5;
        if (jump_target === expected)
            $display("Test 6 passed");
        else begin
            $display("Test 6 failed");
            $display("  pc_plus_1 = %h, jump_addr = %h, Expected = %h, Got = %h",
                     pc_plus_1, jump_addr, expected, jump_target);
            all_passed = 1'b0;
        end

        // Test 7: Another mixed case
        pc_plus_1 = 16'hF001;
        jump_addr = 12'h00A;
        expected  = 16'hF00A;
        #5;
        if (jump_target === expected)
            $display("Test 7 passed");
        else begin
            $display("Test 7 failed");
            $display("  pc_plus_1 = %h, jump_addr = %h, Expected = %h, Got = %h",
                     pc_plus_1, jump_addr, expected, jump_target);
            all_passed = 1'b0;
        end

        if (all_passed)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule