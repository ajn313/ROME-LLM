`timescale 1ns/1ps

module conv3d_tb;

    parameter K1=3, K2=3, K3=3;
    parameter D=4, H=4, W=4;
    parameter DATA_W=8;
    parameter OUT_W = DATA_W + 5;
    parameter N = D * H * W;
    parameter N_OUT = (D-K1+1) * (H-K2+1) * (W-K3+1); // 8
    parameter LATENCY = 2*H*W + W + 2;

    reg clk=0, rst, valid_in;
    reg [DATA_W-1:0] voxel_in;
    reg [K1*K2*K3*DATA_W-1:0] kernel;
    wire [OUT_W-1:0] voxel_out;
    wire valid_out;

    conv3d #(.K1(K1),.K2(K2),.K3(K3),.D(D),.H(H),.W(W),.DATA_W(DATA_W))
    uut (.clk(clk),.rst(rst),.voxel_in(voxel_in),.valid_in(valid_in),
         .kernel(kernel),.voxel_out(voxel_out),.valid_out(valid_out));

    always #5 clk = ~clk;

    reg [DATA_W-1:0] stimuli [0:N-1];
    reg [OUT_W-1:0] golden [0:N_OUT-1];

    integer i, out_idx, any_fail;

    initial begin
        // Volume: values 1..64
        for (i = 0; i < N; i = i + 1) stimuli[i] = i + 1;

        // All-ones kernel
        kernel = {27{8'd1}};

        // Golden (computed by formula)
        golden[0] = 594;  golden[1] = 621;
        golden[2] = 702;  golden[3] = 729;
        golden[4] = 1026; golden[5] = 1053;
        golden[6] = 1134; golden[7] = 1161;

        clk = 0; rst = 1; valid_in = 0; voxel_in = 0;
        any_fail = 0; out_idx = 0;

        #20 rst = 0;

        // Feed + flush
        for (i = 0; i < N + LATENCY; i = i + 1) begin
            @(negedge clk);
            valid_in = 1;
            voxel_in = (i < N) ? stimuli[i] : 0;

            @(posedge clk);
            #1;
            if (valid_out) begin
                if (voxel_out === golden[out_idx])
                    $display("Test %0d passed", out_idx);
                else begin
                    $display("Test %0d failed: expected=%0d got=%0d", out_idx, golden[out_idx], voxel_out);
                    any_fail = 1;
                end
                out_idx = out_idx + 1;
            end
        end

        @(negedge clk); valid_in = 0;
        $display("[INFO] Total outputs: %0d (expected %0d)", out_idx, N_OUT);

        if (any_fail == 0 && out_idx == N_OUT)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end
endmodule
