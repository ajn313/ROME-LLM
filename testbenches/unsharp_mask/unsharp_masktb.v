`timescale 1ns/1ps

module unsharp_mask_tb;

    parameter PIXEL_W    = 8;
    parameter IMG_WIDTH  = 8;
    parameter IMG_HEIGHT = 8;
    parameter GAIN_W     = 8;
    parameter NUM_PIXELS = IMG_WIDTH * IMG_HEIGHT; // 64
    parameter LATENCY    = IMG_WIDTH + 3;          // 11

    reg                  clk, rst;
    reg  [PIXEL_W-1:0]  pixel_in;
    reg                  valid_in;
    reg  [GAIN_W-1:0]   gain;
    wire [PIXEL_W-1:0]  pixel_out;
    wire                 valid_out;

    unsharp_mask #(
        .IMG_WIDTH(IMG_WIDTH),
        .IMG_HEIGHT(IMG_HEIGHT),
        .PIXEL_W(PIXEL_W),
        .GAIN_W(GAIN_W)
    ) uut (
        .clk(clk), .rst(rst),
        .pixel_in(pixel_in), .valid_in(valid_in), .gain(gain),
        .pixel_out(pixel_out), .valid_out(valid_out)
    );

    always #5 clk = ~clk;

    reg [PIXEL_W-1:0] stimuli [0:NUM_PIXELS-1];
    reg [PIXEL_W-1:0] golden [0:NUM_PIXELS-1];

    integer i, out_idx, any_fail, lat_fail;

    initial begin
        // Initialize stimuli
        for (i = 0; i < NUM_PIXELS; i = i + 1) stimuli[i] = 0;
        stimuli[18] = 10; stimuli[19] = 20; stimuli[20] = 30;
        stimuli[26] = 40; stimuli[27] = 50; stimuli[28] = 60;
        stimuli[34] = 70; stimuli[35] = 80; stimuli[36] = 90;

        // Initialize golden (computed by formula: clamp(orig + gain*(orig - blur), 0, 255))
        for (i = 0; i < NUM_PIXELS; i = i + 1) golden[i] = 0;
        golden[18] =   4; golden[19] =  16; golden[20] =  50;
        golden[26] =  56; golden[27] =  50; golden[28] =  96;
        golden[34] = 140; golden[35] = 136; golden[36] = 184;

        clk      = 0;
        rst      = 1;
        valid_in = 0;
        pixel_in = 0;
        gain     = 8'd2;
        any_fail = 0;
        lat_fail = 0;
        out_idx  = 0;

        #20 rst = 0;

        // Phase 1: verify latency — feed first LATENCY pixels, valid_out must be 0
        for (i = 0; i < LATENCY; i = i + 1) begin
            @(negedge clk);
            valid_in = 1;
            pixel_in = stimuli[i];

            @(posedge clk);
            #1;
            if (valid_out) begin
                $display("Latency test failed: valid_out=1 at cycle %0d", i);
                lat_fail = 1;
            end
        end

        if (lat_fail == 0)
            $display("Latency test passed: valid_out=0 for first %0d cycles", LATENCY);
        else
            any_fail = 1;

        // Phase 2: feed remaining pixels + capture valid outputs
        for (i = LATENCY; i < NUM_PIXELS; i = i + 1) begin
            @(negedge clk);
            valid_in = 1;
            pixel_in = stimuli[i];

            @(posedge clk);
            #1;
            if (valid_out) begin
                if (pixel_out === golden[out_idx]) begin
                    $display("Test %0d passed", out_idx);
                end else begin
                    $display("Test %0d failed", out_idx);
                    $display("  Expected: %0d, Got: %0d", golden[out_idx], pixel_out);
                    any_fail = 1;
                end
                out_idx = out_idx + 1;
            end
        end

        // Phase 3: flush — feed zeros to drain pipeline
        for (i = 0; i < LATENCY; i = i + 1) begin
            @(negedge clk);
            valid_in = 1;
            pixel_in = 0;

            @(posedge clk);
            #1;
            if (valid_out) begin
                if (pixel_out === golden[out_idx]) begin
                    $display("Test %0d passed", out_idx);
                end else begin
                    $display("Test %0d failed", out_idx);
                    $display("  Expected: %0d, Got: %0d", golden[out_idx], pixel_out);
                    any_fail = 1;
                end
                out_idx = out_idx + 1;
            end
        end

        @(negedge clk);
        valid_in = 0;

        $display("[INFO] Total outputs verified: %0d (expected %0d)", out_idx, NUM_PIXELS);

        if (any_fail == 0 && out_idx == NUM_PIXELS)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule
