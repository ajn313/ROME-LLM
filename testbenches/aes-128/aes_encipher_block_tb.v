//======================================================================
// aes_encipher_block_tb.v  (Verilog-2001 only)
// Testbench for AES-128 encipher block (clocked)
//
// Assumed DUT interface:
//   module aes_encipher_block(
//       input  wire         clk,
//       input  wire         reset_n,
//       input  wire         init,
//       input  wire         next,
//       input  wire [127:0] key,
//       input  wire [127:0] block,
//       output wire [127:0] result,
//       output wire         result_valid,
//       output wire         ready
//   );
//
// Includes timeout waits to avoid hanging simulations.
// Uses the classic FIPS-197 AES-128 KAT:
//   key   = 000102030405060708090a0b0c0d0e0f
//   pt    = 00112233445566778899aabbccddeeff
//   ct    = 69c4e0d86a7b0430d8cdb78070b4c55a
//======================================================================

`timescale 1ns/1ps

module aes_encipher_block_tb;

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
  reg [127:0] block;

  wire [127:0] result;
  wire         result_valid;
  wire         ready;

  // -------------------------------------------------------------------
  // Instantiate DUT
  // -------------------------------------------------------------------
  aes_encipher_block dut (
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
    input [127:0] in_pt;
    input [127:0] exp_ct;
    begin
      test_num = test_num + 1;

      // Apply key/block and perform init/next handshake
      key   = in_key;
      block = in_pt;

      // Start key schedule / init
      init = 1'b1;
      @(posedge clk);
      init = 1'b0;

      // Wait until core is ready (key expanded etc.)
      wait_ready;

      // Trigger encryption
      next = 1'b1;
      @(posedge clk);
      next = 1'b0;

      // Wait for result_valid
      wait_result_valid;
      #1;

      if (result === exp_ct) begin
        $display("Test %0d passed", test_num);
      end else begin
        $display("Test %0d failed", test_num);
        $display("  key =0x%032x", in_key);
        $display("  pt  =0x%032x", in_pt);
        $display("  exp =0x%032x", exp_ct);
        $display("  got =0x%032x", result);
        any_fail = 1;
      end

      // Let result_valid drop (if it is a pulse). Avoid assuming behavior;
      // just advance a couple cycles.
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
    // Test 1: Classic AES-128 KAT
    // ---------------------------------------------------------------
    run_kat_test(
      128'h00010203_04050607_08090a0b_0c0d0e0f,
      128'h00112233_44556677_8899aabb_ccddeeff,
      128'h69c4e0d8_6a7b0430_d8cdb780_70b4c55a
    );

    // ---------------------------------------------------------------
    // Test 2: Another common KAT (NIST SP 800-38A example)
    // key: 2b7e1516 28aed2a6 abf71588 09cf4f3c
    // pt : 6bc1bee2 2e409f96 e93d7e11 7393172a
    // ct : 3ad77bb4 0d7a3660 a89ecaf3 2466ef97
    // ---------------------------------------------------------------
    run_kat_test(
      128'h2b7e1516_28aed2a6_abf71588_09cf4f3c,
      128'h6bc1bee2_2e409f96_e93d7e11_7393172a,
      128'h3ad77bb4_0d7a3660_a89ecaf3_2466ef97
    );

    // Summary
    if (any_fail == 0)
      $display("All tests passed!");
    else
      $display("Some tests failed");

    $finish;
  end

endmodule