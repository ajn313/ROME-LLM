`timescale 1ns / 1ps

module rx_shift_regtb;

  reg clk;
  reg rst;
  reg shift;
  reg rx_sampled;
  wire [7:0] rx_data;

  integer failures;

  rx_shift_reg dut (
    .clk(clk),
    .rst(rst),
    .shift(shift),
    .rx_sampled(rx_sampled),
    .rx_data(rx_data)
  );

  // Clock generation
  initial begin
    clk = 1'b0;
    forever #20 clk = ~clk;
  end

  task shift_in_bit;
    input bit_value;
    begin
      rx_sampled = bit_value;
      shift = 1'b1;
      @(posedge clk);
      shift = 1'b0;
      @(posedge clk);
    end
  endtask

  initial begin
    failures = 0;
    rst = 1'b1;
    shift = 1'b0;
    rx_sampled = 1'b0;

    // -------------------------
    // Test 1: Reset clears register
    // -------------------------
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;
    @(posedge clk);

    if (rx_data === 8'h00) begin
      $display("Test 1 passed");
    end else begin
      $display("Test 1 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 2: Shift in first bit = 1
    // Expect rx_data[0] = 1 for an LSB-first receiver
    // -------------------------
    shift_in_bit(1'b1);

    if (rx_data === 8'h01) begin
      $display("Test 2 passed");
    end else begin
      $display("Test 2 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 3: Shift in second bit = 0
    // Byte should still be 8'h01
    // -------------------------
    shift_in_bit(1'b0);

    if (rx_data === 8'h01) begin
      $display("Test 3 passed");
    end else begin
      $display("Test 3 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 4: Shift in full 8'hA5 sequence LSB-first
    // Sequence: 1,0,1,0,0,1,0,1
    // -------------------------
    rst = 1'b1;
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;
    @(posedge clk);

    shift_in_bit(1'b1); // bit 0
    shift_in_bit(1'b0); // bit 1
    shift_in_bit(1'b1); // bit 2
    shift_in_bit(1'b0); // bit 3
    shift_in_bit(1'b0); // bit 4
    shift_in_bit(1'b1); // bit 5
    shift_in_bit(1'b0); // bit 6
    shift_in_bit(1'b1); // bit 7

    if (rx_data === 8'hA5) begin
      $display("Test 4 passed");
    end else begin
      $display("Test 4 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 5: Shift in full 8'h3C sequence LSB-first
    // 8'h3C = 0011_1100
    // LSB-first sequence: 0,0,1,1,1,1,0,0
    // -------------------------
    rst = 1'b1;
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;
    @(posedge clk);

    shift_in_bit(1'b0); // bit 0
    shift_in_bit(1'b0); // bit 1
    shift_in_bit(1'b1); // bit 2
    shift_in_bit(1'b1); // bit 3
    shift_in_bit(1'b1); // bit 4
    shift_in_bit(1'b1); // bit 5
    shift_in_bit(1'b0); // bit 6
    shift_in_bit(1'b0); // bit 7

    if (rx_data === 8'h3C) begin
      $display("Test 5 passed");
    end else begin
      $display("Test 5 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 6: Reset clears register after loading data
    // -------------------------
    rst = 1'b1;
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;
    @(posedge clk);

    if (rx_data === 8'h00) begin
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