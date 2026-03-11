`timescale 1ns / 1ps

module rx_samplertb;

  reg clk;
  reg rst;
  reg oversample_tick;
  reg rx;
  wire sample_now;
  wire rx_sampled;

  integer failures;
  integer i;
  integer saw_sample;

  rx_sampler dut (
    .clk(clk),
    .rst(rst),
    .oversample_tick(oversample_tick),
    .rx(rx),
    .sample_now(sample_now),
    .rx_sampled(rx_sampled)
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

  initial begin
    failures = 0;
    rst = 1'b1;
    oversample_tick = 1'b0;
    rx = 1'b1;
    saw_sample = 0;

    // -------------------------
    // Test 1: Reset / idle behavior
    // -------------------------
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;
    @(posedge clk);

    if (sample_now === 1'b0) begin
      $display("Test 1 passed");
    end else begin
      $display("Test 1 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 2: No sampling while line stays idle high
    // -------------------------
    saw_sample = 0;
    rx = 1'b1;
    for (i = 0; i < 10; i = i + 1) begin
      pulse_oversample_tick;
      if (sample_now === 1'b1)
        saw_sample = 1;
    end

    if (saw_sample == 0) begin
      $display("Test 2 passed");
    end else begin
      $display("Test 2 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 3: Start-bit low eventually causes sample_now pulse
    // -------------------------
    saw_sample = 0;
    rx = 1'b0;

    for (i = 0; i < 20; i = i + 1) begin
      pulse_oversample_tick;
      if (sample_now === 1'b1)
        saw_sample = 1;
    end

    if (saw_sample == 1) begin
      $display("Test 3 passed");
    end else begin
      $display("Test 3 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 4: Sampled low value is captured correctly
    // Hold rx low and wait for a fresh sample pulse
    // -------------------------
    rst = 1'b1;
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;
    @(posedge clk);

    rx = 1'b0;
    saw_sample = 0;

    for (i = 0; i < 20; i = i + 1) begin
      pulse_oversample_tick;
      if ((sample_now === 1'b1) && (saw_sample == 0)) begin
        saw_sample = 1;
        if (rx_sampled === 1'b0) begin
          $display("Test 4 passed");
        end else begin
          $display("Test 4 failed");
          failures = failures + 1;
        end
      end
    end

    if (saw_sample == 0) begin
      $display("Test 4 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 5: Sampled high value is captured correctly
    // -------------------------
    rst = 1'b1;
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;
    @(posedge clk);

    rx = 1'b0;
    saw_sample = 0;

    // First force the sampler into active timing by presenting low
    for (i = 0; i < 8; i = i + 1)
      pulse_oversample_tick;

    // Now drive high and wait for a sample pulse
    rx = 1'b1;

    for (i = 0; i < 20; i = i + 1) begin
      pulse_oversample_tick;
      if ((sample_now === 1'b1) && (saw_sample == 0)) begin
        saw_sample = 1;
        if (rx_sampled === 1'b1) begin
          $display("Test 5 passed");
        end else begin
          $display("Test 5 failed");
          failures = failures + 1;
        end
      end
    end

    if (saw_sample == 0) begin
      $display("Test 5 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 6: Reset clears sampler activity
    // -------------------------
    rst = 1'b1;
    @(posedge clk);
    @(posedge clk);
    if (sample_now === 1'b0) begin
      $display("Test 6 passed");
    end else begin
      $display("Test 6 failed");
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