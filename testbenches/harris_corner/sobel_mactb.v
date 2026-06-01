`timescale 1ns/1ps

module sobel_mac_tb;

    parameter DATA_W = 8;
    parameter KERNEL_SIZE = 3;
    parameter OUT_W = 16;
    parameter WIN_W = DATA_W * KERNEL_SIZE * KERNEL_SIZE;

    reg  [WIN_W-1:0]          window;
    wire signed [OUT_W-1:0]   result_gx;
    wire signed [OUT_W-1:0]   result_gy;

    sobel_mac #(
        .DATA_W(DATA_W), .KERNEL_SIZE(KERNEL_SIZE), .OUT_W(OUT_W),
        .C00(-1), .C01(0), .C02(1), .C10(-2), .C11(0), .C12(2), .C20(-1), .C21(0), .C22(1)
    ) uut_gx (.window(window), .result(result_gx));

    sobel_mac #(
        .DATA_W(DATA_W), .KERNEL_SIZE(KERNEL_SIZE), .OUT_W(OUT_W),
        .C00(-1), .C01(-2), .C02(-1), .C10(0), .C11(0), .C12(0), .C20(1), .C21(2), .C22(1)
    ) uut_gy (.window(window), .result(result_gy));

    integer any_fail;

    task check;
        input integer tnum;
        input signed [OUT_W-1:0] exp_gx;
        input signed [OUT_W-1:0] exp_gy;
        begin
            #1;
            if (result_gx === exp_gx && result_gy === exp_gy) begin
                $display("Test %0d passed", tnum);
            end else begin
                $display("Test %0d failed", tnum);
                $display("  Gx: expected=%0d got=%0d", exp_gx, result_gx);
                $display("  Gy: expected=%0d got=%0d", exp_gy, result_gy);
                any_fail = 1;
            end
        end
    endtask

    initial begin
        any_fail = 0;

        // Test 1: all zeros
        window = {8'd0,8'd0,8'd0, 8'd0,8'd0,8'd0, 8'd0,8'd0,8'd0};
        check(1, 0, 0);

        // Test 2: uniform 100 → no gradient
        window = {8'd100,8'd100,8'd100, 8'd100,8'd100,8'd100, 8'd100,8'd100,8'd100};
        check(2, 0, 0);

        // Test 3: vertical edge (left=0, right=200)
        window = {8'd0,8'd0,8'd200, 8'd0,8'd0,8'd200, 8'd0,8'd0,8'd200};
        check(3, 800, 0);

        // Test 4: horizontal edge (top=0, bottom=200)
        window = {8'd0,8'd0,8'd0, 8'd0,8'd0,8'd0, 8'd200,8'd200,8'd200};
        check(4, 0, 800);

        // Test 5: diagonal — top-left bright
        window = {8'd255,8'd0,8'd0, 8'd0,8'd0,8'd0, 8'd0,8'd0,8'd0};
        check(5, -255, -255);

        // Test 6: bottom-right bright
        window = {8'd0,8'd0,8'd0, 8'd0,8'd0,8'd0, 8'd0,8'd0,8'd255};
        check(6, 255, 255);

        // Test 7: center pixel only
        window = {8'd0,8'd0,8'd0, 8'd0,8'd128,8'd0, 8'd0,8'd0,8'd0};
        check(7, 0, 0);

        // Test 8: max gradient — left=0, right=255 all rows
        window = {8'd0,8'd0,8'd255, 8'd0,8'd0,8'd255, 8'd0,8'd0,8'd255};
        check(8, 1020, 0);

        if (any_fail == 0)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule
