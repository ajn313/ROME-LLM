`timescale 1ns/1ps

module window_gen_2d_tb;

    parameter DATA_W      = 8;
    parameter IMG_WIDTH   = 4;
    parameter KERNEL_SIZE = 3;
    parameter WIN_W       = DATA_W * KERNEL_SIZE * KERNEL_SIZE;

    reg                clk, rst;
    reg                valid_in;
    reg  [DATA_W-1:0] pixel_in;
    wire [WIN_W-1:0]   window;

    window_gen_2d #(
        .DATA_W(DATA_W),
        .IMG_WIDTH(IMG_WIDTH),
        .KERNEL_SIZE(KERNEL_SIZE)
    ) uut (
        .clk(clk), .rst(rst),
        .valid_in(valid_in),
        .pixel_in(pixel_in),
        .window(window)
    );

    always #5 clk = ~clk;

    wire [DATA_W-1:0] r2_0 = window[DATA_W*1-1 -: DATA_W]; // row2[0] newest
    wire [DATA_W-1:0] r2_1 = window[DATA_W*2-1 -: DATA_W]; // row2[1]
    wire [DATA_W-1:0] r2_2 = window[DATA_W*3-1 -: DATA_W]; // row2[2] oldest
    wire [DATA_W-1:0] r1_0 = window[DATA_W*4-1 -: DATA_W]; // row1[0]
    wire [DATA_W-1:0] r1_1 = window[DATA_W*5-1 -: DATA_W]; // row1[1]
    wire [DATA_W-1:0] r1_2 = window[DATA_W*6-1 -: DATA_W]; // row1[2]
    wire [DATA_W-1:0] r0_0 = window[DATA_W*7-1 -: DATA_W]; // row0[0]
    wire [DATA_W-1:0] r0_1 = window[DATA_W*8-1 -: DATA_W]; // row0[1]
    wire [DATA_W-1:0] r0_2 = window[DATA_W*9-1 -: DATA_W]; // row0[2]

    integer any_fail;

    task check;
        input integer tnum;
        input [DATA_W-1:0] ea, eb, ec, ed, ee, ef, eg, eh, ei;
        begin
            if (r0_2===ea && r0_1===eb && r0_0===ec &&
                r1_2===ed && r1_1===ee && r1_0===ef &&
                r2_2===eg && r2_1===eh && r2_0===ei) begin
                $display("Test %0d passed", tnum);
            end else begin
                $display("Test %0d failed", tnum);
                $display("  Expected: [%0d,%0d,%0d / %0d,%0d,%0d / %0d,%0d,%0d]",
                         ea, eb, ec, ed, ee, ef, eg, eh, ei);
                $display("  Got:      [%0d,%0d,%0d / %0d,%0d,%0d / %0d,%0d,%0d]",
                         r0_2, r0_1, r0_0, r1_2, r1_1, r1_0, r2_2, r2_1, r2_0);
                any_fail = 1;
            end
        end
    endtask

    reg [DATA_W-1:0] img [0:15];
    integer idx;

    initial begin
        clk      = 0;
        rst      = 1;
        valid_in = 0;
        pixel_in = 0;
        any_fail = 0;

        img[0]=1;  img[1]=2;  img[2]=3;  img[3]=4;
        img[4]=5;  img[5]=6;  img[6]=7;  img[7]=8;
        img[8]=9;  img[9]=10; img[10]=11; img[11]=12;
        img[12]=13; img[13]=14; img[14]=15; img[15]=16;

        #20 rst = 0;

        // Test 1: after reset, window all zeros
        @(negedge clk); valid_in = 0; pixel_in = 0;
        @(posedge clk); #1;
        check(1, 0,0,0, 0,0,0, 0,0,0);

        // Feed pixels one by one with negedge/posedge
        // Test 2: after feeding img[0]=1 (cycle 0, col_cnt=1 → mask_right)
        @(negedge clk); valid_in = 1; pixel_in = img[0];
        @(posedge clk); #1;
        check(2, 0,0,0, 0,0,0, 0,0,0);

        // Feed img[1]..img[6] without checking (advance to cycle 7)
        for (idx = 1; idx <= 6; idx = idx + 1) begin
            @(negedge clk); pixel_in = img[idx];
            @(posedge clk); #1;
        end

        // Test 3: after cycle 7 (fed img[6]=7)
        check(3, 0,0,0, 1,2,3, 5,6,7);

        // Feed img[7]
        @(negedge clk); pixel_in = img[7];
        @(posedge clk); #1;

        // Test 4: after cycle 8 (fed img[7]=8)
        check(4, 0,0,0, 2,3,4, 6,7,8);

        // Feed img[8]
        @(negedge clk); pixel_in = img[8];
        @(posedge clk); #1;

        // Test 5: after cycle 8 (fed img[8]=9, col_cnt=1 → mask_right)
        check(5, 0,0,0, 3,4,0, 7,8,0);

        // Feed img[9], img[10]
        @(negedge clk); pixel_in = img[9];
        @(posedge clk); #1;
        @(negedge clk); pixel_in = img[10];
        @(posedge clk); #1;

        // Test 6: after cycle 11 (fed img[10]=11)
        check(6, 1,2,3, 5,6,7, 9,10,11);

        // Feed img[11]..img[15]
        for (idx = 11; idx <= 15; idx = idx + 1) begin
            @(negedge clk); pixel_in = img[idx];
            @(posedge clk); #1;
        end

        // Test 7: after cycle 16 (fed img[15]=16)
        check(7, 6,7,8, 10,11,12, 14,15,16);

        // Test 8: feed 0 (flush), col_cnt wraps → right boundary masking
        @(negedge clk); pixel_in = 0;
        @(posedge clk); #1;
        check(8, 7,8,0, 11,12,0, 15,16,0);

        @(negedge clk); valid_in = 0;

        if (any_fail == 0)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule
