`timescale 1ns/1ps

module harris_threshold_tb;

    parameter RESP_W = 32;

    reg  signed [2*RESP_W-1:0] response;
    reg  signed [RESP_W-1:0]   threshold;
    wire                        is_corner;

    harris_threshold #(.RESP_W(RESP_W))
    uut (.response(response), .threshold(threshold), .is_corner(is_corner));

    integer any_fail;

    task check;
        input integer tnum;
        input expected;
        begin
            #1;
            if (is_corner === expected) begin
                $display("Test %0d passed", tnum);
            end else begin
                $display("Test %0d failed", tnum);
                $display("  Expected: %0d, Got: %0d", expected, is_corner);
                any_fail = 1;
            end
        end
    endtask

    initial begin
        any_fail = 0;

        // Test 1: R=0, threshold=1000 → not corner
        response = 0; threshold = 1000;
        check(1, 0);

        // Test 2: R=1001, threshold=1000 → corner
        response = 1001; threshold = 1000;
        check(2, 1);

        // Test 3: R=1000, threshold=1000 → not corner (not >)
        response = 1000; threshold = 1000;
        check(3, 0);

        // Test 4: R=-500, threshold=1000 → not corner
        response = -500; threshold = 1000;
        check(4, 0);

        // Test 5: R=687500, threshold=1000 → corner
        response = 687500; threshold = 1000;
        check(5, 1);

        // Test 6: large negative R
        response = -312500; threshold = 1000;
        check(6, 0);

        // Test 7: threshold=0, R=1 → corner
        response = 1; threshold = 0;
        check(7, 1);

        // Test 8: threshold=0, R=0 → not corner
        response = 0; threshold = 0;
        check(8, 0);

        if (any_fail == 0)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule
