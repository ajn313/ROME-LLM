`timescale 1ns / 1ps

module baud_gentb;

  reg clk;
  reg rst;
  wire baud_tick;
  wire oversample_tick;

  integer failures;
  integer oversample_seen;
  integer i;

  parameter CLK_FREQ   = 25000000;
  parameter BAUD_RATE  = 115200;
  parameter OVERSAMPLE = 16;

  // 25,000,000 / 115,200 = 217
  // 25,000,000 / (115,200 * 16) = 13
  localparam BAUD_DIV       = CLK_FREQ / BAUD_RATE;
  localparam OVERSAMPLE_DIV = CLK_FREQ / (BAUD_RATE * OVERSAMPLE);

  // DUT
  baud_gen #(
    .CLK_FREQ(CLK_FREQ),
    .BAUD_RATE(BAUD_RATE),
    .OVERSAMPLE(OVERSAMPLE)
  ) dut (
    .clk(clk),
    .rst(rst),
    .baud_tick(baud_tick),
    .oversample_tick(oversample_tick)
  );

  // Clock generation: 25 MHz -> 40 ns period
  initial begin
    clk = 1'b0;
    forever #20 clk = ~clk;
  end

  initial begin
    failures = 0;
    oversample_seen = 0;

    // -------------------------
    // Test 1: Reset behavior
    // -------------------------
    rst = 1'b1;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);

    if ((baud_tick !== 1'b0) || (oversample_tick !== 1'b0)) begin
      $display("Test 1 failed");
      failures = failures + 1;
    end else begin
      $display("Test 1 passed");
    end

    // Release reset
    rst = 1'b0;

    // -------------------------
    // Test 2: oversample_tick period
    // Expect first oversample tick after OVERSAMPLE_DIV clocks
    // -------------------------
    for (i = 0; i < OVERSAMPLE_DIV-1; i = i + 1) begin
      @(posedge clk);
      if (oversample_tick === 1'b1) begin
        $display("Test 2 failed");
        failures = failures + 1;
        disable test2_done;
      end
    end

    @(posedge clk);
    if (oversample_tick === 1'b1) begin
      $display("Test 2 passed");
    end else begin
      $display("Test 2 failed");
      failures = failures + 1;
    end
    test2_done: begin end

    // -------------------------
    // Test 3: baud_tick period
    // Expect first baud tick after BAUD_DIV clocks
    // -------------------------
    rst = 1'b1;
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;

    for (i = 0; i < BAUD_DIV-1; i = i + 1) begin
      @(posedge clk);
      if (baud_tick === 1'b1) begin
        $display("Test 3 failed");
        failures = failures + 1;
        disable test3_done;
      end
    end

    @(posedge clk);
    if (baud_tick === 1'b1) begin
      $display("Test 3 passed");
    end else begin
      $display("Test 3 failed");
      failures = failures + 1;
    end
    test3_done: begin end

    // -------------------------
    // Test 4: 16 oversample ticks per baud interval
    // After reset, count oversample ticks until the first baud tick
    // -------------------------
    rst = 1'b1;
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;

    oversample_seen = 0;

    for (i = 0; i < BAUD_DIV; i = i + 1) begin
      @(posedge clk);
      if (oversample_tick === 1'b1)
        oversample_seen = oversample_seen + 1;
    end

    if ((baud_tick === 1'b1) && (oversample_seen == OVERSAMPLE)) begin
      $display("Test 4 passed");
    end else begin
      $display("Test 4 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Final result
    // -------------------------
    if (failures == 0)
      $display("All tests passed!");
    else
      $display("Some tests failed");

    $finish;
  end

endmodule