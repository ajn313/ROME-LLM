`timescale 1ns / 1ps

module alu_tb;

    reg  [15:0] a;
    reg  [15:0] b;
    reg  [2:0]  alu_ctrl;
    wire [15:0] result;
    wire        zero;

    reg all_passed;
    reg [15:0] expected_result;
    reg        expected_zero;

    ALU uut (
        .a(a),
        .b(b),
        .alu_ctrl(alu_ctrl),
        .result(result),
        .zero(zero)
    );

    initial begin
        all_passed = 1'b1;

        // Test 1: ADD
        a = 16'h0003;
        b = 16'h0004;
        alu_ctrl = 3'b000;
        expected_result = 16'h0007;
        expected_zero   = 1'b0;
        #5;
        if ((result === expected_result) && (zero === expected_zero))
            $display("Test 1 passed");
        else begin
            $display("Test 1 failed");
            $display("  ADD: a=%h b=%h expected_result=%h got_result=%h expected_zero=%b got_zero=%b",
                     a, b, expected_result, result, expected_zero, zero);
            all_passed = 1'b0;
        end

        // Test 2: ADD with wraparound
        a = 16'hFFFF;
        b = 16'h0001;
        alu_ctrl = 3'b000;
        expected_result = 16'h0000;
        expected_zero   = 1'b1;
        #5;
        if ((result === expected_result) && (zero === expected_zero))
            $display("Test 2 passed");
        else begin
            $display("Test 2 failed");
            $display("  ADD wrap: a=%h b=%h expected_result=%h got_result=%h expected_zero=%b got_zero=%b",
                     a, b, expected_result, result, expected_zero, zero);
            all_passed = 1'b0;
        end

        // Test 3: SUB nonzero result
        a = 16'h0009;
        b = 16'h0004;
        alu_ctrl = 3'b001;
        expected_result = 16'h0005;
        expected_zero   = 1'b0;
        #5;
        if ((result === expected_result) && (zero === expected_zero))
            $display("Test 3 passed");
        else begin
            $display("Test 3 failed");
            $display("  SUB: a=%h b=%h expected_result=%h got_result=%h expected_zero=%b got_zero=%b",
                     a, b, expected_result, result, expected_zero, zero);
            all_passed = 1'b0;
        end

        // Test 4: SUB zero result
        a = 16'h00AA;
        b = 16'h00AA;
        alu_ctrl = 3'b001;
        expected_result = 16'h0000;
        expected_zero   = 1'b1;
        #5;
        if ((result === expected_result) && (zero === expected_zero))
            $display("Test 4 passed");
        else begin
            $display("Test 4 failed");
            $display("  SUB zero: a=%h b=%h expected_result=%h got_result=%h expected_zero=%b got_zero=%b",
                     a, b, expected_result, result, expected_zero, zero);
            all_passed = 1'b0;
        end

        // Test 5: AND
        a = 16'hA5A5;
        b = 16'h0FF0;
        alu_ctrl = 3'b010;
        expected_result = 16'h05A0;
        expected_zero   = 1'b0;
        #5;
        if ((result === expected_result) && (zero === expected_zero))
            $display("Test 5 passed");
        else begin
            $display("Test 5 failed");
            $display("  AND: a=%h b=%h expected_result=%h got_result=%h expected_zero=%b got_zero=%b",
                     a, b, expected_result, result, expected_zero, zero);
            all_passed = 1'b0;
        end

        // Test 6: OR
        a = 16'hA5A5;
        b = 16'h0FF0;
        alu_ctrl = 3'b011;
        expected_result = 16'hAFF5;
        expected_zero   = 1'b0;
        #5;
        if ((result === expected_result) && (zero === expected_zero))
            $display("Test 6 passed");
        else begin
            $display("Test 6 failed");
            $display("  OR: a=%h b=%h expected_result=%h got_result=%h expected_zero=%b got_zero=%b",
                     a, b, expected_result, result, expected_zero, zero);
            all_passed = 1'b0;
        end

        // Test 7: SLT true (signed)
        a = 16'hFFFE; // -2
        b = 16'h0001; //  1
        alu_ctrl = 3'b100;
        expected_result = 16'h0001;
        expected_zero   = 1'b0;
        #5;
        if ((result === expected_result) && (zero === expected_zero))
            $display("Test 7 passed");
        else begin
            $display("Test 7 failed");
            $display("  SLT true: a=%h b=%h expected_result=%h got_result=%h expected_zero=%b got_zero=%b",
                     a, b, expected_result, result, expected_zero, zero);
            all_passed = 1'b0;
        end

        // Test 8: SLT false (signed)
        a = 16'h0003;
        b = 16'hFFFD; // -3
        alu_ctrl = 3'b100;
        expected_result = 16'h0000;
        expected_zero   = 1'b1;
        #5;
        if ((result === expected_result) && (zero === expected_zero))
            $display("Test 8 passed");
        else begin
            $display("Test 8 failed");
            $display("  SLT false: a=%h b=%h expected_result=%h got_result=%h expected_zero=%b got_zero=%b",
                     a, b, expected_result, result, expected_zero, zero);
            all_passed = 1'b0;
        end

        // Test 9: XOR
        a = 16'hAAAA;
        b = 16'h0F0F;
        alu_ctrl = 3'b101;
        expected_result = 16'hA5A5;
        expected_zero   = 1'b0;
        #5;
        if ((result === expected_result) && (zero === expected_zero))
            $display("Test 9 passed");
        else begin
            $display("Test 9 failed");
            $display("  XOR: a=%h b=%h expected_result=%h got_result=%h expected_zero=%b got_zero=%b",
                     a, b, expected_result, result, expected_zero, zero);
            all_passed = 1'b0;
        end

        // Test 10: NOR
        a = 16'h00FF;
        b = 16'h0F0F;
        alu_ctrl = 3'b110;
        expected_result = 16'hF000;
        expected_zero   = 1'b0;
        #5;
        if ((result === expected_result) && (zero === expected_zero))
            $display("Test 10 passed");
        else begin
            $display("Test 10 failed");
            $display("  NOR: a=%h b=%h expected_result=%h got_result=%h expected_zero=%b got_zero=%b",
                     a, b, expected_result, result, expected_zero, zero);
            all_passed = 1'b0;
        end

        if (all_passed)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule