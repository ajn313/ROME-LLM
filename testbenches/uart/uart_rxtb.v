`timescale 1ns/1ps

module uart_rxtb;

  parameter CLOCK_PERIOD_NS = 40;
  parameter OVERSAMPLE      = 4;

  reg clk;
  reg rst;
  reg oversample_tick;
  reg rx;

  wire [7:0] rx_data;
  wire       rx_valid;
  wire       framing_error;

  integer failures;
  integer i;
  reg [7:0] test_byte;

  // DUT
  uart_rx
  #(
    .OVERSAMPLE(OVERSAMPLE)
  )
  uut
  (
    .clk(clk),
    .rst(rst),
    .oversample_tick(oversample_tick),
    .rx(rx),
    .rx_data(rx_data),
    .rx_valid(rx_valid),
    .framing_error(framing_error)
  );

  // Clock generation
  initial begin
    clk = 1'b0;
    forever #(CLOCK_PERIOD_NS/2) clk = ~clk;
  end

  // Generate one oversample tick pulse
  task pulse_oversample_tick;
  begin
    @(posedge clk);
    oversample_tick = 1'b1;
    @(posedge clk);
    oversample_tick = 1'b0;
  end
  endtask

  // Hold current RX level for one full UART bit time
  task send_bit;
    input bit_value;
    integer j;
  begin
    rx = bit_value;
    for (j = 0; j < OVERSAMPLE; j = j + 1)
      pulse_oversample_tick;
  end
  endtask

  // Send one UART byte: start + 8 data bits + stop
  task send_uart_byte;
    input [7:0] data_byte;
    integer k;
  begin
    send_bit(1'b0); // start bit
    for (k = 0; k < 8; k = k + 1)
      send_bit(data_byte[k]); // LSB first
    send_bit(1'b1); // stop bit
  end
  endtask

  // Send one UART byte with a bad stop bit
  task send_uart_byte_bad_stop;
    input [7:0] data_byte;
    integer k;
  begin
    send_bit(1'b0); // start bit
    for (k = 0; k < 8; k = k + 1)
      send_bit(data_byte[k]); // LSB first
    send_bit(1'b0); // invalid stop bit
  end
  endtask

  initial begin
    failures        = 0;
    rst             = 1'b1;
    oversample_tick = 1'b0;
    rx              = 1'b1;
    test_byte       = 8'h00;

    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;
    @(posedge clk);

    // ----------------------------
    // Test 1: Idle/reset state
    // ----------------------------
    if ((rx_valid !== 1'b0) || (framing_error !== 1'b0)) begin
      $display("Test 1 failed");
      $display("  Expected: rx_valid=0 framing_error=0");
      $display("  Actual:   rx_valid=%b framing_error=%b", rx_valid, framing_error);
      failures = failures + 1;
    end
    else begin
      $display("Test 1 passed");
      $display("  Expected: rx_valid=0 framing_error=0");
      $display("  Actual:   rx_valid=%b framing_error=%b", rx_valid, framing_error);
    end

    // ----------------------------
    // Test 2: Receive 8'hFF correctly
    // ----------------------------
    test_byte = 8'hFF;
    send_uart_byte(test_byte);

    @(posedge clk);

    if (rx_data !== 8'hFF || rx_valid !== 1'b1 || framing_error !== 1'b0) begin
      $display("Test 2 failed");
      $display("  Expected: rx_data=0x%02h rx_valid=1 framing_error=0", 8'hFF);
      $display("  Actual:   rx_data=0x%02h rx_valid=%b framing_error=%b", rx_data, rx_valid, framing_error);
      failures = failures + 1;
    end
    else begin
      $display("Test 2 passed");
      $display("  Expected: rx_data=0x%02h rx_valid=1 framing_error=0", 8'hFF);
      $display("  Actual:   rx_data=0x%02h rx_valid=%b framing_error=%b", rx_data, rx_valid, framing_error);
    end

    pulse_oversample_tick;
    @(posedge clk);

    // ----------------------------
    // Test 3: Receive 8'hA5 correctly
    // 8'hA5 = 1010_0101
    // LSB-first serial order: 1 0 1 0 0 1 0 1
    // ----------------------------
    test_byte = 8'hA5;
    send_uart_byte(test_byte);

    @(posedge clk);

    if (rx_data !== 8'hA5 || rx_valid !== 1'b1 || framing_error !== 1'b0) begin
      $display("Test 3 failed");
      $display("  Expected: rx_data=0x%02h rx_valid=1 framing_error=0", 8'hA5);
      $display("  Actual:   rx_data=0x%02h rx_valid=%b framing_error=%b", rx_data, rx_valid, framing_error);
      failures = failures + 1;
    end
    else begin
      $display("Test 3 passed");
      $display("  Expected: rx_data=0x%02h rx_valid=1 framing_error=0", 8'hA5);
      $display("  Actual:   rx_data=0x%02h rx_valid=%b framing_error=%b", rx_data, rx_valid, framing_error);
    end

    pulse_oversample_tick;
    @(posedge clk);

    // ----------------------------
    // Test 4: Receive 8'h3C correctly
    // ----------------------------
    test_byte = 8'h3C;
    send_uart_byte(test_byte);

    @(posedge clk);

    if (rx_data !== 8'h3C || rx_valid !== 1'b1 || framing_error !== 1'b0) begin
      $display("Test 4 failed");
      $display("  Expected: rx_data=0x%02h rx_valid=1 framing_error=0", 8'h3C);
      $display("  Actual:   rx_data=0x%02h rx_valid=%b framing_error=%b", rx_data, rx_valid, framing_error);
      failures = failures + 1;
    end
    else begin
      $display("Test 4 passed");
      $display("  Expected: rx_data=0x%02h rx_valid=1 framing_error=0", 8'h3C);
      $display("  Actual:   rx_data=0x%02h rx_valid=%b framing_error=%b", rx_data, rx_valid, framing_error);
    end

    pulse_oversample_tick;
    @(posedge clk);

    // ----------------------------
    // Test 5: Framing error on invalid stop bit
    // ----------------------------
    test_byte = 8'h55;
    send_uart_byte_bad_stop(test_byte);

    @(posedge clk);

    if (framing_error !== 1'b1) begin
      $display("Test 5 failed");
      $display("  Expected framing_error: 1");
      $display("  Actual framing_error:   %b", framing_error);
      $display("  Expected rx_data:       0x%02h", 8'h55);
      $display("  Actual rx_data:         0x%02h", rx_data);
      failures = failures + 1;
    end
    else begin
      $display("Test 5 passed");
      $display("  Expected framing_error: 1");
      $display("  Actual framing_error:   %b", framing_error);
      $display("  Expected rx_data:       0x%02h", 8'h55);
      $display("  Actual rx_data:         0x%02h", rx_data);
    end

    pulse_oversample_tick;
    @(posedge clk);

    // ----------------------------
    // Test 6: Reset restores clean idle state
    // ----------------------------
    rst = 1'b1;
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;
    @(posedge clk);

    if ((rx_valid !== 1'b0) || (framing_error !== 1'b0)) begin
      $display("Test 6 failed");
      $display("  Expected after reset: rx_valid=0 framing_error=0");
      $display("  Actual after reset:   rx_valid=%b framing_error=%b", rx_valid, framing_error);
      failures = failures + 1;
    end
    else begin
      $display("Test 6 passed");
      $display("  Expected after reset: rx_valid=0 framing_error=0");
      $display("  Actual after reset:   rx_valid=%b framing_error=%b", rx_valid, framing_error);
    end

    // ----------------------------
    // Test 7: Receive 8'h00 correctly after reset
    // ----------------------------
    test_byte = 8'h00;
    send_uart_byte(test_byte);

    @(posedge clk);

    if (rx_data !== 8'h00 || rx_valid !== 1'b1 || framing_error !== 1'b0) begin
      $display("Test 7 failed");
      $display("  Expected: rx_data=0x%02h rx_valid=1 framing_error=0", 8'h00);
      $display("  Actual:   rx_data=0x%02h rx_valid=%b framing_error=%b", rx_data, rx_valid, framing_error);
      failures = failures + 1;
    end
    else begin
      $display("Test 7 passed");
      $display("  Expected: rx_data=0x%02h rx_valid=1 framing_error=0", 8'h00);
      $display("  Actual:   rx_data=0x%02h rx_valid=%b framing_error=%b", rx_data, rx_valid, framing_error);
    end

    if (failures == 0)
      $display("All tests passed!");
    else
      $display("Some tests failed");

    $finish;
  end

endmodule