`timescale 1ns/1ps

module uart_txtb;

  parameter CLOCK_PERIOD_NS = 40;

  reg clk;
  reg rst;
  reg baud_tick;
  reg tx_start;
  reg [7:0] tx_data;
  wire tx;
  wire tx_busy;

  integer failures;
  integer i;
  reg expected_bit;

  // DUT
  uart_tx uut (
    .clk(clk),
    .rst(rst),
    .baud_tick(baud_tick),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx(tx),
    .tx_busy(tx_busy)
  );

  // Clock generation
  initial begin
    clk = 1'b0;
    forever #(CLOCK_PERIOD_NS/2) clk = ~clk;
  end

  // Helper task: generate one baud tick pulse
  task pulse_baud_tick;
  begin
    @(posedge clk);
    baud_tick = 1'b1;
    @(posedge clk);
    baud_tick = 1'b0;
  end
  endtask

  initial begin
    failures  = 0;
    rst       = 1'b1;
    baud_tick = 1'b0;
    tx_start  = 1'b0;
    tx_data   = 8'h00;

    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;
    @(posedge clk);

    // ----------------------------
    // Test 1: Idle behavior after reset
    // ----------------------------
    if ((tx !== 1'b1) || (tx_busy !== 1'b0)) begin
      $display("Test 1 failed");
      $display("  Expected: tx=1 tx_busy=0");
      $display("  Actual:   tx=%b tx_busy=%b", tx, tx_busy);
      failures = failures + 1;
    end
    else begin
      $display("Test 1 passed");
      $display("  Expected: tx=1 tx_busy=0");
      $display("  Actual:   tx=%b tx_busy=%b", tx, tx_busy);
    end

    // ----------------------------
    // Test 2: Start transmission begins properly
    // Send 8'hA5 = 1010_0101
    // LSB-first bits: 1 0 1 0 0 1 0 1
    // ----------------------------
    tx_data  = 8'hA5;
    tx_start = 1'b1;
    @(posedge clk);
    tx_start = 1'b0;
    @(posedge clk);

    if (tx_busy !== 1'b1) begin
      $display("Test 2 failed");
      $display("  Expected tx_busy: 1");
      $display("  Actual tx_busy:   %b", tx_busy);
      failures = failures + 1;
    end
    else begin
      $display("Test 2 passed");
      $display("  Expected tx_busy: 1");
      $display("  Actual tx_busy:   %b", tx_busy);
    end

    // ----------------------------
    // Test 3: Start bit
    // After first baud tick, tx should output start bit 0
    // ----------------------------
    pulse_baud_tick;
    @(posedge clk);

    if (tx !== 1'b0) begin
      $display("Test 3 failed");
      $display("  Expected start bit: 0");
      $display("  Actual start bit:   %b", tx);
      failures = failures + 1;
    end
    else begin
      $display("Test 3 passed");
      $display("  Expected start bit: 0");
      $display("  Actual start bit:   %b", tx);
    end

    // ----------------------------
    // Test 4: Data bits for 8'hA5, LSB first
    // Expected sequence: 1 0 1 0 0 1 0 1
    // ----------------------------
    for (i = 0; i < 8; i = i + 1) begin
      expected_bit = tx_data[i];
      pulse_baud_tick;
      @(posedge clk);

      if (tx !== expected_bit) begin
        $display("Test 4 failed");
        $display("  Data bit index: %0d", i);
        $display("  Expected bit:   %b", expected_bit);
        $display("  Actual bit:     %b", tx);
        failures = failures + 1;
      end
      else begin
        $display("Test 4 passed");
        $display("  Data bit index: %0d", i);
        $display("  Expected bit:   %b", expected_bit);
        $display("  Actual bit:     %b", tx);
      end
    end

    // ----------------------------
    // Test 5: Stop bit
    // ----------------------------
    pulse_baud_tick;
    @(posedge clk);

    if (tx !== 1'b1) begin
      $display("Test 5 failed");
      $display("  Expected stop bit: 1");
      $display("  Actual stop bit:   %b", tx);
      failures = failures + 1;
    end
    else begin
      $display("Test 5 passed");
      $display("  Expected stop bit: 1");
      $display("  Actual stop bit:   %b", tx);
    end

    // ----------------------------
    // Test 6: Return to idle after frame completion
    // ----------------------------
    pulse_baud_tick;
    @(posedge clk);

    if ((tx !== 1'b1) || (tx_busy !== 1'b0)) begin
      $display("Test 6 failed");
      $display("  Expected: tx=1 tx_busy=0");
      $display("  Actual:   tx=%b tx_busy=%b", tx, tx_busy);
      failures = failures + 1;
    end
    else begin
      $display("Test 6 passed");
      $display("  Expected: tx=1 tx_busy=0");
      $display("  Actual:   tx=%b tx_busy=%b", tx, tx_busy);
    end

    // ----------------------------
    // Test 7: Second byte transmission
    // Send 8'h3C = 0011_1100
    // LSB-first bits: 0 0 1 1 1 1 0 0
    // ----------------------------
    tx_data  = 8'h3C;
    tx_start = 1'b1;
    @(posedge clk);
    tx_start = 1'b0;
    @(posedge clk);

    pulse_baud_tick;
    @(posedge clk);

    if (tx !== 1'b0) begin
      $display("Test 7 failed");
      $display("  Expected start bit: 0");
      $display("  Actual start bit:   %b", tx);
      failures = failures + 1;
    end
    else begin
      $display("Test 7 passed");
      $display("  Expected start bit: 0");
      $display("  Actual start bit:   %b", tx);
    end

    for (i = 0; i < 8; i = i + 1) begin
      expected_bit = tx_data[i];
      pulse_baud_tick;
      @(posedge clk);

      if (tx !== expected_bit) begin
        $display("Test 7 failed");
        $display("  Data bit index: %0d", i);
        $display("  Expected bit:   %b", expected_bit);
        $display("  Actual bit:     %b", tx);
        failures = failures + 1;
      end
      else begin
        $display("Test 7 passed");
        $display("  Data bit index: %0d", i);
        $display("  Expected bit:   %b", expected_bit);
        $display("  Actual bit:     %b", tx);
      end
    end

    pulse_baud_tick;
    @(posedge clk);

    if (tx !== 1'b1) begin
      $display("Test 7 failed");
      $display("  Expected stop bit: 1");
      $display("  Actual stop bit:   %b", tx);
      failures = failures + 1;
    end
    else begin
      $display("Test 7 passed");
      $display("  Expected stop bit: 1");
      $display("  Actual stop bit:   %b", tx);
    end

    pulse_baud_tick;
    @(posedge clk);

    if (tx_busy !== 1'b0) begin
      $display("Test 7 failed");
      $display("  Expected tx_busy after frame: 0");
      $display("  Actual tx_busy after frame:   %b", tx_busy);
      failures = failures + 1;
    end
    else begin
      $display("Test 7 passed");
      $display("  Expected tx_busy after frame: 0");
      $display("  Actual tx_busy after frame:   %b", tx_busy);
    end

    // ----------------------------
    // Test 8: Reset during/after operation restores idle state
    // ----------------------------
    tx_data  = 8'hF0;
    tx_start = 1'b1;
    @(posedge clk);
    tx_start = 1'b0;
    @(posedge clk);

    pulse_baud_tick;
    pulse_baud_tick;

    rst = 1'b1;
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;
    @(posedge clk);

    if ((tx !== 1'b1) || (tx_busy !== 1'b0)) begin
      $display("Test 8 failed");
      $display("  Expected after reset: tx=1 tx_busy=0");
      $display("  Actual after reset:   tx=%b tx_busy=%b", tx, tx_busy);
      failures = failures + 1;
    end
    else begin
      $display("Test 8 passed");
      $display("  Expected after reset: tx=1 tx_busy=0");
      $display("  Actual after reset:   tx=%b tx_busy=%b", tx, tx_busy);
    end

    if (failures == 0)
      $display("All tests passed!");
    else
      $display("Some tests failed");

    $finish;
  end

endmodule