`timescale 1ns/1ps

module full_adder_1bit_tb;

    reg  a;
    reg  b;
    reg  cin;
    wire sum;
    wire cout;

    reg  expected_sum;
    reg  expected_cout;

    integer failures;
    integer test_num;

    full_adder_1bit dut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    task run_test;
        input ta;
        input tb;
        input tcin;
        input tsum;
        input tcout;
        begin
            a = ta;
            b = tb;
            cin = tcin;
            expected_sum  = tsum;
            expected_cout = tcout;
            #1;

            if ((sum === expected_sum) && (cout === expected_cout)) begin
                $display("Test %0d passed", test_num);
            end else begin
                $display("Test %0d failed", test_num);
                $display("  Inputs:   a=%b b=%b cin=%b", a, b, cin);
                $display("  Expected: sum=%b cout=%b", expected_sum, expected_cout);
                $display("  Actual:   sum=%b cout=%b", sum, cout);
                failures = failures + 1;
            end

            test_num = test_num + 1;
        end
    endtask

    initial begin
        failures = 0;
        test_num = 1;

        // Exhaustive truth-table tests
        run_test(1'b0, 1'b0, 1'b0, 1'b0, 1'b0);
        run_test(1'b0, 1'b0, 1'b1, 1'b1, 1'b0);
        run_test(1'b0, 1'b1, 1'b0, 1'b1, 1'b0);
        run_test(1'b0, 1'b1, 1'b1, 1'b0, 1'b1);
        run_test(1'b1, 1'b0, 1'b0, 1'b1, 1'b0);
        run_test(1'b1, 1'b0, 1'b1, 1'b0, 1'b1);
        run_test(1'b1, 1'b1, 1'b0, 1'b0, 1'b1);
        run_test(1'b1, 1'b1, 1'b1, 1'b1, 1'b1);

        if (failures == 0)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule