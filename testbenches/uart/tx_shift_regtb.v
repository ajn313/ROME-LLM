`timescale 1ns / 1ps

module tx_shift_regtb;

  reg clk;
  reg rst;
  reg load;
  reg shift;
  reg [7:0] tx_data;
  wire tx_bit;

  integer failures;

  tx_shift_reg dut (
    .clk(clk),
    .rst(rst),
    .load(load),
    .shift(shift),
    .tx_data(tx_data),
    .tx_bit(tx_bit)
  );

  // 25 MHz style clock
  initial begin
    clk = 1'b0;
    forever #20 clk = ~clk;
  end

  initial begin
    failures = 0;
    rst = 1'b1;
    load = 1'b0;
    shift = 1'b0;
    tx_data = 8'h00;

    // -------------------------
    // Test 1: Reset behavior
    // -------------------------
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;
    @(posedge clk);

    if (tx_bit === 1'b1) begin
      $display("Test 1 passed");
    end else begin
      $display("Test 1 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 2: Load 8'hA5, check first output bit (LSB)
    // 8'hA5 = 1010_0101, LSB = 1
    // -------------------------
    tx_data = 8'hA5;
    load = 1'b1;
    shift = 1'b0;
    @(posedge clk);
    load = 1'b0;
    @(posedge clk);

    if (tx_bit === 1'b1) begin
      $display("Test 2 passed");
    end else begin
      $display("Test 2 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 3: Shift once, next bit of 8'hA5 should be bit[1] = 0
    // -------------------------
    shift = 1'b1;
    @(posedge clk);
    shift = 1'b0;
    @(posedge clk);

    if (tx_bit === 1'b0) begin
      $display("Test 3 passed");
    end else begin
      $display("Test 3 failed");
      failures = failures + 1;
    end

    // -------------------------
    // Test 4: Shift through all bits of 8'hA5
    // Sequence LSB-first: 1,0,1,0,0,1,0,1
    // We already checked first two bits, now check remaining
    // -------------------------
    shift = 1'b1; @(posedge clk); shift = 1'b0; @(posedge clk); // bit[2] = 1
    if (tx_bit !== 1'b1) failures = failures + 1;

    shift = 1'b1; @(posedge clk); shift = 1'b0; @(posedge clk); // bit[3] = 0
    if (tx_bit !== 1'b0) failures = failures + 1;

    shift = 1'b1; @(posedge clk); shift = 1'b0; @(posedge clk); // bit[4] = 0
    if (tx_bit !== 1'b0) failures = failures + 1;

    shift = 1'b1; @(posedge clk); shift = 1'b0; @(posedge clk); // bit[5] = 1
    if (tx_bit !== 1'b1) failures = failures + 1;

    shift = 1'b1; @(posedge clk); shift = 1'b0; @(posedge clk); // bit[6] = 0
    if (tx_bit !== 1'b0) failures = failures + 1;

    shift = 1'b1; @(posedge clk); shift = 1'b0; @(posedge clk); // bit[7] = 1
    if (tx_bit !== 1'b1) failures = failures + 1;

    if (failures == 0 || failures == 1 || failures == 2) begin
      // This conditional is not used for correctness, just prevents double-counting logic confusion
    end

    // Re-run Test 4 cleanly with explicit pass/fail accounting
    rst = 1'b1;
    load = 1'b0;
    shift = 1'b0;
    tx_data = 8'h00;
    @(posedge clk);
    rst = 1'b0;
    @(posedge clk);

    tx_data = 8'hA5;
    load = 1'b1;
    @(posedge clk);
    load = 1'b0;
    @(posedge clk);

    if (tx_bit !== 1'b1) begin
      $display("Test 4 failed");
      failures = failures + 1;
    end else begin
      shift = 1'b1; @(posedge clk); shift = 1'b0; @(posedge clk);
      if (tx_bit !== 1'b0) begin
        $display("Test 4 failed");
        failures = failures + 1;
      end else begin
        shift = 1'b1; @(posedge clk); shift = 1'b0; @(posedge clk);
        if (tx_bit !== 1'b1) begin
          $display("Test 4 failed");
          failures = failures + 1;
        end else begin
          shift = 1'b1; @(posedge clk); shift = 1'b0; @(posedge clk);
          if (tx_bit !== 1'b0) begin
            $display("Test 4 failed");
            failures = failures + 1;
          end else begin
            shift = 1'b1; @(posedge clk); shift = 1'b0; @(posedge clk);
            if (tx_bit !== 1'b0) begin
              $display("Test 4 failed");
              failures = failures + 1;
            end else begin
              shift = 1'b1; @(posedge clk); shift = 1'b0; @(posedge clk);
              if (tx_bit !== 1'b1) begin
                $display("Test 4 failed");
                failures = failures + 1;
              end else begin
                shift = 1'b1; @(posedge clk); shift = 1'b0; @(posedge clk);
                if (tx_bit !== 1'b0) begin
                  $display("Test 4 failed");
                  failures = failures + 1;
                end else begin
                  shift = 1'b1; @(posedge clk); shift = 1'b0; @(posedge clk);
                  if (tx_bit !== 1'b1) begin
                    $display("Test 4 failed");
                    failures = failures + 1;
                  end else begin
                    $display("Test 4 passed");
                  end
                end
              end
            end
          end
        end
      end
    end

    // -------------------------
    // Test 5: Load new value 8'h3C and verify first bit
    // 8'h3C = 0011_1100, LSB = 0
    // -------------------------
    tx_data = 8'h3C;
    load = 1'b1;
    shift = 1'b0;
    @(posedge clk);
    load = 1'b0;
    @(posedge clk);

    if (tx_bit === 1'b0) begin
      $display("Test 5 passed");
    end else begin
      $display("Test 5 failed");
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