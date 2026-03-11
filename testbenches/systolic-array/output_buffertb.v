`timescale 1ns / 1ps

module output_buffer_tb;

  reg clk;
  reg rst;
  reg capture;

  reg [31:0] c00_in;
  reg [31:0] c01_in;
  reg [31:0] c02_in;
  reg [31:0] c03_in;
  reg [31:0] c10_in;
  reg [31:0] c11_in;
  reg [31:0] c12_in;
  reg [31:0] c13_in;
  reg [31:0] c20_in;
  reg [31:0] c21_in;
  reg [31:0] c22_in;
  reg [31:0] c23_in;
  reg [31:0] c30_in;
  reg [31:0] c31_in;
  reg [31:0] c32_in;
  reg [31:0] c33_in;

  wire [31:0] c00_out;
  wire [31:0] c01_out;
  wire [31:0] c02_out;
  wire [31:0] c03_out;
  wire [31:0] c10_out;
  wire [31:0] c11_out;
  wire [31:0] c12_out;
  wire [31:0] c13_out;
  wire [31:0] c20_out;
  wire [31:0] c21_out;
  wire [31:0] c22_out;
  wire [31:0] c23_out;
  wire [31:0] c30_out;
  wire [31:0] c31_out;
  wire [31:0] c32_out;
  wire [31:0] c33_out;

  integer failures;

  reg [31:0] prev_c00_out;
  reg [31:0] prev_c01_out;
  reg [31:0] prev_c02_out;
  reg [31:0] prev_c03_out;
  reg [31:0] prev_c10_out;
  reg [31:0] prev_c11_out;
  reg [31:0] prev_c12_out;
  reg [31:0] prev_c13_out;
  reg [31:0] prev_c20_out;
  reg [31:0] prev_c21_out;
  reg [31:0] prev_c22_out;
  reg [31:0] prev_c23_out;
  reg [31:0] prev_c30_out;
  reg [31:0] prev_c31_out;
  reg [31:0] prev_c32_out;
  reg [31:0] prev_c33_out;

  output_buffer uut (
    .clk(clk),
    .rst(rst),
    .capture(capture),
    .c00_in(c00_in),
    .c01_in(c01_in),
    .c02_in(c02_in),
    .c03_in(c03_in),
    .c10_in(c10_in),
    .c11_in(c11_in),
    .c12_in(c12_in),
    .c13_in(c13_in),
    .c20_in(c20_in),
    .c21_in(c21_in),
    .c22_in(c22_in),
    .c23_in(c23_in),
    .c30_in(c30_in),
    .c31_in(c31_in),
    .c32_in(c32_in),
    .c33_in(c33_in),
    .c00_out(c00_out),
    .c01_out(c01_out),
    .c02_out(c02_out),
    .c03_out(c03_out),
    .c10_out(c10_out),
    .c11_out(c11_out),
    .c12_out(c12_out),
    .c13_out(c13_out),
    .c20_out(c20_out),
    .c21_out(c21_out),
    .c22_out(c22_out),
    .c23_out(c23_out),
    .c30_out(c30_out),
    .c31_out(c31_out),
    .c32_out(c32_out),
    .c33_out(c33_out)
  );

  always #5 clk = ~clk;

  task check_outputs;
    input integer test_num;
    input [31:0] exp_c00_out;
    input [31:0] exp_c01_out;
    input [31:0] exp_c02_out;
    input [31:0] exp_c03_out;
    input [31:0] exp_c10_out;
    input [31:0] exp_c11_out;
    input [31:0] exp_c12_out;
    input [31:0] exp_c13_out;
    input [31:0] exp_c20_out;
    input [31:0] exp_c21_out;
    input [31:0] exp_c22_out;
    input [31:0] exp_c23_out;
    input [31:0] exp_c30_out;
    input [31:0] exp_c31_out;
    input [31:0] exp_c32_out;
    input [31:0] exp_c33_out;
    begin
      if ((c00_out === exp_c00_out) && (c01_out === exp_c01_out) &&
          (c02_out === exp_c02_out) && (c03_out === exp_c03_out) &&
          (c10_out === exp_c10_out) && (c11_out === exp_c11_out) &&
          (c12_out === exp_c12_out) && (c13_out === exp_c13_out) &&
          (c20_out === exp_c20_out) && (c21_out === exp_c21_out) &&
          (c22_out === exp_c22_out) && (c23_out === exp_c23_out) &&
          (c30_out === exp_c30_out) && (c31_out === exp_c31_out) &&
          (c32_out === exp_c32_out) && (c33_out === exp_c33_out)) begin
        $display("Test %0d passed", test_num);
      end else begin
        $display("Test %0d failed", test_num);
        failures = failures + 1;
      end
    end
  endtask

  task save_outputs;
    begin
      prev_c00_out = c00_out; prev_c01_out = c01_out; prev_c02_out = c02_out; prev_c03_out = c03_out;
      prev_c10_out = c10_out; prev_c11_out = c11_out; prev_c12_out = c12_out; prev_c13_out = c13_out;
      prev_c20_out = c20_out; prev_c21_out = c21_out; prev_c22_out = c22_out; prev_c23_out = c23_out;
      prev_c30_out = c30_out; prev_c31_out = c31_out; prev_c32_out = c32_out; prev_c33_out = c33_out;
    end
  endtask

  task check_hold;
    input integer test_num;
    begin
      if ((c00_out === prev_c00_out) && (c01_out === prev_c01_out) &&
          (c02_out === prev_c02_out) && (c03_out === prev_c03_out) &&
          (c10_out === prev_c10_out) && (c11_out === prev_c11_out) &&
          (c12_out === prev_c12_out) && (c13_out === prev_c13_out) &&
          (c20_out === prev_c20_out) && (c21_out === prev_c21_out) &&
          (c22_out === prev_c22_out) && (c23_out === prev_c23_out) &&
          (c30_out === prev_c30_out) && (c31_out === prev_c31_out) &&
          (c32_out === prev_c32_out) && (c33_out === prev_c33_out)) begin
        $display("Test %0d passed", test_num);
      end else begin
        $display("Test %0d failed", test_num);
        $display("  Expected outputs to hold when capture=0");
        failures = failures + 1;
      end
    end
  endtask

  initial begin
    failures = 0;
    clk = 0;
    rst = 0;
    capture = 0;

    c00_in = 32'd1;   c01_in = 32'd2;   c02_in = 32'd3;   c03_in = 32'd4;
    c10_in = 32'd5;   c11_in = 32'd6;   c12_in = 32'd7;   c13_in = 32'd8;
    c20_in = 32'd9;   c21_in = 32'd10;  c22_in = 32'd11;  c23_in = 32'd12;
    c30_in = 32'd13;  c31_in = 32'd14;  c32_in = 32'd15;  c33_in = 32'd16;

    // Test 1: Reset clears all outputs
    rst = 1;
    @(posedge clk);
    #1;
    check_outputs(1,
      32'd0, 32'd0, 32'd0, 32'd0,
      32'd0, 32'd0, 32'd0, 32'd0,
      32'd0, 32'd0, 32'd0, 32'd0,
      32'd0, 32'd0, 32'd0, 32'd0
    );

    // Test 2: Without capture, outputs remain zero
    rst = 0;
    @(posedge clk);
    #1;
    check_outputs(2,
      32'd0, 32'd0, 32'd0, 32'd0,
      32'd0, 32'd0, 32'd0, 32'd0,
      32'd0, 32'd0, 32'd0, 32'd0,
      32'd0, 32'd0, 32'd0, 32'd0
    );

    // Test 3: Capture first full matrix
    capture = 1;
    @(posedge clk);
    #1;
    capture = 0;
    check_outputs(3,
      32'd1, 32'd2, 32'd3, 32'd4,
      32'd5, 32'd6, 32'd7, 32'd8,
      32'd9, 32'd10, 32'd11, 32'd12,
      32'd13, 32'd14, 32'd15, 32'd16
    );

    // Test 4: Change inputs but do not capture, outputs must hold
    save_outputs();
    c00_in = 32'd101; c01_in = 32'd102; c02_in = 32'd103; c03_in = 32'd104;
    c10_in = 32'd105; c11_in = 32'd106; c12_in = 32'd107; c13_in = 32'd108;
    c20_in = 32'd109; c21_in = 32'd110; c22_in = 32'd111; c23_in = 32'd112;
    c30_in = 32'd113; c31_in = 32'd114; c32_in = 32'd115; c33_in = 32'd116;
    @(posedge clk);
    #1;
    check_hold(4);

    // Test 5: Capture updated matrix
    capture = 1;
    @(posedge clk);
    #1;
    capture = 0;
    check_outputs(5,
      32'd101, 32'd102, 32'd103, 32'd104,
      32'd105, 32'd106, 32'd107, 32'd108,
      32'd109, 32'd110, 32'd111, 32'd112,
      32'd113, 32'd114, 32'd115, 32'd116
    );

    // Test 6: Reset after capture clears all outputs again
    rst = 1;
    @(posedge clk);
    #1;
    check_outputs(6,
      32'd0, 32'd0, 32'd0, 32'd0,
      32'd0, 32'd0, 32'd0, 32'd0,
      32'd0, 32'd0, 32'd0, 32'd0,
      32'd0, 32'd0, 32'd0, 32'd0
    );

    if (failures == 0)
      $display("All tests passed!");
    else
      $display("Some tests failed");

    $finish;
  end

endmodule