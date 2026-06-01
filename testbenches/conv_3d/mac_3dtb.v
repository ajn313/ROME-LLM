`timescale 1ns/1ps

module mac_3d_tb;
    parameter DATA_W = 8;
    parameter KERNEL_SIZE = 3;
    parameter OUT_W = 13;
    parameter NUM_TAPS = 27;
    parameter WIN3D_W = 3 * DATA_W * KERNEL_SIZE * KERNEL_SIZE; // 216 bits

    reg [WIN3D_W-1:0] window_3d;
    reg [NUM_TAPS*DATA_W-1:0] kernel;
    wire [OUT_W-1:0] result;

    mac_3d #(.DATA_W(DATA_W),.KERNEL_SIZE(KERNEL_SIZE),.OUT_W(OUT_W))
    uut (.window_3d(window_3d),.kernel(kernel),.result(result));

    integer any_fail;

    task check;
        input integer tnum;
        input [OUT_W-1:0] expected;
        begin
            #1;
            if (result === expected)
                $display("Test %0d passed", tnum);
            else begin
                $display("Test %0d failed: expected=%0d got=%0d", tnum, expected, result);
                any_fail = 1;
            end
        end
    endtask

    integer i;
    initial begin
        any_fail = 0;

        // Test 1: all zeros
        window_3d = 0; kernel = 0;
        check(1, 0);

        // Test 2: all ones kernel, window all 1s → sum = 27
        kernel = {27{8'd1}};
        window_3d = {27{8'd1}};
        check(2, 27);

        // Test 3: all ones kernel, window all 10s → sum = 270
        window_3d = {27{8'd10}};
        check(3, 270);

        // Test 4: kernel all 2s, window all 5s → sum = 27*2*5 = 270
        kernel = {27{8'd2}};
        window_3d = {27{8'd5}};
        check(4, 270);

        // Test 5: only center voxel = 100, kernel all 1s → sum = 100
        kernel = {27{8'd1}};
        window_3d = 0;
        window_3d[DATA_W*14-1 -: DATA_W] = 100;
        check(5, 100);

        // Test 6: window = 1..27, kernel all 1s → sum = 27*28/2 = 378
        kernel = {27{8'd1}};
        for (i = 0; i < 27; i = i + 1)
            window_3d[DATA_W*(i+1)-1 -: DATA_W] = i + 1;
        check(6, 378);

        // Test 7: single kernel weight = 3 at position 0, rest 0
        kernel = 0;
        kernel[DATA_W-1:0] = 8'd3;
        window_3d = 0;
        window_3d[DATA_W-1:0] = 8'd50;
        check(7, 150);

        // Test 8: from conv3d golden — values 1..27, kernel all 1s → 378
        kernel = {27{8'd1}};
        for (i = 0; i < 27; i = i + 1)
            window_3d[DATA_W*(i+1)-1 -: DATA_W] = i + 1;
        check(8, 378);

        if (any_fail == 0)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end
endmodule
