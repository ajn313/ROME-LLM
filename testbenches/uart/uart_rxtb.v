`timescale 1ns / 1ps

module uart_rxtb;

  reg clk;
  reg rst;
  reg oversample_tick;
  reg rx;
  wire [7:0] rx_data;
  wire rx_valid;
  wire framing_error;

  integer failures;
  integer i;

  uart_rx dut (
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
    forever #20 clk = ~clk;
  end

  task pulse_oversample_tick;
    begin
      oversample_tick = 1'b1;
      @(posedge clk);
      oversample_tick = 1'b0;
      @(posedge clk);
    end
  endtask

  task hold_line_for_16_ticks;
    input line_value;
    integer j;
    begin
      rx = line_value;
      for (j = 0; j < 16; j = j + 1)
        pulse_oversample_tick;
    end
  endtask

  task send_uart_byte;
    input [7:0] data_byte;
    begin
      // Start bit
      hold_line_for_16_ticks(1'b0);

      // 8 data bits, LSB first
      hold_line_for_16_ticks(data_byte[0]);
      hold_line_for_16_ticks(data_byte[1]);
      hold_line_for_16_ticks(data_byte[2]);
      hold_line_for_16_ticks(data_byte[3]);
      hold_line_for_16_ticks(data_byte[4]);
      hold_line_for_16_ticks(data_byte[5]);
      hold_line_for_16_ticks(data_byte[6]);
      hold_line_for_16_ticks(data_byte[7]);

      // Stop bit
      hold_line_for_16_ticks(1'b1);
    end
  endtask

  task send_uart_byte_bad_stop;
    input [7:0] data_byte;
    begin
      // Start bit
      hold_line_for_16_ticks(1'b0);

      // 8 data bits, LSB first
      hold_line_for_16_ticks(data_byte[0]);
      hold_line_for_16_ticks(data_byte[1]);
      hold_line_for_16_ticks(data_byte[2]);
      hold_line_for_16_ticks(data_byte[3]);
      hold_line_for_16_ticks(data_byte[4]);
      hold_line_for_16_ticks(data_byte[5]);
      hold_line_for_16_ticks(data_byte[6]);
      hold_line_for_16_ticks(data_byte[7]);

      // Bad stop bit
      hold_line_for_16_ticks(1'b0);
    end
  endtask

  initial begin
    failures = 0;
    rst = 1'b1;
    oversample_tick = 1'b0;
    rx = 1'b1;

    // -------------------------
    // Test 1: Reset / idle behavior
    // -------------------------
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;
    @(posedge clk);

    if ((rx_valid === 1'b0) && (framing_error === 1'b0)) begin
      $display("Test 1 passed");
    end else begin
      $display("Test 1 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 2: Idle high line should not produce data valid
    // -------------------------
    rx = 1'b1;
    for (i = 0; i < 40; i = i + 1)
      pulse_oversample_tick;

    if ((rx_valid === 1'b0) && (framing_error === 1'b0)) begin
      $display("Test 2 passed");
    end else begin
      $display("Test 2 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 3: Receive 8'hFF correctly
    // -------------------------
    send_uart_byte(8'hFF);
    @(posedge clk);

    if ((rx_valid === 1'b1) && (rx_data === 8'hFF) && (framing_error === 1'b0)) begin
      $display("Test 3 passed");
    end else begin
      $display("Test 3 failed");
      failures = failures + 1;
    end

    // Allow rx_valid pulse to clear in many common implementations
    @(posedge clk);

    // -------------------------
    // Test 4: Receive 8'hA5 correctly
    // 8'hA5 = 1010_0101
    // -------------------------
    send_uart_byte(8'hA5);
    @(posedge clk);

    if ((rx_valid === 1'b1) && (rx_data === 8'hA5) && (framing_error === 1'b0)) begin
      $display("Test 4 passed");
    end else begin
      $display("Test 4 failed");
      failures = failures + 1;
    end

    @(posedge clk);

    // -------------------------
    // Test 5: Receive 8'h3C correctly
    // 8'h3C = 0011_1100
    // -------------------------
    send_uart_byte(8'h3C);
    @(posedge clk);

    if ((rx_valid === 1'b1) && (rx_data === 8'h3C) && (framing_error === 1'b0)) begin
      $display("Test 5 passed");
    end else begin
      $display("Test 5 failed");
      failures = failures + 1;
    end

    @(posedge clk);

    // -------------------------
    // Test 6: Bad stop bit should raise framing_error
    // -------------------------
    send_uart_byte_bad_stop(8'h55);
    @(posedge clk);

    if (framing_error === 1'b1) begin
      $display("Test 6 passed");
    end else begin
      $display("Test 6 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 7: Reset clears status
    // -------------------------
    rst = 1'b1;
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;
    @(posedge clk);

    if ((rx_valid === 1'b0) && (framing_error === 1'b0)) begin
      $display("Test 7 passed");
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