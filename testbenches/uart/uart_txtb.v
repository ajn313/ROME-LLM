`timescale 1ns/1ns

module uart_txtb;

  reg        clk;
  reg        rst;
  reg        baud_tick;
  reg        tx_start;
  reg  [7:0] tx_data;
  wire       tx;
  wire       tx_busy;

  integer failures;
  integer test_num;
  integer accepted;

  reg expected_frame [0:9];
  reg observed_frame [0:9];
  reg busy_frame     [0:9];

  integer baud_count;

  // --------------------------------------------------------------------------
  // UART timing parameters, adapted from the sample style
  // --------------------------------------------------------------------------
  localparam integer BIT_RATE = 115200;
  localparam integer CLK_HZ   = 25000000;
  localparam integer CLK_P    = 1000000000 / CLK_HZ;
  localparam integer CLK_P_2  = 500000000  / CLK_HZ;
  localparam integer BIT_P    = 1000000000 / BIT_RATE;
  localparam integer CYCLES_PER_BIT = CLK_HZ / BIT_RATE;

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

  // --------------------------------------------------------------------------
  // Clock generation
  // --------------------------------------------------------------------------
  always #(CLK_P_2) clk = ~clk;

  // --------------------------------------------------------------------------
  // Baud-tick generation in the testbench
  // One-cycle pulse every CYCLES_PER_BIT clocks
  // --------------------------------------------------------------------------
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      baud_count <= 0;
      baud_tick  <= 1'b0;
    end
    else begin
      if (baud_count == CYCLES_PER_BIT - 1) begin
        baud_count <= 0;
        baud_tick  <= 1'b1;
      end
      else begin
        baud_count <= baud_count + 1;
        baud_tick  <= 1'b0;
      end
    end
  end

  // --------------------------------------------------------------------------
  // Send one byte, adapted from the sample TB
  // Holds tx_start high until tx_busy asserts or timeout occurs
  // --------------------------------------------------------------------------
  task send_byte;
    input [7:0] to_send;
    output integer was_accepted;
    integer timeout;
  begin
    $display("Send data 0x%02h at time %0d", to_send, $time);

    was_accepted = 0;
    tx_data      = to_send;
    tx_start     = 1'b1;
    timeout      = 0;

    while ((tx_busy !== 1'b1) && (timeout < (2 * CYCLES_PER_BIT))) begin
      @(posedge clk);
      timeout = timeout + 1;
    end

    if (tx_busy === 1'b1)
      was_accepted = 1;

    tx_start = 1'b0;
    @(posedge clk);
  end
  endtask

  // --------------------------------------------------------------------------
  // Wait until tx_busy deasserts, similar to the sample TB
  // --------------------------------------------------------------------------
  task wait_until_not_busy;
    integer timeout;
  begin
    timeout = 0;
    while ((tx_busy === 1'b1) && (timeout < (20 * CYCLES_PER_BIT))) begin
      @(posedge clk);
      timeout = timeout + 1;
    end
  end
  endtask

  // --------------------------------------------------------------------------
  // Wait for the next baud boundary, then sample on the following clock
  // This avoids racing DUT updates on the baud_tick clock edge
  // --------------------------------------------------------------------------
  task wait_next_symbol_and_sample;
    integer found;
  begin
    found = 0;
    while (found == 0) begin
      @(posedge clk);
      if (baud_tick === 1'b1) begin
        @(posedge clk);
        found = 1;
      end
    end
  end
  endtask

  // --------------------------------------------------------------------------
  // Build expected 10-bit UART frame: start + 8 data + stop
  // --------------------------------------------------------------------------
  task build_expected_frame;
    input [7:0] data_byte;
  begin
    expected_frame[0] = 1'b0;
    expected_frame[1] = data_byte[0];
    expected_frame[2] = data_byte[1];
    expected_frame[3] = data_byte[2];
    expected_frame[4] = data_byte[3];
    expected_frame[5] = data_byte[4];
    expected_frame[6] = data_byte[5];
    expected_frame[7] = data_byte[6];
    expected_frame[8] = data_byte[7];
    expected_frame[9] = 1'b1;
  end
  endtask

  // --------------------------------------------------------------------------
  // Capture one full frame.
  // Since tx_busy assertion coincides with the start bit in this DUT behavior,
  // sample the current tx first, then advance symbol-by-symbol.
  // --------------------------------------------------------------------------
  task capture_frame;
    integer k;
  begin
    observed_frame[0] = tx;
    busy_frame[0]     = tx_busy;

    for (k = 1; k < 10; k = k + 1) begin
      wait_next_symbol_and_sample;
      observed_frame[k] = tx;
      busy_frame[k]     = tx_busy;
    end
  end
  endtask

  // --------------------------------------------------------------------------
  // Debug prints
  // --------------------------------------------------------------------------
  task print_frame_comparison;
    input [7:0] data_byte;
  begin
    $display("  Byte under test: 0x%02h", data_byte);
    $display("  Frame format: [start][d0][d1][d2][d3][d4][d5][d6][d7][stop]");
    $display("  Expected:      %b %b %b %b %b %b %b %b %b %b",
      expected_frame[0], expected_frame[1], expected_frame[2], expected_frame[3], expected_frame[4],
      expected_frame[5], expected_frame[6], expected_frame[7], expected_frame[8], expected_frame[9]);
    $display("  Actual:        %b %b %b %b %b %b %b %b %b %b",
      observed_frame[0], observed_frame[1], observed_frame[2], observed_frame[3], observed_frame[4],
      observed_frame[5], observed_frame[6], observed_frame[7], observed_frame[8], observed_frame[9]);
  end
  endtask

  task print_frame_timeline;
  begin
    $display("  Timeline:");
    $display("    tick 0  start : tx=%b tx_busy=%b", observed_frame[0], busy_frame[0]);
    $display("    tick 1  d0    : tx=%b tx_busy=%b", observed_frame[1], busy_frame[1]);
    $display("    tick 2  d1    : tx=%b tx_busy=%b", observed_frame[2], busy_frame[2]);
    $display("    tick 3  d2    : tx=%b tx_busy=%b", observed_frame[3], busy_frame[3]);
    $display("    tick 4  d3    : tx=%b tx_busy=%b", observed_frame[4], busy_frame[4]);
    $display("    tick 5  d4    : tx=%b tx_busy=%b", observed_frame[5], busy_frame[5]);
    $display("    tick 6  d5    : tx=%b tx_busy=%b", observed_frame[6], busy_frame[6]);
    $display("    tick 7  d6    : tx=%b tx_busy=%b", observed_frame[7], busy_frame[7]);
    $display("    tick 8  d7    : tx=%b tx_busy=%b", observed_frame[8], busy_frame[8]);
    $display("    tick 9  stop  : tx=%b tx_busy=%b", observed_frame[9], busy_frame[9]);
  end
  endtask

  // --------------------------------------------------------------------------
  // Frame checker
  // If tx_busy drops early, report early termination and only compare the
  // symbols captured while the transmitter was still active.
  // --------------------------------------------------------------------------
  task check_full_frame;
    input [7:0] data_byte;
    integer mismatch_found;
    integer first_bad_index;
    integer first_busy_low;
    integer j;
  begin
    mismatch_found = 0;
    first_bad_index = -1;
    first_busy_low = -1;

    for (j = 0; j < 10; j = j + 1) begin
      if ((busy_frame[j] !== 1'b1) && (first_busy_low == -1))
        first_busy_low = j;
    end

    if (first_busy_low != -1) begin
      for (j = 0; j < first_busy_low; j = j + 1) begin
        if ((observed_frame[j] !== expected_frame[j]) && (mismatch_found == 0)) begin
          mismatch_found = 1;
          first_bad_index = j;
        end
      end

      $display("Test %0d failed", test_num);
      print_frame_comparison(data_byte);
      print_frame_timeline;
      $display("  Frame terminated early");
      $display("  Expected active frame length: 10 symbols");
      $display("  Actual active frame length:   %0d symbols", first_busy_low);
      $display("  Note: samples at and after index %0d were taken after tx_busy dropped and are not treated as valid transmitted data.", first_busy_low);

      if (mismatch_found != 0) begin
        $display("  First mismatch while active at frame index %0d", first_bad_index);
        if (first_bad_index == 0)
          $display("  Meaning: start bit is wrong");
        else
          $display("  Meaning: data bit %0d is wrong before early termination", first_bad_index - 1);
      end
      else begin
        $display("  All symbols matched up to the point where transmission ended.");
      end

      failures = failures + 1;
    end
    else begin
      for (j = 0; j < 10; j = j + 1) begin
        if ((observed_frame[j] !== expected_frame[j]) && (mismatch_found == 0)) begin
          mismatch_found = 1;
          first_bad_index = j;
        end
      end

      if (mismatch_found != 0) begin
        $display("Test %0d failed", test_num);
        print_frame_comparison(data_byte);
        print_frame_timeline;
        $display("  First mismatch at frame index %0d", first_bad_index);

        if (first_bad_index == 0)
          $display("  Meaning: start bit timing is wrong");
        else if (first_bad_index == 9)
          $display("  Meaning: stop bit is wrong");
        else
          $display("  Meaning: data bit %0d is wrong", first_bad_index - 1);

        failures = failures + 1;
      end
      else begin
        $display("Test %0d passed", test_num);
        print_frame_comparison(data_byte);
        print_frame_timeline;
      end
    end

    test_num = test_num + 1;
  end
  endtask

  // --------------------------------------------------------------------------
  // Idle checker
  // --------------------------------------------------------------------------
  task check_idle_state;
  begin
    if ((tx !== 1'b1) || (tx_busy !== 1'b0)) begin
      $display("Test %0d failed", test_num);
      $display("  Expected idle: tx=1 tx_busy=0");
      $display("  Actual idle:   tx=%b tx_busy=%b", tx, tx_busy);
      failures = failures + 1;
    end
    else begin
      $display("Test %0d passed", test_num);
      $display("  Expected idle: tx=1 tx_busy=0");
      $display("  Actual idle:   tx=%b tx_busy=%b", tx, tx_busy);
    end
    test_num = test_num + 1;
  end
  endtask

  // --------------------------------------------------------------------------
  // Test sequence
  // --------------------------------------------------------------------------
  initial begin
    rst       = 1'b1;
    clk       = 1'b0;
    baud_tick = 1'b0;
    tx_start  = 1'b0;
    tx_data   = 8'h00;
    failures  = 0;
    test_num  = 1;
    accepted  = 0;
    baud_count = 0;

    #40 rst = 1'b0;

    // Test 1: idle after reset
    check_idle_state;

    // Test 2: send 0x96 request accepted
    send_byte(8'h96, accepted);
    if (accepted !== 1) begin
      $display("Test %0d failed", test_num);
      $display("  Expected: transmitter accepts 0x96 and asserts tx_busy");
      $display("  Actual:   tx_busy never asserted within timeout");
      failures = failures + 1;
      test_num = test_num + 1;
    end
    else begin
      $display("Test %0d passed", test_num);
      $display("  Expected: transmitter accepts 0x96 and asserts tx_busy");
      $display("  Actual:   tx=%b tx_busy=%b", tx, tx_busy);
      test_num = test_num + 1;
    end

    // Test 3: frame check for 0x96
    build_expected_frame(8'h96);
    capture_frame;
    check_full_frame(8'h96);
    wait_until_not_busy;

    // Test 4: idle after first frame
    check_idle_state;

    // Test 5: send 0x53 request accepted
    send_byte(8'h53, accepted);
    if (accepted !== 1) begin
      $display("Test %0d failed", test_num);
      $display("  Expected: transmitter accepts 0x53 and asserts tx_busy");
      $display("  Actual:   tx_busy never asserted within timeout");
      failures = failures + 1;
      test_num = test_num + 1;
    end
    else begin
      $display("Test %0d passed", test_num);
      $display("  Expected: transmitter accepts 0x53 and asserts tx_busy");
      $display("  Actual:   tx=%b tx_busy=%b", tx, tx_busy);
      test_num = test_num + 1;
    end

    // Test 6: frame check for 0x53
    build_expected_frame(8'h53);
    capture_frame;
    check_full_frame(8'h53);
    wait_until_not_busy;

    // Test 7: idle after second frame
    check_idle_state;

    // Test 8: reset during activity
    send_byte(8'hF0, accepted);
    wait_next_symbol_and_sample;
    wait_next_symbol_and_sample;
    rst = 1'b1;
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;
    @(posedge clk);

    if ((tx !== 1'b1) || (tx_busy !== 1'b0)) begin
      $display("Test %0d failed", test_num);
      $display("  Expected after reset: tx=1 tx_busy=0");
      $display("  Actual after reset:   tx=%b tx_busy=%b", tx, tx_busy);
      failures = failures + 1;
    end
    else begin
      $display("Test %0d passed", test_num);
      $display("  Expected after reset: tx=1 tx_busy=0");
      $display("  Actual after reset:   tx=%b tx_busy=%b", tx, tx_busy);
    end

    $display("BIT RATE  : %0db/s", BIT_RATE);
    $display("BIT PERIOD: %0dns", BIT_P);
    $display("CLK PERIOD: %0dns", CLK_P);
    $display("CYCLES/BIT: %0d", CYCLES_PER_BIT);

    if (failures == 0)
      $display("All tests passed!");
    else
      $display("Some tests failed");

    $display("Finish simulation at time %0d", $time);
    $finish();
  end

endmodule