`timescale 1ns / 1ps

module input_buffer_a_tb;

  reg clk;
  reg rst;
  reg load;
  reg en;

  reg [15:0] a00;
  reg [15:0] a01;
  reg [15:0] a02;
  reg [15:0] a03;
  reg [15:0] a10;
  reg [15:0] a11;
  reg [15:0] a12;
  reg [15:0] a13;
  reg [15:0] a20;
  reg [15:0] a21;
  reg [15:0] a22;
  reg [15:0] a23;
  reg [15:0] a30;
  reg [15:0] a31;
  reg [15:0] a32;
  reg [15:0] a33;

  wire [15:0] a0_out;
  wire [15:0] a1_out;
  wire [15:0] a2_out;
  wire [15:0] a3_out;

  integer failures;
  reg [15:0] prev_a0_out;
  reg [15:0] prev_a1_out;
  reg [15:0] prev_a2_out;
  reg [15:0] prev_a3_out;

  input_buffer_a uut (
    .clk(clk),
    .rst(rst),
    .load(load),
    .a00(a00),
    .a01(a01),
    .a02(a02),
    .a03(a03),
    .a10(a10),
    .a11(a11),
    .a12(a12),
    .a13(a13),
    .a20(a20),
    .a21(a21),
    .a22(a22),
    .a23(a23),
    .a30(a30),
    .a31(a31),
    .a32(a32),
    .a33(a33),
    .en(en),
    .a0_out(a0_out),
    .a1_out(a1_out),
    .a2_out(a2_out),
    .a3_out(a3_out)
  );

  always #5 clk = ~clk;

  task check_outputs;
    input integer test_num;
    input [15:0] exp_a0_out;
    input [15:0] exp_a1_out;
    input [15:0] exp_a2_out;
    input [15:0] exp_a3_out;
    begin
      if ((a0_out === exp_a0_out) &&
          (a1_out === exp_a1_out) &&
          (a2_out === exp_a2_out) &&
          (a3_out === exp_a3_out)) begin
        $display("Test %0d passed", test_num);
      end else begin
        $display("Test %0d failed", test_num);
        $display("  Expected: a0_out=%0d a1_out=%0d a2_out=%0d a3_out=%0d",
                 exp_a0_out, exp_a1_out, exp_a2_out, exp_a3_out);
        $display("  Actual:   a0_out=%0d a1_out=%0d a2_out=%0d a3_out=%0d",
                 a0_out, a1_out, a2_out, a3_out);
        failures = failures + 1;
      end
    end
  endtask

  task save_outputs;
    begin
      prev_a0_out = a0_out;
      prev_a1_out = a1_out;
      prev_a2_out = a2_out;
      prev_a3_out = a3_out;
    end
  endtask

  task check_hold;
    input integer test_num;
    begin
      if ((a0_out === prev_a0_out) &&
          (a1_out === prev_a1_out) &&
          (a2_out === prev_a2_out) &&
          (a3_out === prev_a3_out)) begin
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

    a00 = 16'd1;  a01 = 16'd2;  a02 = 16'd3;  a03 = 16'd4;
    a10 = 16'd5;  a11 = 16'd6;  a12 = 16'd7;  a13 = 16'd8;
    a20 = 16'd9;  a21 = 16'd10; a22 = 16'd11; a23 = 16'd12;
    a30 = 16'd13; a31 = 16'd14; a32 = 16'd15; a33 = 16'd16;

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
    check_outputs(3, 16'd1, 16'd5, 16'd9, 16'd13);

    // Test 4: Second streamed set
    @(posedge clk);
    #1;
    check_outputs(4, 16'd2, 16'd6, 16'd10, 16'd14);

    // Test 5: Third streamed set
    @(posedge clk);
    #1;
    check_outputs(5, 16'd3, 16'd7, 16'd11, 16'd15);

    // Test 6: Fourth streamed set
    @(posedge clk);
    #1;
    check_outputs(6, 16'd4, 16'd8, 16'd12, 16'd16);

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