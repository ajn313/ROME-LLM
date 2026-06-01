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
    window_gen_2d #(.DATA_W(DATA_W), .IMG_WIDTH(IMG_WIDTH), .KERNEL_SIZE(KERNEL_SIZE), .PADDING_MODE(0))
    uut_z (.clk(clk), .rst(rst), .valid_in(valid_in), .pixel_in(pixel_in), .window(window_z));

    wire [WIN_W-1:0] window_v;
    window_gen_2d #(.DATA_W(DATA_W), .IMG_WIDTH(IMG_WIDTH), .KERNEL_SIZE(KERNEL_SIZE), .PADDING_MODE(1))
    uut_v (.clk(clk), .rst(rst), .valid_in(valid_in), .pixel_in(pixel_in), .window(window_v));

    always #5 clk = ~clk;

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
        input [DATA_W-1:0] ea, eb, ec, ed, ee, ef, eg, eh, ei;
        begin
            if (z_r0_2===ea && z_r0_1===eb && z_r0_0===ec &&
                z_r1_2===ed && z_r1_1===ee && z_r1_0===ef &&
                z_r2_2===eg && z_r2_1===eh && z_r2_0===ei)
                $display("[ZERO]  Test %0d passed", tnum);
            else begin
                $display("[ZERO]  Test %0d failed", tnum);
                $display("  Expected: [%0d,%0d,%0d / %0d,%0d,%0d / %0d,%0d,%0d]", ea,eb,ec,ed,ee,ef,eg,eh,ei);
                $display("  Got:      [%0d,%0d,%0d / %0d,%0d,%0d / %0d,%0d,%0d]",
                         z_r0_2,z_r0_1,z_r0_0, z_r1_2,z_r1_1,z_r1_0, z_r2_2,z_r2_1,z_r2_0);
                any_fail = 1;
            end
        end
    endtask

    task check_v;
        input integer tnum;
        input [DATA_W-1:0] ea, eb, ec, ed, ee, ef, eg, eh, ei;
        begin
            if (v_r0_2===ea && v_r0_1===eb && v_r0_0===ec &&
                v_r1_2===ed && v_r1_1===ee && v_r1_0===ef &&
                v_r2_2===eg && v_r2_1===eh && v_r2_0===ei)
                $display("[VALID] Test %0d passed", tnum);
            else begin
                $display("[VALID] Test %0d failed", tnum);
                $display("  Expected: [%0d,%0d,%0d / %0d,%0d,%0d / %0d,%0d,%0d]", ea,eb,ec,ed,ee,ef,eg,eh,ei);
                $display("  Got:      [%0d,%0d,%0d / %0d,%0d,%0d / %0d,%0d,%0d]",
                         v_r0_2,v_r0_1,v_r0_0, v_r1_2,v_r1_1,v_r1_0, v_r2_2,v_r2_1,v_r2_0);
                any_fail = 1;
            end
        end
    endtask

    reg [DATA_W-1:0] img [0:15];
    integer idx;

    initial begin
        clk = 0; rst = 1; valid_in = 0; pixel_in = 0; any_fail = 0;
        img[0]=1;img[1]=2;img[2]=3;img[3]=4;
        img[4]=5;img[5]=6;img[6]=7;img[7]=8;
        img[8]=9;img[9]=10;img[10]=11;img[11]=12;
        img[12]=13;img[13]=14;img[14]=15;img[15]=16;

        #20 rst = 0;

        // Test 1: reset — both modes all zero
        @(negedge clk); valid_in = 0; pixel_in = 0;
        @(posedge clk); #1;
        check_z(1, 0,0,0, 0,0,0, 0,0,0);
        check_v(1, 0,0,0, 0,0,0, 0,0,0);

        // Test 2: feed img[0]=1
        @(negedge clk); valid_in = 1; pixel_in = img[0];
        @(posedge clk); #1;
        check_z(2, 0,0,0, 0,0,0, 0,0,0);
        check_v(2, 0,0,0, 0,0,0, 0,0,1);

        // Feed img[1]..img[6]
        for (idx = 1; idx <= 6; idx = idx + 1) begin
            @(negedge clk); pixel_in = img[idx];
            @(posedge clk); #1;
        end

        // Test 3: after img[6]=7 — interior, both modes same
        check_z(3, 0,0,0, 1,2,3, 5,6,7);
        check_v(3, 0,0,0, 1,2,3, 5,6,7);

        // Feed img[7]
        @(negedge clk); pixel_in = img[7];
        @(posedge clk); #1;

        // Test 4: interior, both same
        check_z(4, 0,0,0, 2,3,4, 6,7,8);
        check_v(4, 0,0,0, 2,3,4, 6,7,8);

        // Feed img[8]
        @(negedge clk); pixel_in = img[8];
        @(posedge clk); #1;

        // Test 5: col_cnt=1 → zero masks row[0], valid does not
        check_z(5, 0,0,0, 3,4,0, 7,8,0);
        check_v(5, 0,0,1, 3,4,5, 7,8,9);

        // Feed img[9], img[10]
        @(negedge clk); pixel_in = img[9];
        @(posedge clk); #1;
        @(negedge clk); pixel_in = img[10];
        @(posedge clk); #1;

        // Test 6: interior, both same
        check_z(6, 1,2,3, 5,6,7, 9,10,11);
        check_v(6, 1,2,3, 5,6,7, 9,10,11);

        // Feed img[11]..img[15]
        for (idx = 11; idx <= 15; idx = idx + 1) begin
            @(negedge clk); pixel_in = img[idx];
            @(posedge clk); #1;
        end

        // Test 7: interior, both same
        check_z(7, 6,7,8, 10,11,12, 14,15,16);
        check_v(7, 6,7,8, 10,11,12, 14,15,16);

        // Test 8: flush with 0
        @(negedge clk); pixel_in = 0;
        @(posedge clk); #1;
        check_z(8, 7,8,0, 11,12,0, 15,16,0);
        check_v(8, 7,8,9, 11,12,13, 15,16,0);

        @(negedge clk); valid_in = 0;

        if (any_fail == 0)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule
