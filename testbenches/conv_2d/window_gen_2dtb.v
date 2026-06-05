`timescale 1ns/1ps

module window_gen_2d_tb;

    parameter DATA_W      = 8;
    parameter IMG_WIDTH   = 4;
    parameter KERNEL_SIZE = 3;
    parameter WIN_W       = DATA_W * KERNEL_SIZE * KERNEL_SIZE;

    reg                clk, rst;
    reg                valid_in;
    reg  [DATA_W-1:0] pixel_in;

    wire [WIN_W-1:0] window_z;
    window_gen_2d #(
        .DATA_W(DATA_W),
        .IMG_WIDTH(IMG_WIDTH),
        .KERNEL_SIZE(KERNEL_SIZE),
        .PADDING_MODE(0)
    ) uut_z (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in),
        .pixel_in(pixel_in),
        .window(window_z)
    );

    wire [WIN_W-1:0] window_v;
    window_gen_2d #(
        .DATA_W(DATA_W),
        .IMG_WIDTH(IMG_WIDTH),
        .KERNEL_SIZE(KERNEL_SIZE),
        .PADDING_MODE(1)
    ) uut_v (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in),
        .pixel_in(pixel_in),
        .window(window_v)
    );

    always #5 clk = ~clk;

    /*
        Window packing assumption:

        check_* arguments are written visually as:

            [a,b,c /
             d,e,f /
             g,h,i]

        where a is top-left and i is bottom-right.

        The DUT window is unpacked using the same mapping as the original TB.
    */

    wire [DATA_W-1:0] z_r2_0 = window_z[DATA_W*1-1 -: DATA_W];
    wire [DATA_W-1:0] z_r2_1 = window_z[DATA_W*2-1 -: DATA_W];
    wire [DATA_W-1:0] z_r2_2 = window_z[DATA_W*3-1 -: DATA_W];
    wire [DATA_W-1:0] z_r1_0 = window_z[DATA_W*4-1 -: DATA_W];
    wire [DATA_W-1:0] z_r1_1 = window_z[DATA_W*5-1 -: DATA_W];
    wire [DATA_W-1:0] z_r1_2 = window_z[DATA_W*6-1 -: DATA_W];
    wire [DATA_W-1:0] z_r0_0 = window_z[DATA_W*7-1 -: DATA_W];
    wire [DATA_W-1:0] z_r0_1 = window_z[DATA_W*8-1 -: DATA_W];
    wire [DATA_W-1:0] z_r0_2 = window_z[DATA_W*9-1 -: DATA_W];

    wire [DATA_W-1:0] v_r2_0 = window_v[DATA_W*1-1 -: DATA_W];
    wire [DATA_W-1:0] v_r2_1 = window_v[DATA_W*2-1 -: DATA_W];
    wire [DATA_W-1:0] v_r2_2 = window_v[DATA_W*3-1 -: DATA_W];
    wire [DATA_W-1:0] v_r1_0 = window_v[DATA_W*4-1 -: DATA_W];
    wire [DATA_W-1:0] v_r1_1 = window_v[DATA_W*5-1 -: DATA_W];
    wire [DATA_W-1:0] v_r1_2 = window_v[DATA_W*6-1 -: DATA_W];
    wire [DATA_W-1:0] v_r0_0 = window_v[DATA_W*7-1 -: DATA_W];
    wire [DATA_W-1:0] v_r0_1 = window_v[DATA_W*8-1 -: DATA_W];
    wire [DATA_W-1:0] v_r0_2 = window_v[DATA_W*9-1 -: DATA_W];

    integer any_fail;

    task check_z;
        input integer tnum;
        input [DATA_W-1:0] ea, eb, ec;
        input [DATA_W-1:0] ed, ee, ef;
        input [DATA_W-1:0] eg, eh, ei;
        begin
            if (z_r0_2 === ea && z_r0_1 === eb && z_r0_0 === ec &&
                z_r1_2 === ed && z_r1_1 === ee && z_r1_0 === ef &&
                z_r2_2 === eg && z_r2_1 === eh && z_r2_0 === ei) begin
                $display("[ZERO]  Test %0d passed", tnum);
            end else begin
                $display("[ZERO]  Test %0d failed", tnum);
                $display("  Expected: [%0d,%0d,%0d / %0d,%0d,%0d / %0d,%0d,%0d]",
                         ea, eb, ec, ed, ee, ef, eg, eh, ei);
                $display("  Got:      [%0d,%0d,%0d / %0d,%0d,%0d / %0d,%0d,%0d]",
                         z_r0_2, z_r0_1, z_r0_0,
                         z_r1_2, z_r1_1, z_r1_0,
                         z_r2_2, z_r2_1, z_r2_0);
                any_fail = 1;
            end
        end
    endtask

    task check_v;
        input integer tnum;
        input [DATA_W-1:0] ea, eb, ec;
        input [DATA_W-1:0] ed, ee, ef;
        input [DATA_W-1:0] eg, eh, ei;
        begin
            if (v_r0_2 === ea && v_r0_1 === eb && v_r0_0 === ec &&
                v_r1_2 === ed && v_r1_1 === ee && v_r1_0 === ef &&
                v_r2_2 === eg && v_r2_1 === eh && v_r2_0 === ei) begin
                $display("[VALID] Test %0d passed", tnum);
            end else begin
                $display("[VALID] Test %0d failed", tnum);
                $display("  Expected: [%0d,%0d,%0d / %0d,%0d,%0d / %0d,%0d,%0d]",
                         ea, eb, ec, ed, ee, ef, eg, eh, ei);
                $display("  Got:      [%0d,%0d,%0d / %0d,%0d,%0d / %0d,%0d,%0d]",
                         v_r0_2, v_r0_1, v_r0_0,
                         v_r1_2, v_r1_1, v_r1_0,
                         v_r2_2, v_r2_1, v_r2_0);
                any_fail = 1;
            end
        end
    endtask

    task feed_pixel;
        input [DATA_W-1:0] p;
        begin
            @(negedge clk);
            valid_in = 1;
            pixel_in = p;
            @(posedge clk);
            #1;
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

        img[0]  = 8'd1;   img[1]  = 8'd2;   img[2]  = 8'd3;   img[3]  = 8'd4;
        img[4]  = 8'd5;   img[5]  = 8'd6;   img[6]  = 8'd7;   img[7]  = 8'd8;
        img[8]  = 8'd9;   img[9]  = 8'd10;  img[10] = 8'd11;  img[11] = 8'd12;
        img[12] = 8'd13;  img[13] = 8'd14;  img[14] = 8'd15;  img[15] = 8'd16;

        #20 rst = 0;

        // Test 1: after reset, both modes should be zero
        @(negedge clk);
        valid_in = 0;
        pixel_in = 0;
        @(posedge clk);
        #1;

        check_z(1, 0,0,0, 0,0,0, 0,0,0);
        check_v(1, 0,0,0, 0,0,0, 0,0,0);

        // Test 2: feed img[0] = 1
        // Zero-padding mode should include the real pixel at bottom-right.
        // Valid mode is not checked yet because no complete 3x3 actual-pixel window exists.
        feed_pixel(img[0]);
        check_z(2, 0,0,0, 0,0,0, 0,0,1);

        // Feed img[1] through img[6]
        for (idx = 1; idx <= 6; idx = idx + 1) begin
            feed_pixel(img[idx]);
        end

        // Test 3: after img[6] = 7
        // Coordinate is row=1, col=2.
        // Top row is outside the image, so only zero-padding mode is checked.
        check_z(3, 0,0,0, 1,2,3, 5,6,7);

        // Feed img[7]
        feed_pixel(img[7]);

        // Test 4: after img[7] = 8
        // Coordinate is row=1, col=3.
        // Top row is still outside the image.
        check_z(4, 0,0,0, 2,3,4, 6,7,8);

        // Feed img[8]
        feed_pixel(img[8]);

        // Test 5: after img[8] = 9
        // Coordinate is row=2, col=0.
        // Left columns are outside the image.
        check_z(5, 0,0,1, 0,0,5, 0,0,9);

        // Feed img[9]
        feed_pixel(img[9]);

        // Test 6: after img[9] = 10
        // Coordinate is row=2, col=1.
        // Leftmost column is outside the image.
        check_z(6, 0,1,2, 0,5,6, 0,9,10);

        // Feed img[10]
        feed_pixel(img[10]);

        // Test 7: after img[10] = 11
        // First complete real 3x3 window. Both modes should match.
        check_z(7, 1,2,3, 5,6,7, 9,10,11);
        check_v(7, 1,2,3, 5,6,7, 9,10,11);

        // Feed img[11]
        feed_pixel(img[11]);

        // Test 8: after img[11] = 12
        // Complete real 3x3 window. Both modes should match.
        check_z(8, 2,3,4, 6,7,8, 10,11,12);
        check_v(8, 2,3,4, 6,7,8, 10,11,12);

        // Feed img[12]
        feed_pixel(img[12]);

        // Test 9: after img[12] = 13
        // Coordinate is row=3, col=0.
        // Left columns are outside the image.
        check_z(9, 0,0,5, 0,0,9, 0,0,13);

        // Feed img[13]
        feed_pixel(img[13]);

        // Test 10: after img[13] = 14
        // Coordinate is row=3, col=1.
        // Leftmost column is outside the image.
        check_z(10, 0,5,6, 0,9,10, 0,13,14);

        // Feed img[14]
        feed_pixel(img[14]);

        // Test 11: after img[14] = 15
        // Complete real 3x3 window. Both modes should match.
        check_z(11, 5,6,7, 9,10,11, 13,14,15);
        check_v(11, 5,6,7, 9,10,11, 13,14,15);

        // Feed img[15]
        feed_pixel(img[15]);

        // Test 12: after img[15] = 16
        // Complete real 3x3 window. Both modes should match.
        check_z(12, 6,7,8, 10,11,12, 14,15,16);
        check_v(12, 6,7,8, 10,11,12, 14,15,16);

        @(negedge clk);
        valid_in = 0;
        pixel_in = 0;

        if (any_fail == 0)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule
