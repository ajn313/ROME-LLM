`timescale 1ns / 1ps

module uart_toptb;

  // 25 MHz clock => 40 ns period
  parameter TB_CLOCK_PERIOD_NS = 40;

  reg clk;
  reg rst;
  reg tx_start;
  reg [7:0] tx_data;
  wire tx;
  wire [7:0] rx_data;
  wire rx_valid;
  wire tx_busy;
  wire framing_error;

  // Loopback wire
  wire rx;

  integer failures;

  assign rx = tx;

  uart_top dut (
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
    forever #(TB_CLOCK_PERIOD_NS/2) clk = ~clk;
  end

  task start_tx;
    input [7:0] data_byte;
    begin
      @(posedge clk);
      tx_data   = data_byte;
      tx_start  = 1'b1;
      @(posedge clk);
      tx_start  = 1'b0;
    end
  endtask

  task wait_for_rx_and_check;
    input [7:0] expected;
    input integer test_num;
    begin
      wait (rx_valid == 1'b1);
      @(posedge clk);

      if ((rx_data === expected) && (framing_error === 1'b0)) begin
        $display("Test %0d passed", test_num);
      end else begin
        $display("Test %0d failed", test_num);
        failures = failures + 1;
      end

      @(posedge clk);
    end
  endtask

  initial begin
    failures = 0;
    rst = 1'b1;
    tx_start = 1'b0;
    tx_data = 8'h00;

    // -------------------------
    // Test 1: Reset / idle behavior
    // -------------------------
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;
    @(posedge clk);

    if ((tx === 1'b1) && (tx_busy === 1'b0) && (rx_valid === 1'b0) && (framing_error === 1'b0)) begin
      $display("Test 1 passed");
    end else begin
      $display("Test 1 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 2: Loop back 8'hFF
    // Adapted directly from your sample bench concept
    // -------------------------
    start_tx(8'hFF);
    wait_for_rx_and_check(8'hFF, 2);

    // -------------------------
    // Test 3: Loop back 8'h00
    // -------------------------
    start_tx(8'h00);
    wait_for_rx_and_check(8'h00, 3);

    // -------------------------
    // Test 4: Loop back 8'hA5
    // -------------------------
    start_tx(8'hA5);
    wait_for_rx_and_check(8'hA5, 4);

    // -------------------------
    // Test 5: Loop back 8'h3C
    // -------------------------
    start_tx(8'h3C);
    wait_for_rx_and_check(8'h3C, 5);

    // -------------------------
    // Test 6: tx_busy should assert during transmit
    // -------------------------
    @(posedge clk);
    tx_data  = 8'h55;
    tx_start = 1'b1;
    @(posedge clk);
    tx_start = 1'b0;
    @(posedge clk);

    if (tx_busy === 1'b1) begin
      $display("Test 6 passed");
    end else begin
      $display("Test 6 failed");
      failures = failures + 1;
    end

    wait_for_rx_and_check(8'h55, 7);

    // -------------------------
    // Test 8: After transfer completes, transmitter returns idle
    // -------------------------
    wait (tx_busy == 1'b0);
    @(posedge clk);

    if (tx === 1'b1) begin
      $display("Test 8 passed");
    end else begin
      $display("Test 8 failed");
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

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, uart_toptb);
  end

endmodule