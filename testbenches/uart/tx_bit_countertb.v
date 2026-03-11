`timescale 1ns / 1ps

module tx_bit_countertb;

  reg clk;
  reg rst;
  reg shift;
  wire [2:0] bit_count;
  wire done;

  integer failures;

  tx_bit_counter dut (
    .clk(clk),
    .rst(rst),
    .shift(shift),
    .bit_count(bit_count),
    .done(done)
  );

  // Clock generation
  initial begin
    clk = 1'b0;
    forever #20 clk = ~clk;
  end

  initial begin
    failures = 0;
    rst = 1'b1;
    shift = 1'b0;

    // -------------------------
    // Test 1: Reset behavior
    // -------------------------
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;
    @(posedge clk);

    if ((bit_count === 3'b000) && (done === 1'b0)) begin
      $display("Test 1 passed");
    end else begin
      $display("Test 1 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 2: First shift increments counter to 1
    // -------------------------
    shift = 1'b1;
    @(posedge clk);
    shift = 1'b0;
    @(posedge clk);

    if ((bit_count === 3'b001) && (done === 1'b0)) begin
      $display("Test 2 passed");
    end else begin
      $display("Test 2 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 3: Counter reaches 4 after four total shifts
    // -------------------------
    shift = 1'b1; @(posedge clk); shift = 1'b0; @(posedge clk); // 2
    shift = 1'b1; @(posedge clk); shift = 1'b0; @(posedge clk); // 3
    shift = 1'b1; @(posedge clk); shift = 1'b0; @(posedge clk); // 4

    if ((bit_count === 3'b100) && (done === 1'b0)) begin
      $display("Test 3 passed");
    end else begin
      $display("Test 3 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 4: Counter reaches 7 after seven total shifts
    // -------------------------
    shift = 1'b1; @(posedge clk); shift = 1'b0; @(posedge clk); // 5
    shift = 1'b1; @(posedge clk); shift = 1'b0; @(posedge clk); // 6
    shift = 1'b1; @(posedge clk); shift = 1'b0; @(posedge clk); // 7

    if ((bit_count === 3'b111) && (done === 1'b0)) begin
      $display("Test 4 passed");
    end else begin
      $display("Test 4 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 5: Eighth shift asserts done
    // Since bit_count is 3 bits, many designs wrap to 0 here.
    // We only require done to assert.
    // -------------------------
    shift = 1'b1;
    @(posedge clk);
    shift = 1'b0;
    @(posedge clk);

    if (done === 1'b1) begin
      $display("Test 5 passed");
    end else begin
      $display("Test 5 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 6: Reset clears counter and done
    // -------------------------
    rst = 1'b1;
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;
    @(posedge clk);

    if ((bit_count === 3'b000) && (done === 1'b0)) begin
      $display("Test 6 passed");
    end else begin
      $display("Test 6 failed");
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