`timescale 1ns/1ps

module harris_response_tb;

    parameter RESP_W = 32;
    parameter K_W    = 8;

    reg  signed [RESP_W-1:0]   sxx, syy, sxy;
    reg  [K_W-1:0]             k_param;
    wire signed [2*RESP_W-1:0] response;

    harris_response #(.RESP_W(RESP_W), .K_W(K_W))
    uut (.sxx(sxx), .syy(syy), .sxy(sxy), .k_param(k_param), .response(response));

    integer any_fail;

    task check;
        input integer tnum;
        input signed [2*RESP_W-1:0] expected;
        begin
            #1;
            if (response === expected) begin
                $display("Test %0d passed", tnum);
            end else begin
                $display("Test %0d failed", tnum);
                $display("  Expected: %0d, Got: %0d", expected, response);
                any_fail = 1;
            end
        end
    endtask

    initial begin
        any_fail = 0;

        // Test 1: all zeros → R = 0
        sxx = 0; syy = 0; sxy = 0; k_param = 5;
        check(1, 0);

        // Test 2: corner-like (sxx=100, syy=100, sxy=0)
        sxx = 100; syy = 100; sxy = 0; k_param = 5;
        check(2, 6875);

        // Test 3: edge-like (sxx=100, syy=0, sxy=0)
        sxx = 100; syy = 0; sxy = 0; k_param = 5;
        check(3, -781);

        // Test 4: flat (sxx=0, syy=0, sxy=0)
        sxx = 0; syy = 0; sxy = 0; k_param = 5;
        check(4, 0);

        // Test 5: strong corner (sxx=1000, syy=1000, sxy=0)
        sxx = 1000; syy = 1000; sxy = 0; k_param = 5;
        check(5, 687500);

        // Test 6: strong edge with cross-term (sxx=1000, syy=1000, sxy=1000)
        sxx = 1000; syy = 1000; sxy = 1000; k_param = 5;
        check(6, -312500);

        // Test 7: k=0 → R = det
        sxx = 100; syy = 50; sxy = 30;
        k_param = 0;
        check(7, 4100);

        // Test 8: negative values
        sxx = -100; syy = -100; sxy = 50;
        k_param = 5;
        check(8, 4375);

        if (any_fail == 0)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule
