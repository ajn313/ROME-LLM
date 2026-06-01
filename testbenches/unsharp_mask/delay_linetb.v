`timescale 1ns/1ps

module delay_line_tb;

    parameter DATA_W = 8;
    parameter DEPTH  = 4;

    reg                clk, rst;
    reg                valid_in;
    reg  [DATA_W-1:0] data_in;
    wire [DATA_W-1:0] data_out;

    delay_line #(
        .DATA_W(DATA_W),
        .DEPTH(DEPTH)
    ) uut (
        .clk(clk), .rst(rst),
        .valid_in(valid_in),
        .data_in(data_in),
        .data_out(data_out)
    );

    always #5 clk = ~clk;

    integer any_fail;

    task check;
        input integer tnum;
        input [DATA_W-1:0] expected;
        begin
            if (data_out === expected) begin
                $display("Test %0d passed", tnum);
            end else begin
                $display("Test %0d failed", tnum);
                $display("  Expected: %0d, Got: %0d", expected, data_out);
                any_fail = 1;
            end
        end
    endtask

    initial begin
        clk = 0; rst = 1; valid_in = 0; data_in = 0; any_fail = 0;

        // Test 1: reset → output 0
        @(posedge clk); #1;
        check(1, 0);

        rst = 0;

        // Test 2: feed 10, output still 0 (depth=4, not through yet)
        valid_in = 1; data_in = 8'd10;
        @(posedge clk); #1;
        check(2, 0);

        // Test 3: feed 20
        data_in = 8'd20;
        @(posedge clk); #1;
        check(3, 0);

        // Test 4: feed 30
        data_in = 8'd30;
        @(posedge clk); #1;
        check(4, 0);

        // Test 5: feed 40 → output 10 (4 clk delay)
        data_in = 8'd40;
        @(posedge clk); #1;
        check(5, 10);

        // Test 6: feed 50 → output 20
        data_in = 8'd50;
        @(posedge clk); #1;
        check(6, 20);

        // Test 7: valid_in=0 → hold (no shift, output stays 20)
        valid_in = 0; data_in = 8'd99;
        @(posedge clk); #1;
        check(7, 20);

        // Test 8: re-enable → one shift, output 30
        valid_in = 1; data_in = 8'd60;
        @(posedge clk); #1;
        check(8, 30);

        if (any_fail == 0)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule
