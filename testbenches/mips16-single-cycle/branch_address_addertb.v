`timescale 1ns / 1ps

module branch_address_adder_tb;

    reg  [15:0] pc_plus_1;
    reg  [15:0] imm_ext;
    wire [15:0] branch_addr;

    reg all_passed;
    reg [15:0] expected;

    Branch_Address_Adder uut (
        .pc_plus_1(pc_plus_1),
        .imm_ext(imm_ext),
        .branch_addr(branch_addr)
    );

    initial begin
        all_passed = 1'b1;

        // Test 1: Zero offset
        pc_plus_1 = 16'h0001;
        imm_ext   = 16'h0000;
        expected  = 16'h0001;
        #5;
        if (branch_addr === expected)
            $display("Test 1 passed");
        else begin
            $display("Test 1 failed");
            $display("  pc_plus_1 = %h, imm_ext = %h, Expected = %h, Got = %h",
                     pc_plus_1, imm_ext, expected, branch_addr);
            all_passed = 1'b0;
        end

        // Test 2: Small positive offset
        pc_plus_1 = 16'h0010;
        imm_ext   = 16'h0004;
        expected  = 16'h0014;
        #5;
        if (branch_addr === expected)
            $display("Test 2 passed");
        else begin
            $display("Test 2 failed");
            $display("  pc_plus_1 = %h, imm_ext = %h, Expected = %h, Got = %h",
                     pc_plus_1, imm_ext, expected, branch_addr);
            all_passed = 1'b0;
        end

        // Test 3: Larger positive offset
        pc_plus_1 = 16'h0100;
        imm_ext   = 16'h0020;
        expected  = 16'h0120;
        #5;
        if (branch_addr === expected)
            $display("Test 3 passed");
        else begin
            $display("Test 3 failed");
            $display("  pc_plus_1 = %h, imm_ext = %h, Expected = %h, Got = %h",
                     pc_plus_1, imm_ext, expected, branch_addr);
            all_passed = 1'b0;
        end

        // Test 4: Negative offset (-1)
        pc_plus_1 = 16'h0020;
        imm_ext   = 16'hFFFF;
        expected  = 16'h001F;
        #5;
        if (branch_addr === expected)
            $display("Test 4 passed");
        else begin
            $display("Test 4 failed");
            $display("  pc_plus_1 = %h, imm_ext = %h, Expected = %h, Got = %h",
                     pc_plus_1, imm_ext, expected, branch_addr);
            all_passed = 1'b0;
        end

        // Test 5: Negative offset (-4)
        pc_plus_1 = 16'h0020;
        imm_ext   = 16'hFFFC;
        expected  = 16'h001C;
        #5;
        if (branch_addr === expected)
            $display("Test 5 passed");
        else begin
            $display("Test 5 failed");
            $display("  pc_plus_1 = %h, imm_ext = %h, Expected = %h, Got = %h",
                     pc_plus_1, imm_ext, expected, branch_addr);
            all_passed = 1'b0;
        end

        // Test 6: Wraparound near upper boundary
        pc_plus_1 = 16'hFFFE;
        imm_ext   = 16'h0002;
        expected  = 16'h0000;
        #5;
        if (branch_addr === expected)
            $display("Test 6 passed");
        else begin
            $display("Test 6 failed");
            $display("  pc_plus_1 = %h, imm_ext = %h, Expected = %h, Got = %h",
                     pc_plus_1, imm_ext, expected, branch_addr);
            all_passed = 1'b0;
        end

        // Test 7: Negative offset from low address
        pc_plus_1 = 16'h0003;
        imm_ext   = 16'hFFFE;
        expected  = 16'h0001;
        #5;
        if (branch_addr === expected)
            $display("Test 7 passed");
        else begin
            $display("Test 7 failed");
            $display("  pc_plus_1 = %h, imm_ext = %h, Expected = %h, Got = %h",
                     pc_plus_1, imm_ext, expected, branch_addr);
            all_passed = 1'b0;
        end

        if (all_passed)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule