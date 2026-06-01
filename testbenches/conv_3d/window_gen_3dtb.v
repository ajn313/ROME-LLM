`timescale 1ns/1ps

module window_gen_3d_tb;

    parameter DATA_W      = 8;
    parameter H           = 4;
    parameter W           = 4;
    parameter KERNEL_SIZE = 3;
    parameter N           = 4 * H * W; // D=4, 64 voxels
    parameter WIN3D_W     = 3 * DATA_W * KERNEL_SIZE * KERNEL_SIZE; // 216 bits
    parameter WIN2D_W     = DATA_W * KERNEL_SIZE * KERNEL_SIZE;     // 72 bits

    reg                clk, rst;
    reg                valid_in;
    reg  [DATA_W-1:0] voxel_in;
    wire [WIN3D_W-1:0] window_3d;

    window_gen_3d #(
        .DATA_W(DATA_W), .H(H), .W(W), .KERNEL_SIZE(KERNEL_SIZE)
    ) uut (
        .clk(clk), .rst(rst),
        .valid_in(valid_in), .voxel_in(voxel_in),
        .window_3d(window_3d)
    );

    always #5 clk = ~clk;

    reg [DATA_W-1:0] stimuli [0:N-1];
    integer i, cycle, any_fail;

    function [DATA_W-1:0] get_voxel;
        input integer plane; // 0=2 frames ago, 1=1 frame ago, 2=current
        input integer idx;   // 0..8 within 3x3 window
        integer bit_pos;
        begin
            bit_pos = (plane * 9 + idx) * DATA_W;
            get_voxel = window_3d[bit_pos +: DATA_W];
        end
    endfunction

    task check_window;
        input integer tnum;
        input [DATA_W-1:0] e0,e1,e2,e3,e4,e5,e6,e7,e8;       // plane2 (current)
        input [DATA_W-1:0] e9,e10,e11,e12,e13,e14,e15,e16,e17; // plane1
        input [DATA_W-1:0] e18,e19,e20,e21,e22,e23,e24,e25,e26;// plane0
        reg ok;
        begin
            ok = (get_voxel(2,0)==e0) && (get_voxel(2,1)==e1) && (get_voxel(2,2)==e2) &&
                 (get_voxel(2,3)==e3) && (get_voxel(2,4)==e4) && (get_voxel(2,5)==e5) &&
                 (get_voxel(2,6)==e6) && (get_voxel(2,7)==e7) && (get_voxel(2,8)==e8) &&
                 (get_voxel(1,0)==e9) && (get_voxel(1,1)==e10) && (get_voxel(1,2)==e11) &&
                 (get_voxel(1,3)==e12) && (get_voxel(1,4)==e13) && (get_voxel(1,5)==e14) &&
                 (get_voxel(1,6)==e15) && (get_voxel(1,7)==e16) && (get_voxel(1,8)==e17) &&
                 (get_voxel(0,0)==e18) && (get_voxel(0,1)==e19) && (get_voxel(0,2)==e20) &&
                 (get_voxel(0,3)==e21) && (get_voxel(0,4)==e22) && (get_voxel(0,5)==e23) &&
                 (get_voxel(0,6)==e24) && (get_voxel(0,7)==e25) && (get_voxel(0,8)==e26);
            if (ok)
                $display("Test %0d passed", tnum);
            else begin
                $display("Test %0d failed", tnum);
                $display("  plane2: [%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d]",
                    get_voxel(2,0),get_voxel(2,1),get_voxel(2,2),
                    get_voxel(2,3),get_voxel(2,4),get_voxel(2,5),
                    get_voxel(2,6),get_voxel(2,7),get_voxel(2,8));
                $display("  plane1: [%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d]",
                    get_voxel(1,0),get_voxel(1,1),get_voxel(1,2),
                    get_voxel(1,3),get_voxel(1,4),get_voxel(1,5),
                    get_voxel(1,6),get_voxel(1,7),get_voxel(1,8));
                $display("  plane0: [%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d]",
                    get_voxel(0,0),get_voxel(0,1),get_voxel(0,2),
                    get_voxel(0,3),get_voxel(0,4),get_voxel(0,5),
                    get_voxel(0,6),get_voxel(0,7),get_voxel(0,8));
                any_fail = 1;
            end
        end
    endtask

    initial begin
        clk = 0; rst = 1; valid_in = 0; voxel_in = 0;
        any_fail = 0; cycle = 0;

        // Volume: values 1..64
        for (i = 0; i < N; i = i + 1) stimuli[i] = i + 1;

        #20 rst = 0;

        // Test 1: all zeros after reset
        @(negedge clk); valid_in = 0; voxel_in = 0;
        @(posedge clk); #1;
        check_window(1, 0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0);

        // Feed all 64 voxels + some flush
        for (i = 0; i < N + 40; i = i + 1) begin
            @(negedge clk);
            valid_in = 1;
            voxel_in = (i < N) ? stimuli[i] : 0;
            @(posedge clk); #1;
            cycle = cycle + 1;
        end

        @(negedge clk); valid_in = 0;

        if (any_fail == 0)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule
