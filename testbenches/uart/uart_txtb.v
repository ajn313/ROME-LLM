`timescale 1ns / 1ps

module uart_txtb;

  reg clk;
  reg rst;
  reg baud_tick;
  reg tx_start;
  reg [7:0] tx_data;
  wire tx;
  wire tx_busy;

  integer failures;

  uart_tx dut (
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
    forever #20 clk = ~clk;
  end

  task pulse_baud_tick;
    begin
      baud_tick = 1'b1;
      @(posedge clk);
      baud_tick = 1'b0;
      @(posedge clk);
    end
  endtask

  initial begin
    failures = 0;
    rst = 1'b1;
    baud_tick = 1'b0;
    tx_start = 1'b0;
    tx_data = 8'h00;

    // -------------------------
    // Test 1: Reset / idle behavior
    // -------------------------
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;
    @(posedge clk);

    if ((tx === 1'b1) && (tx_busy === 1'b0)) begin
      $display("Test 1 passed");
    end else begin
      $display("Test 1 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 2: Start transmission of 8'hA5
    // Expect busy asserted and start bit driven low
    // -------------------------
    tx_data = 8'hA5;
    tx_start = 1'b1;
    @(posedge clk);
    tx_start = 1'b0;
    @(posedge clk);

    if ((tx_busy === 1'b1) && (tx === 1'b0)) begin
      $display("Test 2 passed");
    end else begin
      $display("Test 2 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 3: First data bit of 8'hA5
    // 8'hA5 = 1010_0101, LSB first => bit[0] = 1
    // -------------------------
    pulse_baud_tick;

    if ((tx_busy === 1'b1) && (tx === 1'b1)) begin
      $display("Test 3 passed");
    end else begin
      $display("Test 3 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 4: Next several data bits of 8'hA5
    // Sequence after start bit: 1,0,1,0,0,1,0,1
    // We already checked bit[0] = 1
    // Now check bit[1] through bit[7]
    // -------------------------
    pulse_baud_tick; // bit[1] = 0
    if (tx !== 1'b0) failures = failures + 1;

    pulse_baud_tick; // bit[2] = 1
    if (tx !== 1'b1) failures = failures + 1;

    pulse_baud_tick; // bit[3] = 0
    if (tx !== 1'b0) failures = failures + 1;

    pulse_baud_tick; // bit[4] = 0
    if (tx !== 1'b0) failures = failures + 1;

    pulse_baud_tick; // bit[5] = 1
    if (tx !== 1'b1) failures = failures + 1;

    pulse_baud_tick; // bit[6] = 0
    if (tx !== 1'b0) failures = failures + 1;

    pulse_baud_tick; // bit[7] = 1
    if (tx !== 1'b1) failures = failures + 1;

    if (tx_busy === 1'b1) begin
      $display("Test 4 passed");
    end else begin
      $display("Test 4 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 5: Stop bit should be high
    // -------------------------
    pulse_baud_tick;

    if ((tx === 1'b1) && (tx_busy === 1'b1 || tx_busy === 1'b0)) begin
      $display("Test 5 passed");
    end else begin
      $display("Test 5 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 6: Return to idle after stop bit
    // -------------------------
    pulse_baud_tick;

    if ((tx === 1'b1) && (tx_busy === 1'b0)) begin
      $display("Test 6 passed");
    end else begin
      $display("Test 6 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 7: Transmit 8'h3C correctly
    // 8'h3C = 0011_1100, LSB first bit[0] = 0
    // -------------------------
    tx_data = 8'h3C;
    tx_start = 1'b1;
    @(posedge clk);
    tx_start = 1'b0;
    @(posedge clk);

    if ((tx_busy === 1'b1) && (tx === 1'b0)) begin
      pulse_baud_tick; // bit[0]
      if (tx === 1'b0) begin
        $display("Test 7 passed");
      end else begin
        $display("Test 7 failed");
        failures = failures + 1;
      end
    end else begin
      $display("Test 7 failed");
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