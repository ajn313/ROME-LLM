`timescale 1ns/1ps

module rca_32bit_tb;

    reg  [31:0] a;
    reg  [31:0] b;
    reg         cin;
    wire [31:0] sum;
    wire        cout;

    reg  [32:0] expected;

    integer failures;
    integer test_num;

    rca_32bit dut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    task run_test;
        input [31:0] ta;
        input [31:0] tb;
        input        tcin;
        begin
            a   = ta;
            b   = tb;
            cin = tcin;
            expected = ta + tb + tcin;
            #1;

            if ((sum === expected[31:0]) && (cout === expected[32])) begin
                $display("Test %0d passed", test_num);
            end else begin
                $display("Test %0d failed", test_num);
                $display("  Inputs:   a=0x%08h b=0x%08h cin=%b", a, b, cin);
                $display("  Expected: sum=0x%08h cout=%b", expected[31:0], expected[32]);
                $display("  Actual:   sum=0x%08h cout=%b", sum, cout);
                failures = failures + 1;
            end

            test_num = test_num + 1;
        end
    endtask

    initial begin
        failures = 0;
        test_num = 1;

        // Simple sanity tests
        run_test(32'h00000000, 32'h00000000, 1'b0);
        run_test(32'h00000001, 32'h00000001, 1'b0);
        run_test(32'h0000000F, 32'h00000001, 1'b0);

        // Carry-in behavior
        run_test(32'h00000000, 32'h00000000, 1'b1);
        run_test(32'h0000000F, 32'h00000000, 1'b1);

        // Internal carry propagation
        run_test(32'h0000FFFF, 32'h00000001, 1'b0);
        run_test(32'h00FFFFFF, 32'h00000001, 1'b0);
        run_test(32'h7FFFFFFF, 32'h00000001, 1'b0);

        // Full-width overflow
        run_test(32'hFFFFFFFF, 32'h00000001, 1'b0);
        run_test(32'hFFFFFFFF, 32'h00000000, 1'b1);
        run_test(32'hFFFFFFFF, 32'hFFFFFFFF, 1'b0);
        run_test(32'hFFFFFFFF, 32'hFFFFFFFF, 1'b1);

        // Patterned values
        run_test(32'hAAAAAAAA, 32'h55555555, 1'b0);
        run_test(32'h12345678, 32'h11111111, 1'b0);
        run_test(32'h89ABCDEF, 32'h76543210, 1'b0);

        // Additional mixed cases
        run_test(32'h80000000, 32'h80000000, 1'b0);
        run_test(32'h13579BDF, 32'h2468ACE0, 1'b1);
        run_test(32'hDEADBEEF, 32'h21524110, 1'b0);

        if (failures == 0)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule