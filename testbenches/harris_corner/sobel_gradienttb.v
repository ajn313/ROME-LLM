`timescale 1ns/1ps

module sobel_gradient_tb;

    parameter DATA_W    = 8;
    parameter IMG_WIDTH = 8;
    parameter GRAD_W    = 16;
    parameter NUM_PIXELS = IMG_WIDTH * IMG_WIDTH; // 64
    parameter LATENCY   = IMG_WIDTH + 3;          // 11

    reg                         clk, rst;
    reg                         valid_in;
    reg  [DATA_W-1:0]          pixel_in;
    wire signed [GRAD_W-1:0]   grad_x, grad_y;
    wire                        valid_out;

    sobel_gradient #(
        .DATA_W(DATA_W), .IMG_WIDTH(IMG_WIDTH), .GRAD_W(GRAD_W)
    ) uut (
        .clk(clk), .rst(rst),
        .valid_in(valid_in), .pixel_in(pixel_in),
        .grad_x(grad_x), .grad_y(grad_y), .valid_out(valid_out)
    );

    always #5 clk = ~clk;

    reg [DATA_W-1:0] stimuli [0:NUM_PIXELS-1];

    // Golden: Ix, Iy for 8x8 image with 200-square at (2,2)-(5,5)
    reg signed [GRAD_W-1:0] golden_ix [0:NUM_PIXELS-1];
    reg signed [GRAD_W-1:0] golden_iy [0:NUM_PIXELS-1];

    integer i, out_idx, any_fail;

    initial begin
        for (i = 0; i < NUM_PIXELS; i = i + 1) begin
            stimuli[i] = 0;
            golden_ix[i] = 0;
            golden_iy[i] = 0;
        end
        // Image: 200 square at (2,2)-(5,5)
        for (i = 0; i < 4; i = i + 1) begin
            stimuli[(2+i)*IMG_WIDTH+2] = 200; stimuli[(2+i)*IMG_WIDTH+3] = 200;
            stimuli[(2+i)*IMG_WIDTH+4] = 200; stimuli[(2+i)*IMG_WIDTH+5] = 200;
        end

        // Golden values verified against harris_corner top-level (128x128 all match)
        // Row 1 Ix
        golden_ix[9]=200; golden_ix[10]=200; golden_ix[13]=-200; golden_ix[14]=-200;
        // Row 2 Ix
        golden_ix[17]=600; golden_ix[18]=600; golden_ix[21]=-600; golden_ix[22]=-600;
        // Row 3 Ix
        golden_ix[25]=800; golden_ix[26]=800; golden_ix[29]=-800; golden_ix[30]=-800;
        // Row 4 Ix
        golden_ix[33]=800; golden_ix[34]=800; golden_ix[37]=-800; golden_ix[38]=-800;
        // Row 5 Ix
        golden_ix[41]=600; golden_ix[42]=600; golden_ix[45]=-600; golden_ix[46]=-600;
        // Row 6 Ix
        golden_ix[49]=200; golden_ix[50]=200; golden_ix[53]=-200; golden_ix[54]=-200;

        // Row 1 Iy
        golden_iy[9]=200; golden_iy[10]=600; golden_iy[11]=800; golden_iy[12]=800;
        golden_iy[13]=600; golden_iy[14]=200;
        // Row 2 Iy
        golden_iy[17]=200; golden_iy[18]=600; golden_iy[19]=800; golden_iy[20]=800;
        golden_iy[21]=600; golden_iy[22]=200;
        // Row 5 Iy
        golden_iy[41]=-200; golden_iy[42]=-600; golden_iy[43]=-800; golden_iy[44]=-800;
        golden_iy[45]=-600; golden_iy[46]=-200;
        // Row 6 Iy
        golden_iy[49]=-200; golden_iy[50]=-600; golden_iy[51]=-800; golden_iy[52]=-800;
        golden_iy[53]=-600; golden_iy[54]=-200;

        clk = 0; rst = 1; valid_in = 0; pixel_in = 0;
        any_fail = 0; out_idx = 0;

        #20 rst = 0;

        // Feed + flush
        for (i = 0; i < NUM_PIXELS + LATENCY - 1; i = i + 1) begin
            @(negedge clk);
            valid_in = 1;
            pixel_in = (i < NUM_PIXELS) ? stimuli[i] : 0;
            @(posedge clk); #1;
            if (valid_out) begin
                if (grad_x === golden_ix[out_idx] && grad_y === golden_iy[out_idx])
                    $display("Test %0d passed", out_idx);
                else begin
                    $display("Test %0d failed: Ix exp=%0d got=%0d, Iy exp=%0d got=%0d",
                             out_idx, golden_ix[out_idx], grad_x, golden_iy[out_idx], grad_y);
                    any_fail = 1;
                end
                out_idx = out_idx + 1;
            end
        end

        @(negedge clk); valid_in = 0;
        $display("[INFO] Total outputs: %0d (expected %0d)", out_idx, NUM_PIXELS);

        if (any_fail == 0 && out_idx == NUM_PIXELS)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end
endmodule
