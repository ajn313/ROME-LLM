`timescale 1ns/1ps

module mac_unit_tb;

    parameter DATA_W      = 8;
    parameter KERNEL_SIZE = 5;
    parameter GAIN_W      = 4;
    parameter COEFF0      = 2;
    parameter COEFF1      = 8;
    parameter COEFF2      = 12;
    parameter COEFF3      = 8;
    parameter COEFF4      = 2;

    reg  [DATA_W-1:0]              newest;
    reg  [DATA_W*KERNEL_SIZE-1:0]  taps;
    wire [DATA_W+GAIN_W-1:0]       result;

    mac_unit #(
        .DATA_W(DATA_W),
        .KERNEL_SIZE(KERNEL_SIZE),
        .GAIN_W(GAIN_W),
        .COEFF0(COEFF0),
        .COEFF1(COEFF1),
        .COEFF2(COEFF2),
        .COEFF3(COEFF3),
        .COEFF4(COEFF4)
    ) uut (
        .newest(newest),
        .taps(taps),
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

    initial begin
        any_fail = 0;

        // Test 1: All zeros → 0
        newest = 0;
        taps = {8'd0, 8'd0, 8'd0, 8'd0, 8'd0};
        check(1, 0);

        // Test 2: newest=128, taps all zero
        newest = 8'd128;
        taps = {8'd0, 8'd0, 8'd0, 8'd0, 8'd0};
        check(2, 16);

        // Test 3: newest=177, tap[0]=128
        newest = 8'd177;
        taps = {8'd0, 8'd0, 8'd0, 8'd0, 8'd128};
        check(3, 86);

        // Test 4: newest=218, tap[0]=177, tap[1]=128
        newest = 8'd218;
        taps = {8'd0, 8'd0, 8'd0, 8'd128, 8'd177};
        check(4, 211);

        // Test 5: newest=245, tap[0]=218, tap[1]=177, tap[2]=128
        newest = 8'd245;
        taps = {8'd0, 8'd0, 8'd128, 8'd177, 8'd218};
        check(5, 336);

        // Test 6: newest=255, tap[0]=245, tap[1]=218, tap[2]=177, tap[3]=128
        newest = 8'd255;
        taps = {8'd0, 8'd128, 8'd177, 8'd218, 8'd245};
        check(6, 422);

        // Test 7: newest=245, tap[0]=255, tap[1]=245, tap[2]=218, tap[3]=177
        newest = 8'd245;
        taps = {8'd0, 8'd177, 8'd218, 8'd245, 8'd255};
        check(7, 473);

        // Test 8: newest=218, tap[0]=245, tap[1]=255, tap[2]=245, tap[3]=218
        newest = 8'd218;
        taps = {8'd0, 8'd218, 8'd245, 8'd255, 8'd245};
        check(8, 490);

        if (any_fail == 0)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule
