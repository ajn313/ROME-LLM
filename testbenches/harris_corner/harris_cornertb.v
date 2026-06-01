`timescale 1ns/1ps

module harris_corner_tb;

    parameter PIXEL_W    = 8;
    parameter IMG_WIDTH  = 8;
    parameter IMG_HEIGHT = 8;
    parameter GRAD_W     = 16;
    parameter RESP_W     = 32;
    parameter K_W        = 8;
    parameter NUM_PIXELS = IMG_WIDTH * IMG_HEIGHT; // 64
    parameter LATENCY    = 2 * (IMG_WIDTH + 3);    // 22

    reg                    clk, rst;
    reg  [PIXEL_W-1:0]    pixel_in;
    reg                    valid_in;
    reg  signed [RESP_W-1:0] threshold;
    reg  [K_W-1:0]        k_param;
    wire                   is_corner;
    wire                   valid_out;

    harris_corner #(
        .IMG_WIDTH(IMG_WIDTH), .IMG_HEIGHT(IMG_HEIGHT),
        .PIXEL_W(PIXEL_W), .GRAD_W(GRAD_W), .RESP_W(RESP_W), .K_W(K_W)
    ) uut (
        .clk(clk), .rst(rst),
        .pixel_in(pixel_in), .valid_in(valid_in),
        .threshold(threshold), .k_param(k_param),
        .is_corner(is_corner), .valid_out(valid_out)
    );

    always #5 clk = ~clk;

    reg [PIXEL_W-1:0] stimuli [0:NUM_PIXELS-1];
    reg               golden [0:NUM_PIXELS-1];

    integer i, out_idx, any_fail, lat_fail;

    initial begin
        // Stimuli: 4x4 bright square (200) at (2,2)-(5,5) on black background
        for (i = 0; i < NUM_PIXELS; i = i + 1) stimuli[i] = 0;
        for (i = 0; i < 4; i = i + 1) begin
            stimuli[(2+i)*IMG_WIDTH + 2] = 200;
            stimuli[(2+i)*IMG_WIDTH + 3] = 200;
            stimuli[(2+i)*IMG_WIDTH + 4] = 200;
            stimuli[(2+i)*IMG_WIDTH + 5] = 200;
        end

        // Golden: computed by formula (k=5/64, threshold=1000)
        for (i = 0; i < NUM_PIXELS; i = i + 1) golden[i] = 0;
        // Row 1
        golden[9]  = 1; golden[10] = 1; golden[13] = 1; golden[14] = 1;
        // Row 2
        golden[17] = 1; golden[18] = 1; golden[19] = 1; golden[20] = 1; golden[21] = 1; golden[22] = 1;
        // Row 3
        golden[26] = 1; golden[27] = 1; golden[28] = 1; golden[29] = 1;
        // Row 4
        golden[34] = 1; golden[35] = 1; golden[36] = 1; golden[37] = 1;
        // Row 5
        golden[41] = 1; golden[42] = 1; golden[43] = 1; golden[44] = 1; golden[45] = 1; golden[46] = 1;
        // Row 6
        golden[49] = 1; golden[50] = 1; golden[53] = 1; golden[54] = 1;

        clk       = 0;
        rst       = 1;
        valid_in  = 0;
        pixel_in  = 0;
        threshold = 32'd1000;
        k_param   = 8'd5;
        any_fail  = 0;
        lat_fail  = 0;
        out_idx   = 0;

        #20 rst = 0;

        // Phase 1: verify latency
        for (i = 0; i < LATENCY; i = i + 1) begin
            @(negedge clk);
            valid_in = 1;
            pixel_in = (i < NUM_PIXELS) ? stimuli[i] : 0;

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

        // Phase 2: feed remaining pixels + capture
        for (i = LATENCY; i < NUM_PIXELS; i = i + 1) begin
            @(negedge clk);
            valid_in = 1;
            pixel_in = stimuli[i];

            @(posedge clk);
            #1;
            if (valid_out) begin
                if (is_corner === golden[out_idx]) begin
                    $display("Test %0d passed", out_idx);
                end else begin
                    $display("Test %0d failed", out_idx);
                    $display("  Expected: %0d, Got: %0d", golden[out_idx], is_corner);
                    any_fail = 1;
                end
                out_idx = out_idx + 1;
            end
        end

        // Phase 3: flush
        for (i = 0; i < LATENCY; i = i + 1) begin
            @(negedge clk);
            valid_in = 1;
            pixel_in = 0;

            @(posedge clk);
            #1;
            if (valid_out) begin
                if (is_corner === golden[out_idx]) begin
                    $display("Test %0d passed", out_idx);
                end else begin
                    $display("Test %0d failed", out_idx);
                    $display("  Expected: %0d, Got: %0d", golden[out_idx], is_corner);
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
