`timescale 1ns/1ps

module shift_register_tb;

    parameter DATA_W      = 8;
    parameter KERNEL_SIZE = 5;

    reg                clk, rst;
    reg                valid_in;
    reg  [DATA_W-1:0] data_in;
    wire [DATA_W*KERNEL_SIZE-1:0] taps;

    shift_register #(
        .DATA_W(DATA_W),
        .KERNEL_SIZE(KERNEL_SIZE)
    ) uut (
        .clk(clk), .rst(rst),
        .valid_in(valid_in),
        .data_in(data_in),
        .taps(taps)
    );

    always #5 clk = ~clk;

    integer test_num, any_fail;

    wire [DATA_W-1:0] tap0 = taps[DATA_W*1-1 -: DATA_W];
    wire [DATA_W-1:0] tap1 = taps[DATA_W*2-1 -: DATA_W];
    wire [DATA_W-1:0] tap2 = taps[DATA_W*3-1 -: DATA_W];
    wire [DATA_W-1:0] tap3 = taps[DATA_W*4-1 -: DATA_W];
    wire [DATA_W-1:0] tap4 = taps[DATA_W*5-1 -: DATA_W];

    task check;
        input integer tnum;
        input [DATA_W-1:0] exp0, exp1, exp2, exp3, exp4;
        begin
            if (tap0 === exp0 && tap1 === exp1 && tap2 === exp2 &&
                tap3 === exp3 && tap4 === exp4) begin
                $display("Test %0d passed", tnum);
            end else begin
                $display("Test %0d failed", tnum);
                $display("  Expected: %0d %0d %0d %0d %0d", exp0, exp1, exp2, exp3, exp4);
                $display("  Got:      %0d %0d %0d %0d %0d", tap0, tap1, tap2, tap3, tap4);
                any_fail = 1;
            end
        end
    endtask

    initial begin
        clk      = 0;
        rst      = 1;
        valid_in = 0;
        data_in  = 0;
        any_fail = 0;
        test_num = 0;

        // Test 1: Reset clears all taps
        @(posedge clk); #1;
        test_num = 1;
        check(test_num, 0, 0, 0, 0, 0);

        rst = 0;

        // Test 2: First sample enters tap0
        valid_in = 1;
        data_in  = 8'd10;
        @(posedge clk); #1;
        test_num = 2;
        check(test_num, 10, 0, 0, 0, 0);

        // Test 3: Second sample shifts
        data_in = 8'd20;
        @(posedge clk); #1;
        test_num = 3;
        check(test_num, 20, 10, 0, 0, 0);

        // Test 4: Third sample
        data_in = 8'd30;
        @(posedge clk); #1;
        test_num = 4;
        check(test_num, 30, 20, 10, 0, 0);

        // Test 5: Fourth sample
        data_in = 8'd40;
        @(posedge clk); #1;
        test_num = 5;
        check(test_num, 40, 30, 20, 10, 0);

        // Test 6: Fifth sample - window full
        data_in = 8'd50;
        @(posedge clk); #1;
        test_num = 6;
        check(test_num, 50, 40, 30, 20, 10);

        // Test 7: Sixth sample - oldest drops out
        data_in = 8'd60;
        @(posedge clk); #1;
        test_num = 7;
        check(test_num, 60, 50, 40, 30, 20);

        // Test 8: valid_in=0, taps hold
        valid_in = 0;
        data_in  = 8'd99;
        @(posedge clk); #1;
        test_num = 8;
        check(test_num, 60, 50, 40, 30, 20);

        if (any_fail == 0)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule
