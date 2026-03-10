//======================================================================
// aes_decipher_block_tb.v  (Verilog-2001 only)
// Testbench for AES-128 decipher block (clocked)
//
// Assumed DUT interface:
//   module aes_decipher_block(
//       input  wire         clk,
//       input  wire         reset_n,
//       input  wire         init,
//       input  wire         next,
//       input  wire [127:0] key,
//       input  wire [127:0] block,        // ciphertext input
//       output wire [127:0] result,       // plaintext output
//       output wire         result_valid,
//       output wire         ready
//   );
//
// Includes timeout waits to avoid hanging simulations.
// Uses known AES-128 KATs (ciphertext -> plaintext).
//======================================================================

`timescale 1ns/1ps

module aes_decipher_block_tb;

  // -------------------------------------------------------------------
  // Clock / reset
  // -------------------------------------------------------------------
  reg clk;
  reg reset_n;

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // -------------------------------------------------------------------
  // DUT signals
  // -------------------------------------------------------------------
  reg         init;
  reg         next;
  reg [127:0] key;
  reg [127:0] block;  // ciphertext in

  wire [127:0] result;       // plaintext out
  wire         result_valid;
  wire         ready;

  // -------------------------------------------------------------------
  // Instantiate DUT
  // -------------------------------------------------------------------
  aes_decipher_block dut (
    .clk          (clk),
    .reset_n      (reset_n),
    .init         (init),
    .next         (next),
    .key          (key),
    .block        (block),
    .result       (result),
    .result_valid (result_valid),
    .ready        (ready)
  );

  integer test_num;
  integer any_fail;

  // Wait for ready with timeout
  task wait_ready;
    integer cycles;
    begin
      cycles = 0;
      while (ready !== 1'b1) begin
        @(posedge clk);
        cycles = cycles + 1;
        if (cycles > 400) begin
          $display("ERROR: Timeout waiting for ready");
          any_fail = 1;
          disable wait_ready;
        end
      end
    end
  endtask

  // Wait for result_valid with timeout
  task wait_result_valid;
    integer cycles;
    begin
      cycles = 0;
      while (result_valid !== 1'b1) begin
        @(posedge clk);
        cycles = cycles + 1;
        if (cycles > 800) begin
          $display("ERROR: Timeout waiting for result_valid");
          any_fail = 1;
          disable wait_result_valid;
        end
      end
    end
  endtask

  task run_kat_test;
    input [127:0] in_key;
    input [127:0] in_ct;
    input [127:0] exp_pt;
    begin
      test_num = test_num + 1;

      key   = in_key;
      block = in_ct;

      // Start key schedule / init
      init = 1'b1;
      @(posedge clk);
      init = 1'b0;

      // Wait until core is ready
      wait_ready;

      // Trigger decryption
      next = 1'b1;
      @(posedge clk);
      next = 1'b0;

      // Wait for result_valid
      wait_result_valid;
      #1;

      if (result === exp_pt) begin
        $display("Test %0d passed", test_num);
      end else begin
        $display("Test %0d failed", test_num);
        $display("  key =0x%032x", in_key);
        $display("  ct  =0x%032x", in_ct);
        $display("  exp =0x%032x", exp_pt);
        $display("  got =0x%032x", result);
        any_fail = 1;
      end

      // Advance a couple cycles
      repeat (2) @(posedge clk);
    end
  endtask

  initial begin
    // init
    reset_n  = 0;
    init     = 0;
    next     = 0;
    key      = 128'h0;
    block    = 128'h0;
    test_num = 0;
    any_fail = 0;

    // reset
    repeat (3) @(posedge clk);
    reset_n = 1;
    @(posedge clk);

    // ---------------------------------------------------------------
    // Test 1: Classic AES-128 KAT (ct -> pt)
    // key = 00010203...0f
    // pt  = 00112233...ff
    // ct  = 69c4e0d8...c55a
    // ---------------------------------------------------------------
    run_kat_test(
      128'h00010203_04050607_08090a0b_0c0d0e0f,
      128'h69c4e0d8_6a7b0430_d8cdb780_70b4c55a,
      128'h00112233_44556677_8899aabb_ccddeeff
    );

    // ---------------------------------------------------------------
    // Test 2: NIST SP 800-38A example (ct -> pt)
    // key: 2b7e1516...4f3c
    // pt : 6bc1bee2...172a
    // ct : 3ad77bb4...ef97
    // ---------------------------------------------------------------
    run_kat_test(
      128'h2b7e1516_28aed2a6_abf71588_09cf4f3c,
      128'h3ad77bb4_0d7a3660_a89ecaf3_2466ef97,
      128'h6bc1bee2_2e409f96_e93d7e11_7393172a
    );

    // Summary
    if (any_fail == 0)
      $display("All tests passed!");
    else
      $display("Some tests failed");

    $finish;
  end

endmodule