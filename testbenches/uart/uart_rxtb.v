`timescale 1ns/1ns

module uart_rxtb;

  reg        clk;
  reg        rst;
  reg        oversample_tick;
  reg        rx;

  wire [7:0] rx_data;
  wire       rx_valid;
  wire       framing_error;

  integer failures;
  integer test_num;
  integer valid_seen;
  integer timeout_count;

  reg framing_error_seen;

  // --------------------------------------------------------------------------
  // UART timing parameters, adapted from the sample style
  // --------------------------------------------------------------------------
  localparam integer BIT_RATE          = 115200;
  localparam integer OVERSAMPLE        = 16;
  localparam integer CLK_HZ            = 25000000;
  localparam integer CLK_P             = 1000000000 / CLK_HZ;
  localparam integer CLK_P_2           = 500000000  / CLK_HZ;
  localparam integer BIT_P             = 1000000000 / BIT_RATE;
  localparam integer SAMPLE_RATE       = BIT_RATE * OVERSAMPLE;
  localparam integer CYCLES_PER_SAMPLE = CLK_HZ / SAMPLE_RATE;

  integer sample_count;

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

  // --------------------------------------------------------------------------
  // Clock generation
  // --------------------------------------------------------------------------
  always #(CLK_P_2) clk = ~clk;

  // --------------------------------------------------------------------------
  // Oversample tick generation in the testbench
  // One-cycle pulse every CYCLES_PER_SAMPLE clocks
  // --------------------------------------------------------------------------
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      sample_count     <= 0;
      oversample_tick  <= 1'b0;
    end
    else begin
      if (sample_count == CYCLES_PER_SAMPLE - 1) begin
        sample_count    <= 0;
        oversample_tick <= 1'b1;
      end
      else begin
        sample_count    <= sample_count + 1;
        oversample_tick <= 1'b0;
      end
    end
  end

  // --------------------------------------------------------------------------
  // Latch whether framing_error was ever seen
  // --------------------------------------------------------------------------
  always @(posedge clk or posedge rst) begin
    if (rst)
      framing_error_seen <= 1'b0;
    else if (framing_error)
      framing_error_seen <= 1'b1;
  end

  // --------------------------------------------------------------------------
  // Send one UART byte on rx: start + 8 data bits + stop
  // LSB first, adapted from the sample RX TB
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
  // Send one UART byte with a bad stop bit
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

    #1000;
    rx = 1'b1;  // return line to idle
    #1000;
  end
  endtask

  // --------------------------------------------------------------------------
  // Wait for rx_valid with timeout
  // --------------------------------------------------------------------------
  task wait_for_valid;
    output integer saw_valid;
    integer timeout_limit;
  begin
    saw_valid = 0;
    timeout_count = 0;
    timeout_limit = 20 * CYCLES_PER_SAMPLE * OVERSAMPLE;

    while ((rx_valid !== 1'b1) && (timeout_count < timeout_limit)) begin
      @(posedge clk);
      timeout_count = timeout_count + 1;
    end

    if (rx_valid === 1'b1)
      saw_valid = 1;
  end
  endtask

  // --------------------------------------------------------------------------
  // Check expected received byte
  // --------------------------------------------------------------------------
  task check_byte;
    input [7:0] expected_value;
  begin
    if ((rx_data === expected_value) &&
        (rx_valid === 1'b1) &&
        (framing_error === 1'b0)) begin
      $display("Test %0d passed", test_num);
      $display("  Expected: rx_data=0x%02h rx_valid=1 framing_error=0", expected_value);
      $display("  Actual:   rx_data=0x%02h rx_valid=%b framing_error=%b", rx_data, rx_valid, framing_error);
    end
    else begin
      $display("Test %0d failed", test_num);
      $display("  Expected: rx_data=0x%02h rx_valid=1 framing_error=0", expected_value);
      $display("  Actual:   rx_data=0x%02h rx_valid=%b framing_error=%b", rx_data, rx_valid, framing_error);
      failures = failures + 1;
    end
    test_num = test_num + 1;
  end
  endtask

  // --------------------------------------------------------------------------
  // Check framing error using a latched flag so short pulses are not missed
  // --------------------------------------------------------------------------
  task check_framing_error;
    input [7:0] expected_value;
  begin
    if (framing_error_seen === 1'b1) begin
      $display("Test %0d passed", test_num);
      $display("  Expected: framing_error observed after byte 0x%02h", expected_value);
      $display("  Actual:   rx_data=0x%02h rx_valid=%b framing_error=%b framing_error_seen=%b",
               rx_data, rx_valid, framing_error, framing_error_seen);
    end
    else begin
      $display("Test %0d failed", test_num);
      $display("  Expected: framing_error observed after byte 0x%02h", expected_value);
      $display("  Actual:   rx_data=0x%02h rx_valid=%b framing_error=%b framing_error_seen=%b",
               rx_data, rx_valid, framing_error, framing_error_seen);
      failures = failures + 1;
    end
    test_num = test_num + 1;
  end
  endtask

  // --------------------------------------------------------------------------
  // Check idle/reset state
  // --------------------------------------------------------------------------
  task check_idle_state;
  begin
    if ((rx_valid !== 1'b0) || (framing_error !== 1'b0)) begin
      $display("Test %0d failed", test_num);
      $display("  Expected idle/reset state: rx_valid=0 framing_error=0");
      $display("  Actual idle/reset state:   rx_valid=%b framing_error=%b", rx_valid, framing_error);
      failures = failures + 1;
    end
    else begin
      $display("Test %0d passed", test_num);
      $display("  Expected idle/reset state: rx_valid=0 framing_error=0");
      $display("  Actual idle/reset state:   rx_valid=%b framing_error=%b", rx_valid, framing_error);
    end
    test_num = test_num + 1;
  end
  endtask

  // --------------------------------------------------------------------------
  // Test sequence
  // --------------------------------------------------------------------------
  initial begin
    rst               = 1'b1;
    clk               = 1'b0;
    oversample_tick   = 1'b0;
    rx                = 1'b1;
    failures          = 0;
    test_num          = 1;
    valid_seen        = 0;
    sample_count      = 0;
    framing_error_seen = 1'b0;

    #40 rst = 1'b0;
    #1000;

    // Test 1: idle after reset
    check_idle_state;

    // Test 2: receive 0xFF
    send_byte(8'hFF);
    wait_for_valid(valid_seen);
    if (valid_seen !== 1) begin
      $display("Test %0d failed", test_num);
      $display("  Expected: rx_valid asserted for byte 0xFF");
      $display("  Actual:   timeout waiting for rx_valid, rx_data=0x%02h framing_error=%b", rx_data, framing_error);
      failures = failures + 1;
      test_num = test_num + 1;
    end
    else begin
      check_byte(8'hFF);
    end

    @(posedge clk);

    // Test 3: receive 0xA5
    send_byte(8'hA5);
    wait_for_valid(valid_seen);
    if (valid_seen !== 1) begin
      $display("Test %0d failed", test_num);
      $display("  Expected: rx_valid asserted for byte 0xA5");
      $display("  Actual:   timeout waiting for rx_valid, rx_data=0x%02h framing_error=%b", rx_data, framing_error);
      failures = failures + 1;
      test_num = test_num + 1;
    end
    else begin
      check_byte(8'hA5);
    end

    @(posedge clk);

    // Test 4: receive 0x3C
    send_byte(8'h3C);
    wait_for_valid(valid_seen);
    if (valid_seen !== 1) begin
      $display("Test %0d failed", test_num);
      $display("  Expected: rx_valid asserted for byte 0x3C");
      $display("  Actual:   timeout waiting for rx_valid, rx_data=0x%02h framing_error=%b", rx_data, framing_error);
      failures = failures + 1;
      test_num = test_num + 1;
    end
    else begin
      check_byte(8'h3C);
    end

    @(posedge clk);

    // Test 5: receive 0x00
    send_byte(8'h00);
    wait_for_valid(valid_seen);
    if (valid_seen !== 1) begin
      $display("Test %0d failed", test_num);
      $display("  Expected: rx_valid asserted for byte 0x00");
      $display("  Actual:   timeout waiting for rx_valid, rx_data=0x%02h framing_error=%b", rx_data, framing_error);
      failures = failures + 1;
      test_num = test_num + 1;
    end
    else begin
      check_byte(8'h00);
    end

    @(posedge clk);

    // Test 6: bad stop bit should raise framing_error
    framing_error_seen = 1'b0;
    send_byte_bad_stop(8'h55);
    #(BIT_P);
    @(posedge clk);
    check_framing_error(8'h55);

    // Test 7: reset restores clean state
    rst = 1'b1;
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;
    @(posedge clk);
    check_idle_state;

    $display("BIT RATE      : %0db/s", BIT_RATE);
    $display("CLK PERIOD    : %0dns", CLK_P);
    $display("BIT PERIOD    : %0dns", BIT_P);
    $display("OVERSAMPLE    : %0d", OVERSAMPLE);
    $display("SAMPLE RATE   : %0d", SAMPLE_RATE);
    $display("CYCLES/SAMPLE : %0d", CYCLES_PER_SAMPLE);

    if (failures == 0)
      $display("All tests passed!");
    else
      $display("Some tests failed");

    $display("Finish simulation at time %0d", $time);
    $finish();
  end

endmodule