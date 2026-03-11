`timescale 1ns / 1ps

module systolic_array_4x4_tb;

  reg clk;
  reg rst;
  reg start;

  reg [15:0] a00; reg [15:0] a01; reg [15:0] a02; reg [15:0] a03;
  reg [15:0] a10; reg [15:0] a11; reg [15:0] a12; reg [15:0] a13;
  reg [15:0] a20; reg [15:0] a21; reg [15:0] a22; reg [15:0] a23;
  reg [15:0] a30; reg [15:0] a31; reg [15:0] a32; reg [15:0] a33;

  reg [15:0] b00; reg [15:0] b01; reg [15:0] b02; reg [15:0] b03;
  reg [15:0] b10; reg [15:0] b11; reg [15:0] b12; reg [15:0] b13;
  reg [15:0] b20; reg [15:0] b21; reg [15:0] b22; reg [15:0] b23;
  reg [15:0] b30; reg [15:0] b31; reg [15:0] b32; reg [15:0] b33;

  wire done;

  wire [31:0] c00; wire [31:0] c01; wire [31:0] c02; wire [31:0] c03;
  wire [31:0] c10; wire [31:0] c11; wire [31:0] c12; wire [31:0] c13;
  wire [31:0] c20; wire [31:0] c21; wire [31:0] c22; wire [31:0] c23;
  wire [31:0] c30; wire [31:0] c31; wire [31:0] c32; wire [31:0] c33;

  integer failures;
  integer timeout_count;

  systolic_array_4x4 uut (
    .clk(clk),
    .rst(rst),
    .start(start),

    .a00(a00), .a01(a01), .a02(a02), .a03(a03),
    .a10(a10), .a11(a11), .a12(a12), .a13(a13),
    .a20(a20), .a21(a21), .a22(a22), .a23(a23),
    .a30(a30), .a31(a31), .a32(a32), .a33(a33),

    .b00(b00), .b01(b01), .b02(b02), .b03(b03),
    .b10(b10), .b11(b11), .b12(b12), .b13(b13),
    .b20(b20), .b21(b21), .b22(b22), .b23(b23),
    .b30(b30), .b31(b31), .b32(b32), .b33(b33),

    .done(done),

    .c00(c00), .c01(c01), .c02(c02), .c03(c03),
    .c10(c10), .c11(c11), .c12(c12), .c13(c13),
    .c20(c20), .c21(c21), .c22(c22), .c23(c23),
    .c30(c30), .c31(c31), .c32(c32), .c33(c33)
  );

  always #5 clk = ~clk;

  task clear_all_inputs;
    begin
      a00 = 16'd0; a01 = 16'd0; a02 = 16'd0; a03 = 16'd0;
      a10 = 16'd0; a11 = 16'd0; a12 = 16'd0; a13 = 16'd0;
      a20 = 16'd0; a21 = 16'd0; a22 = 16'd0; a23 = 16'd0;
      a30 = 16'd0; a31 = 16'd0; a32 = 16'd0; a33 = 16'd0;

      b00 = 16'd0; b01 = 16'd0; b02 = 16'd0; b03 = 16'd0;
      b10 = 16'd0; b11 = 16'd0; b12 = 16'd0; b13 = 16'd0;
      b20 = 16'd0; b21 = 16'd0; b22 = 16'd0; b23 = 16'd0;
      b30 = 16'd0; b31 = 16'd0; b32 = 16'd0; b33 = 16'd0;
    end
  endtask

  task load_reference_matrices;
    begin
      // A matrix adapted from inp_west streams in the reference testbench
      a00 = 16'd3;  a01 = 16'd2;  a02 = 16'd1;  a03 = 16'd0;
      a10 = 16'd0;  a11 = 16'd7;  a12 = 16'd6;  a13 = 16'd5;
      a20 = 16'd0;  a21 = 16'd0;  a22 = 16'd11; a23 = 16'd10;
      a30 = 16'd0;  a31 = 16'd0;  a32 = 16'd0;  a33 = 16'd15;

      // B matrix adapted from inp_north streams in the reference testbench
      b00 = 16'd12; b01 = 16'd8;  b02 = 16'd4;  b03 = 16'd0;
      b10 = 16'd0;  b11 = 16'd13; b12 = 16'd9;  b13 = 16'd5;
      b20 = 16'd0;  b21 = 16'd0;  b22 = 16'd14; b23 = 16'd10;
      b30 = 16'd0;  b31 = 16'd0;  b32 = 16'd0;  b33 = 16'd15;
    end
  endtask

  task pulse_start;
    begin
      start = 1'b1;
      @(posedge clk);
      #1;
      start = 1'b0;
    end
  endtask

  task wait_for_done;
    input integer max_cycles;
    integer i;
    begin
      i = 0;
      while ((done !== 1'b1) && (i < max_cycles)) begin
        @(posedge clk);
        #1;
        i = i + 1;
      end
      timeout_count = i;
    end
  endtask

  task check_all_zero_outputs;
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
        failures = failures + 1;
      end
    end
  endtask

  task check_done_asserted;
    input integer test_num;
    begin
      if (done === 1'b1) begin
        $display("Test %0d passed", test_num);
      end else begin
        $display("Test %0d failed", test_num);
        $display("  Timed out waiting for done");
        failures = failures + 1;
      end
    end
  endtask

  task check_reference_result;
    input integer test_num;
    begin
      if ((c00 === 32'd36)  && (c01 === 32'd50)  && (c02 === 32'd44)  && (c03 === 32'd20) &&
          (c10 === 32'd0)   && (c11 === 32'd91)  && (c12 === 32'd147) && (c13 === 32'd170) &&
          (c20 === 32'd0)   && (c21 === 32'd0)   && (c22 === 32'd154) && (c23 === 32'd260) &&
          (c30 === 32'd0)   && (c31 === 32'd0)   && (c32 === 32'd0)   && (c33 === 32'd225)) begin
        $display("Test %0d passed", test_num);
      end else begin
        $display("Test %0d failed", test_num);
        $display("  Expected result matrix:");
        $display("   [36  50  44  20]");
        $display("   [ 0  91 147 185]");
        $display("   [ 0   0 154 260]");
        $display("   [ 0   0   0 225]");
        $display("  Actual result matrix:");
        $display("   [%0d %0d %0d %0d]", c00, c01, c02, c03);
        $display("   [%0d %0d %0d %0d]", c10, c11, c12, c13);
        $display("   [%0d %0d %0d %0d]", c20, c21, c22, c23);
        $display("   [%0d %0d %0d %0d]", c30, c31, c32, c33);
        failures = failures + 1;
      end
    end
  endtask

  task check_identity_result;
    input integer test_num;
    begin
      if ((c00 === 32'd1)  && (c01 === 32'd2)  && (c02 === 32'd3)  && (c03 === 32'd4) &&
          (c10 === 32'd5)  && (c11 === 32'd6)  && (c12 === 32'd7)  && (c13 === 32'd8) &&
          (c20 === 32'd9)  && (c21 === 32'd10) && (c22 === 32'd11) && (c23 === 32'd12) &&
          (c30 === 32'd13) && (c31 === 32'd14) && (c32 === 32'd15) && (c33 === 32'd16)) begin
        $display("Test %0d passed", test_num);
      end else begin
        $display("Test %0d failed", test_num);
        $display("  Expected A x I = A");
        failures = failures + 1;
      end
    end
  endtask

  initial begin
    failures = 0;
    clk = 0;
    rst = 0;
    start = 0;
    timeout_count = 0;

    clear_all_inputs();

    // Test 1: Reset clears outputs
    rst = 1;
    @(posedge clk);
    #1;
    check_all_zero_outputs(1);

    // Test 2: Zero matrices should produce zero outputs
    rst = 0;
    clear_all_inputs();
    pulse_start();
    wait_for_done(40);
    check_done_asserted(2);
    check_all_zero_outputs(3);

    // Test 3: Reference test adapted from provided sys_array_tb
    rst = 1;
    @(posedge clk);
    #1;
    rst = 0;
    load_reference_matrices();
    pulse_start();
    wait_for_done(60);
    check_done_asserted(4);
    check_reference_result(5);

    // Test 4: Identity matrix multiply
    rst = 1;
    @(posedge clk);
    #1;
    rst = 0;

    // A = arbitrary matrix
    a00 = 16'd1;  a01 = 16'd2;  a02 = 16'd3;  a03 = 16'd4;
    a10 = 16'd5;  a11 = 16'd6;  a12 = 16'd7;  a13 = 16'd8;
    a20 = 16'd9;  a21 = 16'd10; a22 = 16'd11; a23 = 16'd12;
    a30 = 16'd13; a31 = 16'd14; a32 = 16'd15; a33 = 16'd16;

    // B = identity
    b00 = 16'd1;  b01 = 16'd0;  b02 = 16'd0;  b03 = 16'd0;
    b10 = 16'd0;  b11 = 16'd1;  b12 = 16'd0;  b13 = 16'd0;
    b20 = 16'd0;  b21 = 16'd0;  b22 = 16'd1;  b23 = 16'd0;
    b30 = 16'd0;  b31 = 16'd0;  b32 = 16'd0;  b33 = 16'd1;

    pulse_start();
    wait_for_done(60);
    check_done_asserted(6);
    check_identity_result(7);

    if (failures == 0)
      $display("All tests passed!");
    else
      $display("Some tests failed");

    $finish;
  end

endmodule
