`timescale 1ns / 1ps

module systolic_core_4x4_tb;

  reg clk;
  reg rst;
  reg en;

  reg [15:0] a0_in;
  reg [15:0] a1_in;
  reg [15:0] a2_in;
  reg [15:0] a3_in;

  reg [15:0] b0_in;
  reg [15:0] b1_in;
  reg [15:0] b2_in;
  reg [15:0] b3_in;

  wire [31:0] c00;
  wire [31:0] c01;
  wire [31:0] c02;
  wire [31:0] c03;
  wire [31:0] c10;
  wire [31:0] c11;
  wire [31:0] c12;
  wire [31:0] c13;
  wire [31:0] c20;
  wire [31:0] c21;
  wire [31:0] c22;
  wire [31:0] c23;
  wire [31:0] c30;
  wire [31:0] c31;
  wire [31:0] c32;
  wire [31:0] c33;

  reg [31:0] prev_c00;
  reg [31:0] prev_c01;
  reg [31:0] prev_c02;
  reg [31:0] prev_c03;
  reg [31:0] prev_c10;
  reg [31:0] prev_c11;
  reg [31:0] prev_c12;
  reg [31:0] prev_c13;
  reg [31:0] prev_c20;
  reg [31:0] prev_c21;
  reg [31:0] prev_c22;
  reg [31:0] prev_c23;
  reg [31:0] prev_c30;
  reg [31:0] prev_c31;
  reg [31:0] prev_c32;
  reg [31:0] prev_c33;

  integer failures;

  systolic_core_4x4 uut (
    .clk(clk),
    .rst(rst),
    .en(en),
    .a0_in(a0_in),
    .a1_in(a1_in),
    .a2_in(a2_in),
    .a3_in(a3_in),
    .b0_in(b0_in),
    .b1_in(b1_in),
    .b2_in(b2_in),
    .b3_in(b3_in),
    .c00(c00),
    .c01(c01),
    .c02(c02),
    .c03(c03),
    .c10(c10),
    .c11(c11),
    .c12(c12),
    .c13(c13),
    .c20(c20),
    .c21(c21),
    .c22(c22),
    .c23(c23),
    .c30(c30),
    .c31(c31),
    .c32(c32),
    .c33(c33)
  );

  always #5 clk = ~clk;

  task check_all_zero;
    input integer test_num;
    begin
      if ((c00 === 32'd0) && (c01 === 32'd0) && (c02 === 32'd0) && (c03 === 32'd0) &&
          (c10 === 32'd0) && (c11 === 32'd0) && (c12 === 32'd0) && (c13 === 32'd0) &&
          (c20 === 32'd0) && (c21 === 32'd0) && (c22 === 32'd0) && (c23 === 32'd0) &&
          (c30 === 32'd0) && (c31 === 32'd0) && (c32 === 32'd0) && (c33 === 32'd0)) begin
        $display("Test %0d passed", test_num);
      end else begin
        $display("Test %0d failed", test_num);
        $display("  Expected all outputs to be zero");
        $display("  Actual c00=%0d c01=%0d c02=%0d c03=%0d", c00, c01, c02, c03);
        $display("         c10=%0d c11=%0d c12=%0d c13=%0d", c10, c11, c12, c13);
        $display("         c20=%0d c21=%0d c22=%0d c23=%0d", c20, c21, c22, c23);
        $display("         c30=%0d c31=%0d c32=%0d c33=%0d", c30, c31, c32, c33);
        failures = failures + 1;
      end
    end
  endtask

  task save_outputs;
    begin
      prev_c00 = c00; prev_c01 = c01; prev_c02 = c02; prev_c03 = c03;
      prev_c10 = c10; prev_c11 = c11; prev_c12 = c12; prev_c13 = c13;
      prev_c20 = c20; prev_c21 = c21; prev_c22 = c22; prev_c23 = c23;
      prev_c30 = c30; prev_c31 = c31; prev_c32 = c32; prev_c33 = c33;
    end
  endtask

  task check_hold;
    input integer test_num;
    begin
      if ((c00 === prev_c00) && (c01 === prev_c01) && (c02 === prev_c02) && (c03 === prev_c03) &&
          (c10 === prev_c10) && (c11 === prev_c11) && (c12 === prev_c12) && (c13 === prev_c13) &&
          (c20 === prev_c20) && (c21 === prev_c21) && (c22 === prev_c22) && (c23 === prev_c23) &&
          (c30 === prev_c30) && (c31 === prev_c31) && (c32 === prev_c32) && (c33 === prev_c33)) begin
        $display("Test %0d passed", test_num);
      end else begin
        $display("Test %0d failed", test_num);
        $display("  Expected outputs to hold when en=0");
        failures = failures + 1;
      end
    end
  endtask

  task check_any_nonzero;
    input integer test_num;
    begin
      if ((c00 !== 32'd0) || (c01 !== 32'd0) || (c02 !== 32'd0) || (c03 !== 32'd0) ||
          (c10 !== 32'd0) || (c11 !== 32'd0) || (c12 !== 32'd0) || (c13 !== 32'd0) ||
          (c20 !== 32'd0) || (c21 !== 32'd0) || (c22 !== 32'd0) || (c23 !== 32'd0) ||
          (c30 !== 32'd0) || (c31 !== 32'd0) || (c32 !== 32'd0) || (c33 !== 32'd0)) begin
        $display("Test %0d passed", test_num);
      end else begin
        $display("Test %0d failed", test_num);
        $display("  Expected at least one nonzero output after active stimulus");
        failures = failures + 1;
      end
    end
  endtask

  task clear_inputs;
    begin
      a0_in = 16'd0; a1_in = 16'd0; a2_in = 16'd0; a3_in = 16'd0;
      b0_in = 16'd0; b1_in = 16'd0; b2_in = 16'd0; b3_in = 16'd0;
    end
  endtask

  initial begin
    failures = 0;
    clk = 0;
    rst = 0;
    en = 0;
    clear_inputs();

    // Test 1: Reset clears all outputs
    rst = 1;
    @(posedge clk);
    #1;
    check_all_zero(1);

    // Test 2: With enable high but zero inputs, outputs remain zero
    rst = 0;
    en = 1;
    clear_inputs();
    repeat (4) begin
      @(posedge clk);
    end
    #1;
    check_all_zero(2);

    // Test 3: Single active lane pair should produce some nonzero activity
    // Stimulate only row/column 0 path
    a0_in = 16'd3;
    a1_in = 16'd0;
    a2_in = 16'd0;
    a3_in = 16'd0;

    b0_in = 16'd4;
    b1_in = 16'd0;
    b2_in = 16'd0;
    b3_in = 16'd0;

    repeat (6) begin
      @(posedge clk);
    end
    #1;
    check_any_nonzero(3);

    // Test 4: Disabling the core should hold outputs steady
    save_outputs();
    en = 0;
    a0_in = 16'd9;
    b0_in = 16'd9;
    a1_in = 16'd7;
    b1_in = 16'd7;
    repeat (3) begin
      @(posedge clk);
    end
    #1;
    check_hold(4);

    // Test 5: Re-enable with broader stimulus should again produce activity
    en = 1;
    a0_in = 16'd1;
    a1_in = 16'd2;
    a2_in = 16'd3;
    a3_in = 16'd4;

    b0_in = 16'd5;
    b1_in = 16'd6;
    b2_in = 16'd7;
    b3_in = 16'd8;

    repeat (8) begin
      @(posedge clk);
    end
    #1;
    check_any_nonzero(5);

    // Test 6: Reset after activity clears outputs again
    rst = 1;
    @(posedge clk);
    #1;
    check_all_zero(6);

    if (failures == 0)
      $display("All tests passed!");
    else
      $display("Some tests failed");

    $finish;
  end

endmodule