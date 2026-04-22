`timescale 1ns / 1ps

module mux2_1_3bit_tb;

    reg  [2:0] in0;
    reg  [2:0] in1;
    reg        sel;
    wire [2:0] out;

    reg all_passed;
    reg [2:0] expected;

    mux2_1_3bit uut (
        .in0(in0),
        .in1(in1),
        .sel(sel),
        .out(out)
    );

    initial begin
        all_passed = 1'b1;

        // Test 1: sel=0 selects in0
        in0      = 3'b000;
        in1      = 3'b111;
        sel      = 1'b0;
        expected = 3'b000;
        #5;
        if (out === expected)
            $display("Test 1 passed");
        else begin
            $display("Test 1 failed");
            $display("  sel=%b in0=%b in1=%b Expected=%b Got=%b",
                     sel, in0, in1, expected, out);
            all_passed = 1'b0;
        end

        // Test 2: sel=1 selects in1
        in0      = 3'b000;
        in1      = 3'b111;
        sel      = 1'b1;
        expected = 3'b111;
        #5;
        if (out === expected)
            $display("Test 2 passed");
        else begin
            $display("Test 2 failed");
            $display("  sel=%b in0=%b in1=%b Expected=%b Got=%b",
                     sel, in0, in1, expected, out);
            all_passed = 1'b0;
        end

        // Test 3: Mixed values, select in0
        in0      = 3'b101;
        in1      = 3'b010;
        sel      = 1'b0;
        expected = 3'b101;
        #5;
        if (out === expected)
            $display("Test 3 passed");
        else begin
            $display("Test 3 failed");
            $display("  sel=%b in0=%b in1=%b Expected=%b Got=%b",
                     sel, in0, in1, expected, out);
            all_passed = 1'b0;
        end

        // Test 4: Mixed values, select in1
        in0      = 3'b101;
        in1      = 3'b010;
        sel      = 1'b1;
        expected = 3'b010;
        #5;
        if (out === expected)
            $display("Test 4 passed");
        else begin
            $display("Test 4 failed");
            $display("  sel=%b in0=%b in1=%b Expected=%b Got=%b",
                     sel, in0, in1, expected, out);
            all_passed = 1'b0;
        end

        // Test 5: Both inputs same
        in0      = 3'b011;
        in1      = 3'b011;
        sel      = 1'b0;
        expected = 3'b011;
        #5;
        if (out === expected)
            $display("Test 5 passed");
        else begin
            $display("Test 5 failed");
            $display("  sel=%b in0=%b in1=%b Expected=%b Got=%b",
                     sel, in0, in1, expected, out);
            all_passed = 1'b0;
        end

        // Test 6: Both inputs same with sel=1
        in0      = 3'b011;
        in1      = 3'b011;
        sel      = 1'b1;
        expected = 3'b011;
        #5;
        if (out === expected)
            $display("Test 6 passed");
        else begin
            $display("Test 6 failed");
            $display("  sel=%b in0=%b in1=%b Expected=%b Got=%b",
                     sel, in0, in1, expected, out);
            all_passed = 1'b0;
        end

        // Test 7: Toggle select while inputs stay fixed
        in0      = 3'b001;
        in1      = 3'b100;
        sel      = 1'b0;
        expected = 3'b001;
        #5;
        if (out === expected)
            $display("Test 7 passed");
        else begin
            $display("Test 7 failed");
            $display("  sel=%b in0=%b in1=%b Expected=%b Got=%b",
                     sel, in0, in1, expected, out);
            all_passed = 1'b0;
        end

        // Test 8: Toggle to select in1
        sel      = 1'b1;
        expected = 3'b100;
        #5;
        if (out === expected)
            $display("Test 8 passed");
        else begin
            $display("Test 8 failed");
            $display("  sel=%b in0=%b in1=%b Expected=%b Got=%b",
                     sel, in0, in1, expected, out);
            all_passed = 1'b0;
        end

        if (all_passed)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule