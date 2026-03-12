`timescale 1ns / 1ps

module baud_gentb;

  parameter CLOCK_PERIOD_NS = 40;
  parameter CLKS_PER_BIT    = 16;
  parameter OVERSAMPLE      = 4;

  reg clk;
  reg rst;
  wire baud_tick;
  wire oversample_tick;

  integer failures;
  integer baud_count;
  integer oversample_count;

  // DUT
  baud_gen
  #(
    .CLKS_PER_BIT(CLKS_PER_BIT),
    .OVERSAMPLE(OVERSAMPLE)
  )
  uut
  (
    .clk(clk),
    .rst(rst),
    .baud_tick(baud_tick),
    .oversample_tick(oversample_tick)
  );

  // Clock generation
  initial begin
    clk = 1'b0;
    forever #(CLOCK_PERIOD_NS/2) clk = ~clk;
  end

  // Tick counters
  always @(posedge clk) begin
    if (rst) begin
      baud_count       <= 0;
      oversample_count <= 0;
    end
    else begin
      if (baud_tick)
        baud_count <= baud_count + 1;
      if (oversample_tick)
        oversample_count <= oversample_count + 1;
    end
  end

  initial begin
    failures = 0;
    baud_count = 0;
    oversample_count = 0;

    rst = 1'b1;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;
    @(posedge clk);

    // ----------------------------
    // Test 1: Clean startup after reset release
    // ----------------------------
    if ((baud_tick !== 1'b0) || (oversample_tick !== 1'b0)) begin
      $display("Test 1 failed");
      $display("  Expected: baud_tick=0 oversample_tick=0");
      $display("  Actual:   baud_tick=%b oversample_tick=%b", baud_tick, oversample_tick);
      failures = failures + 1;
    end
    else begin
      $display("Test 1 passed");
      $display("  Expected: baud_tick=0 oversample_tick=0");
      $display("  Actual:   baud_tick=%b oversample_tick=%b", baud_tick, oversample_tick);
    end

    // ----------------------------
    // Test 2: oversample_tick count over one baud period
    // Expect 4 oversample ticks in 16 clock cycles
    // ----------------------------
    baud_count       = 0;
    oversample_count = 0;

    repeat (CLKS_PER_BIT) @(posedge clk);
    @(posedge clk);  // allow counter updates to settle

    if (oversample_count !== OVERSAMPLE) begin
      $display("Test 2 failed");
      $display("  Expected oversample_tick count: %0d", OVERSAMPLE);
      $display("  Actual oversample_tick count:   %0d", oversample_count);
      failures = failures + 1;
    end
    else begin
      $display("Test 2 passed");
      $display("  Expected oversample_tick count: %0d", OVERSAMPLE);
      $display("  Actual oversample_tick count:   %0d", oversample_count);
    end

    // ----------------------------
    // Test 3: baud_tick count over one baud period
    // Expect exactly 1 baud tick in 16 clock cycles
    // ----------------------------
    if (baud_count !== 1) begin
      $display("Test 3 failed");
      $display("  Expected baud_tick count: %0d", 1);
      $display("  Actual baud_tick count:   %0d", baud_count);
      failures = failures + 1;
    end
    else begin
      $display("Test 3 passed");
      $display("  Expected baud_tick count: %0d", 1);
      $display("  Actual baud_tick count:   %0d", baud_count);
    end

    // ----------------------------
    // Test 4: baud_tick count over two baud periods
    // Expect 2 baud ticks in 32 clock cycles
    // ----------------------------
    baud_count       = 0;
    oversample_count = 0;

    repeat (2*CLKS_PER_BIT) @(posedge clk);
    @(posedge clk);  // allow counter updates to settle

    if (baud_count !== 2) begin
      $display("Test 4 failed");
      $display("  Expected baud_tick count: %0d", 2);
      $display("  Actual baud_tick count:   %0d", baud_count);
      failures = failures + 1;
    end
    else begin
      $display("Test 4 passed");
      $display("  Expected baud_tick count: %0d", 2);
      $display("  Actual baud_tick count:   %0d", baud_count);
    end

    // ----------------------------
    // Test 5: oversample_tick count over two baud periods
    // Expect 8 oversample ticks in 32 clock cycles
    // ----------------------------
    if (oversample_count !== (2*OVERSAMPLE)) begin
      $display("Test 5 failed");
      $display("  Expected oversample_tick count: %0d", (2*OVERSAMPLE));
      $display("  Actual oversample_tick count:   %0d", oversample_count);
      failures = failures + 1;
    end
    else begin
      $display("Test 5 passed");
      $display("  Expected oversample_tick count: %0d", (2*OVERSAMPLE));
      $display("  Actual oversample_tick count:   %0d", oversample_count);
    end

    // ----------------------------
    // Test 6: Reset restarts timing cleanly
    // ----------------------------
    repeat (5) @(posedge clk);
    rst = 1'b1;
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;

    baud_count       = 0;
    oversample_count = 0;

    repeat (CLKS_PER_BIT) @(posedge clk);
    @(posedge clk);  // allow counter updates to settle

    if ((baud_count !== 1) || (oversample_count !== OVERSAMPLE)) begin
      $display("Test 6 failed");
      $display("  Expected after reset: baud_count=%0d oversample_count=%0d", 1, OVERSAMPLE);
      $display("  Actual after reset:   baud_count=%0d oversample_count=%0d", baud_count, oversample_count);
      failures = failures + 1;
    end
    else begin
      $display("Test 6 passed");
      $display("  Expected after reset: baud_count=%0d oversample_count=%0d", 1, OVERSAMPLE);
      $display("  Actual after reset:   baud_count=%0d oversample_count=%0d", baud_count, oversample_count);
    end

    if (failures == 0)
      $display("All tests passed!");
    else
      $display("Some tests failed");

    $finish;
  end

endmodule
