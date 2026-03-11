`timescale 1ns / 1ps

module input_buffer_b_tb;

  reg clk;
  reg rst;
  reg load;
  reg en;

  reg [15:0] b00;
  reg [15:0] b01;
  reg [15:0] b02;
  reg [15:0] b03;
  reg [15:0] b10;
  reg [15:0] b11;
  reg [15:0] b12;
  reg [15:0] b13;
  reg [15:0] b20;
  reg [15:0] b21;
  reg [15:0] b22;
  reg [15:0] b23;
  reg [15:0] b30;
  reg [15:0] b31;
  reg [15:0] b32;
  reg [15:0] b33;

  wire [15:0] b0_out;
  wire [15:0] b1_out;
  wire [15:0] b2_out;
  wire [15:0] b3_out;

  integer failures;
  reg [15:0] prev_b0_out;
  reg [15:0] prev_b1_out;
  reg [15:0] prev_b2_out;
  reg [15:0] prev_b3_out;

  input_buffer_b uut (
    .clk(clk),
    .rst(rst),
    .load(load),
    .b00(b00),
    .b01(b01),
    .b02(b02),
    .b03(b03),
    .b10(b10),
    .b11(b11),
    .b12(b12),
    .b13(b13),
    .b20(b20),
    .b21(b21),
    .b22(b22),
    .b23(b23),
    .b30(b30),
    .b31(b31),
    .b32(b32),
    .b33(b33),
    .en(en),
    .b0_out(b0_out),
    .b1_out(b1_out),
    .b2_out(b2_out),
    .b3_out(b3_out)
  );

  always #5 clk = ~clk;

  task check_outputs;
    input integer test_num;
    input [15:0] exp_b0_out;
    input [15:0] exp_b1_out;
    input [15:0] exp_b2_out;
    input [15:0] exp_b3_out;
    begin
      if ((b0_out === exp_b0_out) &&
          (b1_out === exp_b1_out) &&
          (b2_out === exp_b2_out) &&
          (b3_out === exp_b3_out)) begin
        $display("Test %0d passed", test_num);
      end else begin
        $display("Test %0d failed", test_num);
        $display("  Expected: b0_out=%0d b1_out=%0d b2_out=%0d b3_out=%0d",
                 exp_b0_out, exp_b1_out, exp_b2_out, exp_b3_out);
        $display("  Actual:   b0_out=%0d b1_out=%0d b2_out=%0d b3_out=%0d",
                 b0_out, b1_out, b2_out, b3_out);
        failures = failures + 1;
      end
    end
  endtask

  task save_outputs;
    begin
      prev_b0_out = b0_out;
      prev_b1_out = b1_out;
      prev_b2_out = b2_out;
      prev_b3_out = b3_out;
    end
  endtask

  task check_hold;
    input integer test_num;
    begin
      if ((b0_out === prev_b0_out) &&
          (b1_out === prev_b1_out) &&
          (b2_out === prev_b2_out) &&
          (b3_out === prev_b3_out)) begin
        $display("Test %0d passed", test_num);
      end else begin
        $display("Test %0d failed", test_num);
        $display("  Expected outputs to hold while en=0");
        failures = failures + 1;
      end
    end
  endtask

  initial begin
    failures = 0;
    clk = 0;
    rst = 0;
    load = 0;
    en = 0;

    b00 = 16'd1;  b01 = 16'd2;  b02 = 16'd3;  b03 = 16'd4;
    b10 = 16'd5;  b11 = 16'd6;  b12 = 16'd7;  b13 = 16'd8;
    b20 = 16'd9;  b21 = 16'd10; b22 = 16'd11; b23 = 16'd12;
    b30 = 16'd13; b31 = 16'd14; b32 = 16'd15; b33 = 16'd16;

    // Test 1: Reset clears outputs
    rst = 1;
    @(posedge clk);
    #1;
    check_outputs(1, 16'd0, 16'd0, 16'd0, 16'd0);

    // Release reset and load matrix
    rst = 0;
    load = 1;
    @(posedge clk);
    #1;
    load = 0;

    // Test 2: With en low, outputs should remain idle/hold at zero
    @(posedge clk);
    #1;
    check_outputs(2, 16'd0, 16'd0, 16'd0, 16'd0);

    // Test 3: First streamed set
    en = 1;
    @(posedge clk);
    #1;
    check_outputs(3, 16'd1, 16'd2, 16'd3, 16'd4);

    // Test 4: Second streamed set
    @(posedge clk);
    #1;
    check_outputs(4, 16'd5, 16'd6, 16'd7, 16'd8);

    // Test 5: Third streamed set
    @(posedge clk);
    #1;
    check_outputs(5, 16'd9, 16'd10, 16'd11, 16'd12);

    // Test 6: Fourth streamed set
    @(posedge clk);
    #1;
    check_outputs(6, 16'd13, 16'd14, 16'd15, 16'd16);

    // Test 7: Disable should hold outputs
    save_outputs();
    en = 0;
    @(posedge clk);
    #1;
    check_hold(7);

    // Test 8: Reset after activity clears outputs again
    rst = 1;
    @(posedge clk);
    #1;
    check_outputs(8, 16'd0, 16'd0, 16'd0, 16'd0);

    if (failures == 0)
      $display("All tests passed!");
    else
      $display("Some tests failed");

    $finish;
  end

endmodule