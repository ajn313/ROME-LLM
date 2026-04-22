`timescale 1ns / 1ps

module mux2_1_16bit_tb;

    reg  [15:0] in0;
    reg  [15:0] in1;
    reg         sel;
    wire [15:0] out;

    reg all_passed;
    reg [15:0] expected;

    mux2_1_16bit uut (
        .in0(in0),
        .in1(in1),
        .sel(sel),
        .out(out)
    );

    initial begin
        all_passed = 1'b1;

        // Test 1: sel=0 selects in0
        in0      = 16'h0000;
        in1      = 16'hFFFF;
        sel      = 1'b0;
        expected = 16'h0000;
        #5;
        if (out === expected)
            $display("Test 1 passed");
        else begin
            $display("Test 1 failed");
            $display("  sel=%b in0=%h in1=%h Expected=%h Got=%h",
                     sel, in0, in1, expected, out);
            all_passed = 1'b0;
        end

        // Test 2: sel=1 selects in1
        in0      = 16'h0000;
        in1      = 16'hFFFF;
        sel      = 1'b1;
        expected = 16'hFFFF;
        #5;
        if (out === expected)
            $display("Test 2 passed");
        else begin
            $display("Test 2 failed");
            $display("  sel=%b in0=%h in1=%h Expected=%h Got=%h",
                     sel, in0, in1, expected, out);
            all_passed = 1'b0;
        end

        // Test 3: Mixed values, select in0
        in0      = 16'h1234;
        in1      = 16'hABCD;
        sel      = 1'b0;
        expected = 16'h1234;
        #5;
        if (out === expected)
            $display("Test 3 passed");
        else begin
            $display("Test 3 failed");
            $display("  sel=%b in0=%h in1=%h Expected=%h Got=%h",
                     sel, in0, in1, expected, out);
            all_passed = 1'b0;
        end

        // Test 4: Mixed values, select in1
        in0      = 16'h1234;
        in1      = 16'hABCD;
        sel      = 1'b1;
        expected = 16'hABCD;
        #5;
        if (out === expected)
            $display("Test 4 passed");
        else begin
            $display("Test 4 failed");
            $display("  sel=%b in0=%h in1=%h Expected=%h Got=%h",
                     sel, in0, in1, expected, out);
            all_passed = 1'b0;
        end

        // Test 5: Both inputs same
        in0      = 16'h0F0F;
        in1      = 16'h0F0F;
        sel      = 1'b0;
        expected = 16'h0F0F;
        #5;
        if (out === expected)
            $display("Test 5 passed");
        else begin
            $display("Test 5 failed");
            $display("  sel=%b in0=%h in1=%h Expected=%h Got=%h",
                     sel, in0, in1, expected, out);
            all_passed = 1'b0;
        end

        // Test 6: Both inputs same with sel=1
        in0      = 16'h0F0F;
        in1      = 16'h0F0F;
        sel      = 1'b1;
        expected = 16'h0F0F;
        #5;
        if (out === expected)
            $display("Test 6 passed");
        else begin
            $display("Test 6 failed");
            $display("  sel=%b in0=%h in1=%h Expected=%h Got=%h",
                     sel, in0, in1, expected, out);
            all_passed = 1'b0;
        end

        // Test 7: Toggle select while inputs stay fixed
        in0      = 16'hAAAA;
        in1      = 16'h5555;
        sel      = 1'b0;
        expected = 16'hAAAA;
        #5;
        if (out === expected)
            $display("Test 7 passed");
        else begin
            $display("Test 7 failed");
            $display("  sel=%b in0=%h in1=%h Expected=%h Got=%h",
                     sel, in0, in1, expected, out);
            all_passed = 1'b0;
        end

        // Test 8: Toggle to select in1
        sel      = 1'b1;
        expected = 16'h5555;
        #5;
        if (out === expected)
            $display("Test 8 passed");
        else begin
            $display("Test 8 failed");
            $display("  sel=%b in0=%h in1=%h Expected=%h Got=%h",
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