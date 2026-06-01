`timescale 1ns/1ps

module pointwise_sharpen_tb;

    parameter PIXEL_W = 8;
    parameter GAIN_W  = 8;

    reg  [PIXEL_W-1:0] original;
    reg  [PIXEL_W-1:0] blurred;
    reg  [GAIN_W-1:0]  gain;
    wire [PIXEL_W-1:0] result;

    pointwise_sharpen #(
        .PIXEL_W(PIXEL_W),
        .GAIN_W(GAIN_W)
    ) uut (
        .original(original),
        .blurred(blurred),
        .gain(gain),
        .result(result)
    );

    integer any_fail;

    task check;
        input integer tnum;
        input [PIXEL_W-1:0] expected;
        begin
            #1;
            if (result === expected) begin
                $display("Test %0d passed", tnum);
            end else begin
                $display("Test %0d failed", tnum);
                $display("  Expected: %0d, Got: %0d", expected, result);
                any_fail = 1;
            end
        end
    endtask

    initial begin
        any_fail = 0;

        // Test 1: no sharpening (original == blurred)
        original = 100; blurred = 100; gain = 2;
        check(1, 100);

        // Test 2: mild sharpening
        original = 100; blurred = 80; gain = 2;
        check(2, 140);

        // Test 3: clamp high (overflow to 255)
        original = 200; blurred = 100; gain = 2;
        check(3, 255);

        // Test 4: clamp low (underflow to 0)
        original = 50; blurred = 100; gain = 2;
        check(4, 0);

        // Test 5: gain=0 (no effect)
        original = 200; blurred = 100; gain = 0;
        check(5, 200);

        // Test 6: gain=1
        original = 80; blurred = 50; gain = 1;
        check(6, 110);

        // Test 7: all zeros
        original = 0; blurred = 0; gain = 2;
        check(7, 0);

        // Test 8: from conv2d golden — pixel(3,3) in 8x8 test image
        original = 50; blurred = 50; gain = 2;
        check(8, 50);

        if (any_fail == 0)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule
