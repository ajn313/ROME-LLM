`timescale 1ns/1ps

module rca_4bit_tb;

    reg  [3:0] a;
    reg  [3:0] b;
    reg        cin;
    wire [3:0] sum;
    wire       cout;

    reg  [4:0] expected;

    integer failures;
    integer test_num;

    rca_4bit dut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    task run_test;
        input [3:0] ta;
        input [3:0] tb;
        input       tcin;
        begin
            a   = ta;
            b   = tb;
            cin = tcin;
            expected = ta + tb + tcin;
            #1;

            if ((sum === expected[3:0]) && (cout === expected[4])) begin
                $display("Test %0d passed", test_num);
            end else begin
                $display("Test %0d failed", test_num);
                $display("  Inputs:   a=0x%0h b=0x%0h cin=%b", a, b, cin);
                $display("  Expected: sum=0x%0h cout=%b", expected[3:0], expected[4]);
                $display("  Actual:   sum=0x%0h cout=%b", sum, cout);
                failures = failures + 1;
            end

            test_num = test_num + 1;
        end
    endtask

    initial begin
        failures = 0;
        test_num = 1;

        // Basic cases
        run_test(4'h0, 4'h0, 1'b0); // 0 + 0
        run_test(4'h1, 4'h2, 1'b0); // 1 + 2 = 3
        run_test(4'h3, 4'h4, 1'b1); // 3 + 4 + 1 = 8

        // Carry propagation cases
        run_test(4'hF, 4'h0, 1'b1); // F + 0 + 1 = 10
        run_test(4'hF, 4'h1, 1'b0); // F + 1 = 10
        run_test(4'h7, 4'h8, 1'b0); // 7 + 8 = F

        // Overflow cases
        run_test(4'hF, 4'hF, 1'b0); // F + F = 1E
        run_test(4'hF, 4'hF, 1'b1); // F + F + 1 = 1F

        // Mixed/random-style cases
        run_test(4'h5, 4'hA, 1'b0); // 5 + A = F
        run_test(4'h9, 4'h6, 1'b1); // 9 + 6 + 1 = 10
        run_test(4'hC, 4'h3, 1'b0); // C + 3 = F
        run_test(4'h2, 4'hD, 1'b1); // 2 + D + 1 = 10

        if (failures == 0)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule