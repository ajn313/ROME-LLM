`timescale 1ns/1ps

module mac_2d_tb;

    parameter DATA_W      = 8;
    parameter KERNEL_SIZE = 3;
    parameter GAIN_W      = 4;
    parameter WIN_W       = DATA_W * KERNEL_SIZE * KERNEL_SIZE;

    reg  [WIN_W-1:0]            window;
    wire [DATA_W+GAIN_W-1:0]    result;

    mac_2d #(
        .DATA_W(DATA_W),
        .KERNEL_SIZE(KERNEL_SIZE),
        .GAIN_W(GAIN_W)
    ) uut (
        .window(window),
        .result(result)
    );

    integer any_fail;

    task check;
        input integer tnum;
        input [DATA_W+GAIN_W-1:0] expected;
        begin
            #1;
            if (result === expected) begin
                $display("Test %0d passed", tnum);
            end else begin
                $display("Test %0d failed", tnum);
                $display("  Expected: %0d, Got: %0d", expected, result);
                any_fail = 1;
            end
        end
    endtask

    // Kernel: [[1,2,1],[2,4,2],[1,2,1]]

    initial begin
        any_fail = 0;

        // Test 1: all zeros → 0
        window = {8'd0,8'd0,8'd0, 8'd0,8'd0,8'd0, 8'd0,8'd0,8'd0};
        check(1, 0);

        // Test 2: center pixel only = 255
        window = {8'd0,8'd0,8'd0, 8'd0,8'd255,8'd0, 8'd0,8'd0,8'd0};
        check(2, 63);

        // Test 3: all 16 → sum = (1+2+1+2+4+2+1+2+1)*16 = 16*16 = 256, result = 16
        window = {8'd16,8'd16,8'd16, 8'd16,8'd16,8'd16, 8'd16,8'd16,8'd16};
        check(3, 16);

        // Test 4: window from conv2d trace cycle 11
        window = {8'd1,8'd2,8'd3, 8'd5,8'd6,8'd7, 8'd9,8'd10,8'd11};
        check(4, 6);

        // Test 5: window from conv2d golden pixel (3,3) = 50
        window = {8'd10,8'd20,8'd30, 8'd40,8'd50,8'd60, 8'd70,8'd80,8'd90};
        check(5, 50);

        // Test 6: edge pixel — partial window with zeros
        window = {8'd0,8'd0,8'd0, 8'd0,8'd0,8'd10, 8'd0,8'd0,8'd40};
        check(6, 3);

        // Test 7: asymmetric values
        window = {8'd100,8'd0,8'd0, 8'd0,8'd0,8'd0, 8'd0,8'd0,8'd0};
        check(7, 6);

        // Test 8: max values all 255
        window = {8'd255,8'd255,8'd255, 8'd255,8'd255,8'd255, 8'd255,8'd255,8'd255};
        check(8, 255);

        if (any_fail == 0)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule
