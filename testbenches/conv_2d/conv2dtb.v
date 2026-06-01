`timescale 1ns/1ps

module conv2d_tb;

    parameter DATA_W      = 8;
    parameter IMG_WIDTH   = 8;
    parameter KERNEL_SIZE = 3;
    parameter GAIN_W      = 4;
    parameter NUM_PIXELS  = IMG_WIDTH * IMG_WIDTH; // 64
    parameter LATENCY     = IMG_WIDTH + 2;         // 10
    parameter OUT_W_VALID = IMG_WIDTH - KERNEL_SIZE + 1; // 6
    parameter NUM_VALID   = OUT_W_VALID * OUT_W_VALID;   // 36

    reg                      clk, rst;
    reg                      valid_in;
    reg  [DATA_W-1:0]       pixel_in;

    wire                     valid_out_z;
    wire [DATA_W+GAIN_W-1:0] pixel_out_z;

    conv2d #(
        .DATA_W(DATA_W), .IMG_WIDTH(IMG_WIDTH),
        .KERNEL_SIZE(KERNEL_SIZE), .GAIN_W(GAIN_W),
        .PADDING_MODE(0)
    ) uut_zero (
        .clk(clk), .rst(rst),
        .valid_in(valid_in), .pixel_in(pixel_in),
        .valid_out(valid_out_z), .pixel_out(pixel_out_z)
    );

    wire                     valid_out_v;
    wire [DATA_W+GAIN_W-1:0] pixel_out_v;

    conv2d #(
        .DATA_W(DATA_W), .IMG_WIDTH(IMG_WIDTH),
        .KERNEL_SIZE(KERNEL_SIZE), .GAIN_W(GAIN_W),
        .PADDING_MODE(1)
    ) uut_valid (
        .clk(clk), .rst(rst),
        .valid_in(valid_in), .pixel_in(pixel_in),
        .valid_out(valid_out_v), .pixel_out(pixel_out_v)
    );

    always #5 clk = ~clk;

    reg [DATA_W-1:0] stimuli [0:NUM_PIXELS-1];

    reg [DATA_W+GAIN_W-1:0] golden_z [0:NUM_PIXELS-1];

    reg [DATA_W+GAIN_W-1:0] golden_v [0:NUM_VALID-1];

    integer i, out_idx_z, out_idx_v, any_fail, lat_fail_z, lat_fail_v;

    initial begin
        // Initialize stimuli
        for (i = 0; i < NUM_PIXELS; i = i + 1) stimuli[i] = 0;
        stimuli[18] = 10; stimuli[19] = 20; stimuli[20] = 30;
        stimuli[26] = 40; stimuli[27] = 50; stimuli[28] = 60;
        stimuli[34] = 70; stimuli[35] = 80; stimuli[36] = 90;

        for (i = 0; i < NUM_PIXELS; i = i + 1) golden_z[i] = 0;
        golden_z[10] =  2; golden_z[11] =  5; golden_z[12] =  5; golden_z[13] =  1;
        golden_z[17] =  3; golden_z[18] = 13; golden_z[19] = 22; golden_z[20] = 20; golden_z[21] =  7;
        golden_z[25] = 10; golden_z[26] = 32; golden_z[27] = 50; golden_z[28] = 42; golden_z[29] = 15;
        golden_z[33] = 11; golden_z[34] = 35; golden_z[35] = 52; golden_z[36] = 43; golden_z[37] = 15;
        golden_z[41] =  4; golden_z[42] = 13; golden_z[43] = 20; golden_z[44] = 16; golden_z[45] =  5;

        for (i = 0; i < NUM_VALID; i = i + 1) golden_v[i] = 0;
        golden_v[1]  =  2; golden_v[2]  =  5; golden_v[3]  =  5; golden_v[4]  =  1;
        golden_v[6]  =  3; golden_v[7]  = 13; golden_v[8]  = 22; golden_v[9]  = 20; golden_v[10] =  7;
        golden_v[12] = 10; golden_v[13] = 32; golden_v[14] = 50; golden_v[15] = 42; golden_v[16] = 15;
        golden_v[18] = 11; golden_v[19] = 35; golden_v[20] = 52; golden_v[21] = 43; golden_v[22] = 15;
        golden_v[24] =  4; golden_v[25] = 13; golden_v[26] = 20; golden_v[27] = 16; golden_v[28] =  5;

        clk        = 0;
        rst        = 1;
        valid_in   = 0;
        pixel_in   = 0;
        any_fail   = 0;
        lat_fail_z = 0;
        lat_fail_v = 0;
        out_idx_z  = 0;
        out_idx_v  = 0;

        #20 rst = 0;

        // Phase 1: verify latency for both modes
        for (i = 0; i < LATENCY; i = i + 1) begin
            @(negedge clk);
            valid_in = 1;
            pixel_in = stimuli[i];

            @(posedge clk);
            #1;
            if (valid_out_z) begin
                $display("Zero-pad latency test failed at cycle %0d", i);
                lat_fail_z = 1;
            end
            if (valid_out_v) begin
                $display("Valid latency test failed at cycle %0d", i);
                lat_fail_v = 1;
            end
        end

        if (lat_fail_z == 0)
            $display("[ZERO] Latency test passed: valid_out=0 for first %0d cycles", LATENCY);
        else
            any_fail = 1;

        if (lat_fail_v == 0)
            $display("[VALID] Latency test passed: valid_out=0 for first %0d cycles", LATENCY);
        else
            any_fail = 1;

        // Phase 2: feed remaining pixels + capture
        for (i = LATENCY; i < NUM_PIXELS; i = i + 1) begin
            @(negedge clk);
            valid_in = 1;
            pixel_in = stimuli[i];

            @(posedge clk);
            #1;

            if (valid_out_z) begin
                if (pixel_out_z === golden_z[out_idx_z])
                    $display("[ZERO] Test %0d passed", out_idx_z);
                else begin
                    $display("[ZERO] Test %0d failed: expected=%0d got=%0d", out_idx_z, golden_z[out_idx_z], pixel_out_z);
                    any_fail = 1;
                end
                out_idx_z = out_idx_z + 1;
            end

            if (valid_out_v) begin
                if (pixel_out_v === golden_v[out_idx_v])
                    $display("[VALID] Test %0d passed", out_idx_v);
                else begin
                    $display("[VALID] Test %0d failed: expected=%0d got=%0d", out_idx_v, golden_v[out_idx_v], pixel_out_v);
                    any_fail = 1;
                end
                out_idx_v = out_idx_v + 1;
            end
        end

        // Phase 3: flush
        for (i = 0; i < LATENCY; i = i + 1) begin
            @(negedge clk);
            valid_in = 1;
            pixel_in = 0;

            @(posedge clk);
            #1;

            if (valid_out_z) begin
                if (pixel_out_z === golden_z[out_idx_z])
                    $display("[ZERO] Test %0d passed", out_idx_z);
                else begin
                    $display("[ZERO] Test %0d failed: expected=%0d got=%0d", out_idx_z, golden_z[out_idx_z], pixel_out_z);
                    any_fail = 1;
                end
                out_idx_z = out_idx_z + 1;
            end

            if (valid_out_v) begin
                if (pixel_out_v === golden_v[out_idx_v])
                    $display("[VALID] Test %0d passed", out_idx_v);
                else begin
                    $display("[VALID] Test %0d failed: expected=%0d got=%0d", out_idx_v, golden_v[out_idx_v], pixel_out_v);
                    any_fail = 1;
                end
                out_idx_v = out_idx_v + 1;
            end
        end

        @(negedge clk);
        valid_in = 0;

        $display("[ZERO]  Total outputs: %0d (expected %0d)", out_idx_z, NUM_PIXELS);
        $display("[VALID] Total outputs: %0d (expected %0d)", out_idx_v, NUM_VALID);

        if (any_fail == 0 && out_idx_z == NUM_PIXELS && out_idx_v == NUM_VALID)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule
