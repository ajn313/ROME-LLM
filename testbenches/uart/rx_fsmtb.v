`timescale 1ns / 1ps

module rx_fsmtb;

  reg clk;
  reg rst;
  reg oversample_tick;
  reg rx;
  reg sample_now;
  reg [2:0] bit_count;
  wire shift;
  wire clr_sample;
  wire rx_valid;
  wire framing_error;

  integer failures;
  integer i;

  rx_fsm dut (
    .clk(clk),
    .rst(rst),
    .oversample_tick(oversample_tick),
    .rx(rx),
    .sample_now(sample_now),
    .bit_count(bit_count),
    .shift(shift),
    .clr_sample(clr_sample),
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

  task pulse_sample_now;
    begin
      sample_now = 1'b1;
      @(posedge clk);
      sample_now = 1'b0;
      @(posedge clk);
    end
  endtask

  initial begin
    failures = 0;
    rst = 1'b1;
    oversample_tick = 1'b0;
    rx = 1'b1;
    sample_now = 1'b0;
    bit_count = 3'b000;

    // -------------------------
    // Test 1: Reset / idle behavior
    // -------------------------
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;
    @(posedge clk);

    if ((shift === 1'b0) && (rx_valid === 1'b0) && (framing_error === 1'b0)) begin
      $display("Test 1 passed");
    end else begin
      $display("Test 1 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 2: Idle line high should not trigger reception
    // -------------------------
    rx = 1'b1;
    for (i = 0; i < 4; i = i + 1)
      pulse_oversample_tick;

    if ((shift === 1'b0) && (rx_valid === 1'b0) && (framing_error === 1'b0)) begin
      $display("Test 2 passed");
    end else begin
      $display("Test 2 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 3: Start bit low begins receive activity
    // -------------------------
    rx = 1'b0;
    pulse_oversample_tick;
    @(posedge clk);

    if ((rx_valid === 1'b0) && (framing_error === 1'b0)) begin
      $display("Test 3 passed");
    end else begin
      $display("Test 3 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 4: sample_now during data reception causes shift
    // -------------------------
    bit_count = 3'b000;
    pulse_sample_now;

    if (shift === 1'b1 || shift === 1'b0) begin
      // shift may be a pulse that is not held long enough to observe here,
      // so we do a stricter check below with direct timing.
      sample_now = 1'b1;
      @(posedge clk);
      if (shift === 1'b1) begin
        $display("Test 4 passed");
      end else begin
        $display("Test 4 failed");
        failures = failures + 1;
      end
      sample_now = 1'b0;
      @(posedge clk);
    end else begin
      $display("Test 4 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 5: Full byte reception with valid stop bit sets rx_valid
    // -------------------------
    rst = 1'b1;
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;
    @(posedge clk);

    rx = 1'b0;  // start bit
    pulse_oversample_tick;

    for (i = 0; i < 8; i = i + 1) begin
      bit_count = i[2:0];
      sample_now = 1'b1;
      @(posedge clk);
      sample_now = 1'b0;
      @(posedge clk);
    end

    rx = 1'b1;  // valid stop bit
    pulse_oversample_tick;
    sample_now = 1'b1;
    @(posedge clk);
    sample_now = 1'b0;
    @(posedge clk);

    if ((rx_valid === 1'b1) && (framing_error === 1'b0)) begin
      $display("Test 5 passed");
    end else begin
      $display("Test 5 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 6: Invalid stop bit sets framing_error
    // -------------------------
    rst = 1'b1;
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;
    @(posedge clk);

    rx = 1'b0;  // start bit
    pulse_oversample_tick;

    for (i = 0; i < 8; i = i + 1) begin
      bit_count = i[2:0];
      sample_now = 1'b1;
      @(posedge clk);
      sample_now = 1'b0;
      @(posedge clk);
    end

    rx = 1'b0;  // invalid stop bit
    pulse_oversample_tick;
    sample_now = 1'b1;
    @(posedge clk);
    sample_now = 1'b0;
    @(posedge clk);

    if (framing_error === 1'b1) begin
      $display("Test 6 passed");
    end else begin
      $display("Test 6 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 7: Reset clears rx_valid and framing_error
    // -------------------------
    rst = 1'b1;
    @(posedge clk);
    @(posedge clk);

    if ((rx_valid === 1'b0) && (framing_error === 1'b0)) begin
      $display("Test 7 passed");
    end else begin
      $display("Test 7 failed");
      failures = failures + 1;
    end

    rst = 1'b0;
    @(posedge clk);

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