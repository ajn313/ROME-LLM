`timescale 1ns / 1ps

module alu_control_unit_tb;

    reg  [1:0] alu_op;
    reg  [2:0] funct;
    wire [2:0] alu_ctrl;

    reg all_passed;
    reg [2:0] expected;

    ALU_Control_Unit uut (
        .alu_op(alu_op),
        .funct(funct),
        .alu_ctrl(alu_ctrl)
    );

    initial begin
        all_passed = 1'b1;

        // Test 1: alu_op = 00 should force ADD
        alu_op   = 2'b00;
        funct    = 3'b101;
        expected = 3'b000;
        #5;
        if (alu_ctrl === expected)
            $display("Test 1 passed");
        else begin
            $display("Test 1 failed");
            $display("  alu_op = %b, funct = %b, Expected = %b, Got = %b", alu_op, funct, expected, alu_ctrl);
            all_passed = 1'b0;
        end

        // Test 2: alu_op = 01 should force SUB
        alu_op   = 2'b01;
        funct    = 3'b000;
        expected = 3'b001;
        #5;
        if (alu_ctrl === expected)
            $display("Test 2 passed");
        else begin
            $display("Test 2 failed");
            $display("  alu_op = %b, funct = %b, Expected = %b, Got = %b", alu_op, funct, expected, alu_ctrl);
            all_passed = 1'b0;
        end

        // Test 3: R-type ADD
        alu_op   = 2'b10;
        funct    = 3'b000;
        expected = 3'b000;
        #5;
        if (alu_ctrl === expected)
            $display("Test 3 passed");
        else begin
            $display("Test 3 failed");
            $display("  alu_op = %b, funct = %b, Expected = %b, Got = %b", alu_op, funct, expected, alu_ctrl);
            all_passed = 1'b0;
        end

        // Test 4: R-type SUB
        alu_op   = 2'b10;
        funct    = 3'b001;
        expected = 3'b001;
        #5;
        if (alu_ctrl === expected)
            $display("Test 4 passed");
        else begin
            $display("Test 4 failed");
            $display("  alu_op = %b, funct = %b, Expected = %b, Got = %b", alu_op, funct, expected, alu_ctrl);
            all_passed = 1'b0;
        end

        // Test 5: R-type AND
        alu_op   = 2'b10;
        funct    = 3'b010;
        expected = 3'b010;
        #5;
        if (alu_ctrl === expected)
            $display("Test 5 passed");
        else begin
            $display("Test 5 failed");
            $display("  alu_op = %b, funct = %b, Expected = %b, Got = %b", alu_op, funct, expected, alu_ctrl);
            all_passed = 1'b0;
        end

        // Test 6: R-type OR
        alu_op   = 2'b10;
        funct    = 3'b011;
        expected = 3'b011;
        #5;
        if (alu_ctrl === expected)
            $display("Test 6 passed");
        else begin
            $display("Test 6 failed");
            $display("  alu_op = %b, funct = %b, Expected = %b, Got = %b", alu_op, funct, expected, alu_ctrl);
            all_passed = 1'b0;
        end

        // Test 7: R-type SLT
        alu_op   = 2'b10;
        funct    = 3'b100;
        expected = 3'b100;
        #5;
        if (alu_ctrl === expected)
            $display("Test 7 passed");
        else begin
            $display("Test 7 failed");
            $display("  alu_op = %b, funct = %b, Expected = %b, Got = %b", alu_op, funct, expected, alu_ctrl);
            all_passed = 1'b0;
        end

        // Test 8: R-type XOR
        alu_op   = 2'b10;
        funct    = 3'b101;
        expected = 3'b101;
        #5;
        if (alu_ctrl === expected)
            $display("Test 8 passed");
        else begin
            $display("Test 8 failed");
            $display("  alu_op = %b, funct = %b, Expected = %b, Got = %b", alu_op, funct, expected, alu_ctrl);
            all_passed = 1'b0;
        end

        // Test 9: R-type NOR
        alu_op   = 2'b10;
        funct    = 3'b110;
        expected = 3'b110;
        #5;
        if (alu_ctrl === expected)
            $display("Test 9 passed");
        else begin
            $display("Test 9 failed");
            $display("  alu_op = %b, funct = %b, Expected = %b, Got = %b", alu_op, funct, expected, alu_ctrl);
            all_passed = 1'b0;
        end

        // Test 10: R-type unknown/default funct
        alu_op   = 2'b10;
        funct    = 3'b111;
        expected = 3'b111;
        #5;
        if (alu_ctrl === expected)
            $display("Test 10 passed");
        else begin
            $display("Test 10 failed");
            $display("  alu_op = %b, funct = %b, Expected = %b, Got = %b", alu_op, funct, expected, alu_ctrl);
            all_passed = 1'b0;
        end

        // Test 11: Invalid alu_op default behavior
        alu_op   = 2'b11;
        funct    = 3'b000;
        expected = 3'b111;
        #5;
        if (alu_ctrl === expected)
            $display("Test 11 passed");
        else begin
            $display("Test 11 failed");
            $display("  alu_op = %b, funct = %b, Expected = %b, Got = %b", alu_op, funct, expected, alu_ctrl);
            all_passed = 1'b0;
        end

        if (all_passed)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule