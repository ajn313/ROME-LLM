`timescale 1ns / 1ps

module pe_tb;

  reg clk;
  reg rst;
  reg en;
  reg [15:0] a_in;
  reg [15:0] b_in;

  wire [15:0] a_out;
  wire [15:0] b_out;
  wire [31:0] psum_out;

  integer failures;

  pe uut (
    .clk(clk),
    .rst(rst),
    .en(en),
    .a_in(a_in),
    .b_in(b_in),
    .a_out(a_out),
    .b_out(b_out),
    .psum_out(psum_out)
  );

  always #5 clk = ~clk;

  task check_outputs;
    input integer test_num;
    input [15:0] expected_a_out;
    input [15:0] expected_b_out;
    input [31:0] expected_psum_out;
    begin
      if ((a_out === expected_a_out) &&
          (b_out === expected_b_out) &&
          (psum_out === expected_psum_out)) begin
        $display("Test %0d passed", test_num);
      end else begin
        $display("Test %0d failed", test_num);
        $display("  Expected: a_out=%0d, b_out=%0d, psum_out=%0d", expected_a_out, expected_b_out, expected_psum_out);
        $display("  Actual:   a_out=%0d, b_out=%0d, psum_out=%0d", a_out, b_out, psum_out);
        failures = failures + 1;
      end
    end
  endtask

  initial begin
    failures = 0;
    clk = 0;
    rst = 0;
    en = 0;
    a_in = 0;
    b_in = 0;

    // Test 1: Reset clears outputs
    rst = 1;
    @(posedge clk);
    #1;
    check_outputs(1, 16'd0, 16'd0, 32'd0);

    // Release reset
    rst = 0;

    // Test 2: First multiply-accumulate
    en = 1;
    a_in = 16'd3;
    b_in = 16'd4;
    @(posedge clk);
    #1;
    check_outputs(2, 16'd3, 16'd4, 32'd12);

    // Test 3: Second multiply-accumulate accumulates correctly
    a_in = 16'd2;
    b_in = 16'd5;
    @(posedge clk);
    #1;
    check_outputs(3, 16'd2, 16'd5, 32'd22);

    // Test 4: Zero input still propagates and accumulator holds arithmetic result
    a_in = 16'd0;
    b_in = 16'd9;
    @(posedge clk);
    #1;
    check_outputs(4, 16'd0, 16'd9, 32'd22);

    // Test 5: Disabled PE holds previous values
    en = 0;
    a_in = 16'd7;
    b_in = 16'd8;
    @(posedge clk);
    #1;
    check_outputs(5, 16'd0, 16'd9, 32'd22);

    // Test 6: Re-enable and continue accumulation
    en = 1;
    a_in = 16'd1;
    b_in = 16'd10;
    @(posedge clk);
    #1;
    check_outputs(6, 16'd1, 16'd10, 32'd32);

    // Test 7: Reset after activity clears everything again
    rst = 1;
    @(posedge clk);
    #1;
    check_outputs(7, 16'd0, 16'd0, 32'd0);

    if (failures == 0)
      $display("All tests passed!");
    else
      $display("Some tests failed");

    $finish;
  end

endmodule