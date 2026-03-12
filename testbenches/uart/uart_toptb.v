`timescale 1ns/1ns

module uart_toptb;

  reg        clk;
  reg        rst;
  reg        rx;
  reg        tx_start;
  reg  [7:0] tx_data;

  wire       tx;
  wire [7:0] rx_data;
  wire       rx_valid;
  wire       tx_busy;
  wire       framing_error;

  integer failures;
  integer test_num;
  integer timeout_count;
  integer valid_seen;

  reg        rx_valid_seen;
  reg [7:0]  rx_data_latched;
  reg        framing_error_seen;

  // --------------------------------------------------------------------------
  // UART timing parameters, adapted from the reference style
  // --------------------------------------------------------------------------
  localparam integer BIT_RATE = 115200;
  localparam integer CLK_HZ   = 25000000;
  localparam integer BIT_P    = 1000000000 / BIT_RATE;
  localparam integer CLK_P    = 1000000000 / CLK_HZ;
  localparam integer CLK_P_2  = 500000000  / CLK_HZ;

  // DUT
  uart_top
  #(
    .BIT_RATE(BIT_RATE),
    .CLK_HZ(CLK_HZ)
  )
  uut
  (
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

  // --------------------------------------------------------------------------
  // Clock generation
  // --------------------------------------------------------------------------
  always #(CLK_P_2) clk = ~clk;

  // --------------------------------------------------------------------------
  // Latch short rx_valid / framing_error pulses so they are not missed
  // --------------------------------------------------------------------------
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      rx_valid_seen      <= 1'b0;
      rx_data_latched    <= 8'h00;
      framing_error_seen <= 1'b0;
    end
    else begin
      if (rx_valid) begin
        rx_valid_seen   <= 1'b1;
        rx_data_latched <= rx_data;
      end

      if (framing_error)
        framing_error_seen <= 1'b1;
    end
  end

  // --------------------------------------------------------------------------
  // Clear latched receive/error events between tests
  // --------------------------------------------------------------------------
  task clear_event_latches;
  begin
    rx_valid_seen      = 1'b0;
    rx_data_latched    = 8'h00;
    framing_error_seen = 1'b0;
  end
  endtask

  // --------------------------------------------------------------------------
  // Sends a single byte down the RX serial line
  // 1 start bit, 8 data bits LSB-first, 1 stop bit
  // --------------------------------------------------------------------------
  task send_byte;
    input [7:0] to_send;
    integer i;
  begin
    $display("Send data 0x%02h at time %0d", to_send, $time);

    #BIT_P;
    rx = 1'b0;  // start bit

    for (i = 0; i < 8; i = i + 1) begin
      #BIT_P;
      rx = to_send[i];
    end

    #BIT_P;
    rx = 1'b1;  // stop bit

    #1000;
  end
  endtask

  // --------------------------------------------------------------------------
  // Sends a byte with an invalid stop bit
  // Hold low long enough to make the framing error unambiguous
  // --------------------------------------------------------------------------
  task send_byte_bad_stop;
    input [7:0] to_send;
    integer i;
  begin
    $display("Send data with bad stop 0x%02h at time %0d", to_send, $time);

    #BIT_P;
    rx = 1'b0;  // start bit

    for (i = 0; i < 8; i = i + 1) begin
      #BIT_P;
      rx = to_send[i];
    end

    #BIT_P;
    rx = 1'b0;  // invalid stop bit

    #BIT_P;
    rx = 1'b0;  // keep low one more bit period

    #BIT_P;
    rx = 1'b1;  // return line to idle

    #1000;
  end
  endtask

  // --------------------------------------------------------------------------
  // Wait for a received byte with timeout
  // --------------------------------------------------------------------------
  task wait_for_valid;
    output integer saw_valid;
    integer timeout_limit;
  begin
    saw_valid = 0;
    timeout_count = 0;
    timeout_limit = 20 * (BIT_P / CLK_P + 1);

    while ((rx_valid_seen !== 1'b1) && (timeout_count < timeout_limit)) begin
      @(posedge clk);
      timeout_count = timeout_count + 1;
    end

    if (rx_valid_seen === 1'b1)
      saw_valid = 1;
  end
  endtask

  // --------------------------------------------------------------------------
  // Check clean idle state
  // --------------------------------------------------------------------------
  task check_idle_state;
  begin
    if ((tx !== 1'b1) ||
        (tx_busy !== 1'b0) ||
        (rx_valid !== 1'b0) ||
        (framing_error !== 1'b0)) begin
      $display("Test %0d failed", test_num);
      $display("  Expected idle: tx=1 tx_busy=0 rx_valid=0 framing_error=0");
      $display("  Actual idle:   tx=%b tx_busy=%b rx_valid=%b framing_error=%b",
               tx, tx_busy, rx_valid, framing_error);
      failures = failures + 1;
    end
    else begin
      $display("Test %0d passed", test_num);
      $display("  Expected idle: tx=1 tx_busy=0 rx_valid=0 framing_error=0");
      $display("  Actual idle:   tx=%b tx_busy=%b rx_valid=%b framing_error=%b",
               tx, tx_busy, rx_valid, framing_error);
    end
    test_num = test_num + 1;
  end
  endtask

  // --------------------------------------------------------------------------
  // Check received byte using latched rx_valid/rx_data
  // --------------------------------------------------------------------------
  task check_byte;
    input [7:0] expected_value;
  begin
    if ((rx_valid_seen === 1'b1) &&
        (rx_data_latched === expected_value) &&
        (framing_error_seen === 1'b0)) begin
      $display("Test %0d passed", test_num);
      $display("  Expected: rx_data=0x%02h rx_valid_seen=1 framing_error_seen=0", expected_value);
      $display("  Actual:   rx_data_latched=0x%02h rx_valid_seen=%b framing_error_seen=%b",
               rx_data_latched, rx_valid_seen, framing_error_seen);
    end
    else begin
      $display("Test %0d failed", test_num);
      $display("  Expected: rx_data=0x%02h rx_valid_seen=1 framing_error_seen=0", expected_value);
      $display("  Actual:   rx_data_latched=0x%02h rx_valid_seen=%b framing_error_seen=%b",
               rx_data_latched, rx_valid_seen, framing_error_seen);
      failures = failures + 1;
    end
    test_num = test_num + 1;
  end
  endtask

  // --------------------------------------------------------------------------
  // Check framing error using latched flag
  // --------------------------------------------------------------------------
  task check_framing_error;
    input [7:0] expected_value;
  begin
    if (framing_error_seen === 1'b1) begin
      $display("Test %0d passed", test_num);
      $display("  Expected: framing_error observed after byte 0x%02h", expected_value);
      $display("  Actual:   rx_data_latched=0x%02h rx_valid_seen=%b framing_error_seen=%b",
               rx_data_latched, rx_valid_seen, framing_error_seen);
    end
    else begin
      $display("Test %0d failed", test_num);
      $display("  Expected: framing_error observed after byte 0x%02h", expected_value);
      $display("  Actual:   rx_data_latched=0x%02h rx_valid_seen=%b framing_error_seen=%b",
               rx_data_latched, rx_valid_seen, framing_error_seen);
      failures = failures + 1;
    end
    test_num = test_num + 1;
  end
  endtask

  // --------------------------------------------------------------------------
  // Test sequence
  // --------------------------------------------------------------------------
  initial begin
    rst                = 1'b1;
    clk                = 1'b0;
    rx                 = 1'b1;
    tx_start           = 1'b0;
    tx_data            = 8'h00;
    failures           = 0;
    test_num           = 1;
    timeout_count      = 0;
    valid_seen         = 0;
    rx_valid_seen      = 1'b0;
    rx_data_latched    = 8'h00;
    framing_error_seen = 1'b0;

    #40 rst = 1'b0;
    #1000;

    // Test 1: idle after reset
    check_idle_state;

    // Test 2: receive 0xFF
    clear_event_latches;
    send_byte(8'hFF);
    wait_for_valid(valid_seen);
    if (valid_seen !== 1) begin
      $display("Test %0d failed", test_num);
      $display("  Expected: rx_valid_seen asserted for byte 0xFF");
      $display("  Actual:   timeout waiting for rx_valid_seen, rx_data_latched=0x%02h framing_error_seen=%b",
               rx_data_latched, framing_error_seen);
      failures = failures + 1;
      test_num = test_num + 1;
    end
    else begin
      check_byte(8'hFF);
    end

    @(posedge clk);

    // Test 3: receive 0xA5
    clear_event_latches;
    send_byte(8'hA5);
    wait_for_valid(valid_seen);
    if (valid_seen !== 1) begin
      $display("Test %0d failed", test_num);
      $display("  Expected: rx_valid_seen asserted for byte 0xA5");
      $display("  Actual:   timeout waiting for rx_valid_seen, rx_data_latched=0x%02h framing_error_seen=%b",
               rx_data_latched, framing_error_seen);
      failures = failures + 1;
      test_num = test_num + 1;
    end
    else begin
      check_byte(8'hA5);
    end

    @(posedge clk);

    // Test 4: receive 0x3C
    clear_event_latches;
    send_byte(8'h3C);
    wait_for_valid(valid_seen);
    if (valid_seen !== 1) begin
      $display("Test %0d failed", test_num);
      $display("  Expected: rx_valid_seen asserted for byte 0x3C");
      $display("  Actual:   timeout waiting for rx_valid_seen, rx_data_latched=0x%02h framing_error_seen=%b",
               rx_data_latched, framing_error_seen);
      failures = failures + 1;
      test_num = test_num + 1;
    end
    else begin
      check_byte(8'h3C);
    end

    @(posedge clk);

    // Test 5: receive 0x00
    clear_event_latches;
    send_byte(8'h00);
    wait_for_valid(valid_seen);
    if (valid_seen !== 1) begin
      $display("Test %0d failed", test_num);
      $display("  Expected: rx_valid_seen asserted for byte 0x00");
      $display("  Actual:   timeout waiting for rx_valid_seen, rx_data_latched=0x%02h framing_error_seen=%b",
               rx_data_latched, framing_error_seen);
      failures = failures + 1;
      test_num = test_num + 1;
    end
    else begin
      check_byte(8'h00);
    end

    @(posedge clk);

    // Test 6: bad stop bit should raise framing_error
    clear_event_latches;
    send_byte_bad_stop(8'h55);
    #(2 * BIT_P);
    @(posedge clk);
    @(posedge clk);
    check_framing_error(8'h55);

    // Test 7: reset restores clean state
    rst = 1'b1;
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;
    @(posedge clk);
    check_idle_state;

    $display("BIT RATE  : %0db/s", BIT_RATE);
    $display("BIT PERIOD: %0dns", BIT_P);
    $display("CLK PERIOD: %0dns", CLK_P);

    if (failures == 0)
      $display("All tests passed!");
    else
      $display("Some tests failed");

    $display("Finish simulation at time %0d", $time);
    $finish();
  end

endmodule