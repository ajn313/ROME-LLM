`timescale 1ns/1ps

module uart_toptb;

  parameter CLOCK_PERIOD_NS = 40;

  reg clk;
  reg rst;
  reg tx_start;
  reg [7:0] tx_data;
  reg rx;

  wire tx;
  wire [7:0] rx_data;
  wire rx_valid;
  wire tx_busy;
  wire framing_error;

  integer failures;
  integer rx_wait_count;

  // DUT
  uart_top uut (
    .clk(clk),
    .rst(rst),
    .rx(rx),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx(tx),
    .rx_data(rx_data),
    .rx_valid(rx_valid),
    .tx_busy(tx_busy),
    .framing_error(framing_error)
  );

  // Clock generation
  initial begin
    clk = 1'b0;
    forever #(CLOCK_PERIOD_NS/2) clk = ~clk;
  end

  // Loopback connection:
  // when transmitter is active, feed TX into RX;
  // otherwise hold RX high (idle UART line)
  always @(*) begin
    if (tx_busy)
      rx = tx;
    else
      rx = 1'b1;
  end

  // Wait for rx_valid with timeout to avoid hangs
  task wait_for_rx_valid;
    output integer timed_out;
  begin
    timed_out = 0;
    rx_wait_count = 0;
    while ((rx_valid !== 1'b1) && (rx_wait_count < 50000)) begin
      @(posedge clk);
      rx_wait_count = rx_wait_count + 1;
    end
    if (rx_valid !== 1'b1)
      timed_out = 1;
  end
  endtask

  // Send one byte by pulsing tx_start for one clock
  task start_tx_byte;
    input [7:0] data_byte;
  begin
    @(posedge clk);
    tx_data  = data_byte;
    tx_start = 1'b1;
    @(posedge clk);
    tx_start = 1'b0;
  end
  endtask

  integer timed_out;

  initial begin
    failures = 0;
    rst      = 1'b1;
    tx_start = 1'b0;
    tx_data  = 8'h00;

    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;
    @(posedge clk);

    // ----------------------------
    // Test 1: Idle state after reset
    // ----------------------------
    if ((tx !== 1'b1) || (tx_busy !== 1'b0) || (rx_valid !== 1'b0) || (framing_error !== 1'b0)) begin
      $display("Test 1 failed");
      $display("  Expected: tx=1 tx_busy=0 rx_valid=0 framing_error=0");
      $display("  Actual:   tx=%b tx_busy=%b rx_valid=%b framing_error=%b",
               tx, tx_busy, rx_valid, framing_error);
      failures = failures + 1;
    end
    else begin
      $display("Test 1 passed");
      $display("  Expected: tx=1 tx_busy=0 rx_valid=0 framing_error=0");
      $display("  Actual:   tx=%b tx_busy=%b rx_valid=%b framing_error=%b",
               tx, tx_busy, rx_valid, framing_error);
    end

    // ----------------------------
    // Test 2: Loopback 8'hFF
    // Adapted from your sample testbench
    // ----------------------------
    start_tx_byte(8'hFF);
    wait_for_rx_valid(timed_out);

    if (timed_out != 0) begin
      $display("Test 2 failed");
      $display("  Expected rx_valid before timeout with rx_data=0x%02h", 8'hFF);
      $display("  Actual:   timeout occurred, rx_data=0x%02h rx_valid=%b framing_error=%b",
               rx_data, rx_valid, framing_error);
      failures = failures + 1;
    end
    else if ((rx_data !== 8'hFF) || (framing_error !== 1'b0)) begin
      $display("Test 2 failed");
      $display("  Expected: rx_data=0x%02h rx_valid=1 framing_error=0", 8'hFF);
      $display("  Actual:   rx_data=0x%02h rx_valid=%b framing_error=%b",
               rx_data, rx_valid, framing_error);
      failures = failures + 1;
    end
    else begin
      $display("Test 2 passed");
      $display("  Expected: rx_data=0x%02h rx_valid=1 framing_error=0", 8'hFF);
      $display("  Actual:   rx_data=0x%02h rx_valid=%b framing_error=%b",
               rx_data, rx_valid, framing_error);
    end

    @(posedge clk);

    // ----------------------------
    // Test 3: Loopback 8'h00
    // ----------------------------
    start_tx_byte(8'h00);
    wait_for_rx_valid(timed_out);

    if (timed_out != 0) begin
      $display("Test 3 failed");
      $display("  Expected rx_valid before timeout with rx_data=0x%02h", 8'h00);
      $display("  Actual:   timeout occurred, rx_data=0x%02h rx_valid=%b framing_error=%b",
               rx_data, rx_valid, framing_error);
      failures = failures + 1;
    end
    else if ((rx_data !== 8'h00) || (framing_error !== 1'b0)) begin
      $display("Test 3 failed");
      $display("  Expected: rx_data=0x%02h rx_valid=1 framing_error=0", 8'h00);
      $display("  Actual:   rx_data=0x%02h rx_valid=%b framing_error=%b",
               rx_data, rx_valid, framing_error);
      failures = failures + 1;
    end
    else begin
      $display("Test 3 passed");
      $display("  Expected: rx_data=0x%02h rx_valid=1 framing_error=0", 8'h00);
      $display("  Actual:   rx_data=0x%02h rx_valid=%b framing_error=%b",
               rx_data, rx_valid, framing_error);
    end

    @(posedge clk);

    // ----------------------------
    // Test 4: Loopback 8'hA5
    // ----------------------------
    start_tx_byte(8'hA5);
    wait_for_rx_valid(timed_out);

    if (timed_out != 0) begin
      $display("Test 4 failed");
      $display("  Expected rx_valid before timeout with rx_data=0x%02h", 8'hA5);
      $display("  Actual:   timeout occurred, rx_data=0x%02h rx_valid=%b framing_error=%b",
               rx_data, rx_valid, framing_error);
      failures = failures + 1;
    end
    else if ((rx_data !== 8'hA5) || (framing_error !== 1'b0)) begin
      $display("Test 4 failed");
      $display("  Expected: rx_data=0x%02h rx_valid=1 framing_error=0", 8'hA5);
      $display("  Actual:   rx_data=0x%02h rx_valid=%b framing_error=%b",
               rx_data, rx_valid, framing_error);
      failures = failures + 1;
    end
    else begin
      $display("Test 4 passed");
      $display("  Expected: rx_data=0x%02h rx_valid=1 framing_error=0", 8'hA5);
      $display("  Actual:   rx_data=0x%02h rx_valid=%b framing_error=%b",
               rx_data, rx_valid, framing_error);
    end

    @(posedge clk);

    // ----------------------------
    // Test 5: Loopback 8'h3C
    // ----------------------------
    start_tx_byte(8'h3C);
    wait_for_rx_valid(timed_out);

    if (timed_out != 0) begin
      $display("Test 5 failed");
      $display("  Expected rx_valid before timeout with rx_data=0x%02h", 8'h3C);
      $display("  Actual:   timeout occurred, rx_data=0x%02h rx_valid=%b framing_error=%b",
               rx_data, rx_valid, framing_error);
      failures = failures + 1;
    end
    else if ((rx_data !== 8'h3C) || (framing_error !== 1'b0)) begin
      $display("Test 5 failed");
      $display("  Expected: rx_data=0x%02h rx_valid=1 framing_error=0", 8'h3C);
      $display("  Actual:   rx_data=0x%02h rx_valid=%b framing_error=%b",
               rx_data, rx_valid, framing_error);
      failures = failures + 1;
    end
    else begin
      $display("Test 5 passed");
      $display("  Expected: rx_data=0x%02h rx_valid=1 framing_error=0", 8'h3C);
      $display("  Actual:   rx_data=0x%02h rx_valid=%b framing_error=%b",
               rx_data, rx_valid, framing_error);
    end

    @(posedge clk);

    // ----------------------------
    // Test 6: Busy should assert during transmission
    // ----------------------------
    start_tx_byte(8'h55);
    @(posedge clk);

    if (tx_busy !== 1'b1) begin
      $display("Test 6 failed");
      $display("  Expected tx_busy: 1");
      $display("  Actual tx_busy:   %b", tx_busy);
      failures = failures + 1;
    end
    else begin
      $display("Test 6 passed");
      $display("  Expected tx_busy: 1");
      $display("  Actual tx_busy:   %b", tx_busy);
    end

    wait_for_rx_valid(timed_out);

    if (timed_out != 0) begin
      $display("Test 6 failed");
      $display("  Expected byte reception after busy period for rx_data=0x%02h", 8'h55);
      $display("  Actual:   timeout occurred, rx_data=0x%02h rx_valid=%b framing_error=%b",
               rx_data, rx_valid, framing_error);
      failures = failures + 1;
    end
    else if ((rx_data !== 8'h55) || (framing_error !== 1'b0)) begin
      $display("Test 6 failed");
      $display("  Expected: rx_data=0x%02h rx_valid=1 framing_error=0", 8'h55);
      $display("  Actual:   rx_data=0x%02h rx_valid=%b framing_error=%b",
               rx_data, rx_valid, framing_error);
      failures = failures + 1;
    end
    else begin
      $display("Test 6 passed");
      $display("  Expected: rx_data=0x%02h rx_valid=1 framing_error=0", 8'h55);
      $display("  Actual:   rx_data=0x%02h rx_valid=%b framing_error=%b",
               rx_data, rx_valid, framing_error);
    end

    @(posedge clk);

    // ----------------------------
    // Test 7: Reset restores clean idle state
    // ----------------------------
    rst = 1'b1;
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;
    @(posedge clk);

    if ((tx !== 1'b1) || (tx_busy !== 1'b0) || (rx_valid !== 1'b0) || (framing_error !== 1'b0)) begin
      $display("Test 7 failed");
      $display("  Expected after reset: tx=1 tx_busy=0 rx_valid=0 framing_error=0");
      $display("  Actual after reset:   tx=%b tx_busy=%b rx_valid=%b framing_error=%b",
               tx, tx_busy, rx_valid, framing_error);
      failures = failures + 1;
    end
    else begin
      $display("Test 7 passed");
      $display("  Expected after reset: tx=1 tx_busy=0 rx_valid=0 framing_error=0");
      $display("  Actual after reset:   tx=%b tx_busy=%b rx_valid=%b framing_error=%b",
               tx, tx_busy, rx_valid, framing_error);
    end

    // ----------------------------
    // Test 8: Loopback still works after reset
    // ----------------------------
    start_tx_byte(8'hC3);
    wait_for_rx_valid(timed_out);

    if (timed_out != 0) begin
      $display("Test 8 failed");
      $display("  Expected rx_valid before timeout with rx_data=0x%02h", 8'hC3);
      $display("  Actual:   timeout occurred, rx_data=0x%02h rx_valid=%b framing_error=%b",
               rx_data, rx_valid, framing_error);
      failures = failures + 1;
    end
    else if ((rx_data !== 8'hC3) || (framing_error !== 1'b0)) begin
      $display("Test 8 failed");
      $display("  Expected: rx_data=0x%02h rx_valid=1 framing_error=0", 8'hC3);
      $display("  Actual:   rx_data=0x%02h rx_valid=%b framing_error=%b",
               rx_data, rx_valid, framing_error);
      failures = failures + 1;
    end
    else begin
      $display("Test 8 passed");
      $display("  Expected: rx_data=0x%02h rx_valid=1 framing_error=0", 8'hC3);
      $display("  Actual:   rx_data=0x%02h rx_valid=%b framing_error=%b",
               rx_data, rx_valid, framing_error);
    end

    if (failures == 0)
      $display("All tests passed!");
    else
      $display("Some tests failed");

    $finish;
  end

endmodule