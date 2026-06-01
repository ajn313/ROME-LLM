`timescale 1ns/1ps

module conv1d_tb;

    parameter DATA_W      = 8;
    parameter KERNEL_SIZE = 5;
    parameter GAIN_W      = 4;
    parameter NUM_SAMPLES = 16;

    reg                      clk, rst;
    reg                      valid_in;
    reg  [DATA_W-1:0]       data_in;
    wire                     valid_out;
    wire [DATA_W+GAIN_W-1:0] data_out;

    conv1d #(
        .DATA_W(DATA_W),
        .KERNEL_SIZE(KERNEL_SIZE),
        .GAIN_W(GAIN_W)
    ) uut (
        .clk(clk), .rst(rst),
        .valid_in(valid_in), .data_in(data_in),
        .valid_out(valid_out), .data_out(data_out)
    );

    always #5 clk = ~clk;

    reg [DATA_W-1:0] stimuli [0:NUM_SAMPLES-1];
    reg [DATA_W+GAIN_W-1:0] golden [0:NUM_SAMPLES-1];

    integer i, out_idx, any_fail;

    initial begin
        // Input samples
        stimuli[0]  = 128; stimuli[1]  = 177; stimuli[2]  = 218; stimuli[3]  = 245;
        stimuli[4]  = 255; stimuli[5]  = 245; stimuli[6]  = 218; stimuli[7]  = 177;
        stimuli[8]  = 128; stimuli[9]  =  79; stimuli[10] =  38; stimuli[11] =  11;
        stimuli[12] =   1; stimuli[13] =  11; stimuli[14] =  38; stimuli[15] =  79;

        golden[0]  =  16; golden[1]  =  86; golden[2]  = 211; golden[3]  = 336;
        golden[4]  = 422; golden[5]  = 473; golden[6]  = 490; golden[7]  = 473;
        golden[8]  = 422; golden[9]  = 346; golden[10] = 256; golden[11] = 165;
        golden[12] =  89; golden[13] =  39; golden[14] =  21; golden[15] =  39;

        clk      = 0;
        rst      = 1;
        valid_in = 0;
        data_in  = 0;
        any_fail = 0;
        out_idx  = 0;

        #20 rst = 0;

        // Feed all 16 samples (negedge input, posedge capture)
        for (i = 0; i < NUM_SAMPLES; i = i + 1) begin
            @(negedge clk);
            valid_in = 1;
            data_in  = stimuli[i];

            @(posedge clk);
            #1;
            if (valid_out) begin
                if (data_out === golden[out_idx]) begin
                    $display("Test %0d passed", out_idx);
                end else begin
                    $display("Test %0d failed", out_idx);
                    $display("  Expected: %0d, Got: %0d", golden[out_idx], data_out);
                    any_fail = 1;
                end
                out_idx = out_idx + 1;
            end
        end

        @(negedge clk);
        valid_in = 0;
        data_in  = 0;

        @(posedge clk);
        #1;
        if (valid_out) begin
            if (data_out === golden[out_idx]) begin
                $display("Test %0d passed", out_idx);
            end else begin
                $display("Test %0d failed", out_idx);
                $display("  Expected: %0d, Got: %0d", golden[out_idx], data_out);
                any_fail = 1;
            end
            out_idx = out_idx + 1;
        end

        $display("[INFO] Total outputs verified: %0d (expected %0d)", out_idx, NUM_SAMPLES);

        if (any_fail == 0 && out_idx == NUM_SAMPLES)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule
