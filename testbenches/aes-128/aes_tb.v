//======================================================================
// aes_tb.v  (Verilog-2001 only)
// Testbench for top-level AES (enc+dec)
//
// Assumed DUT interface:
//   module aes(
//       input  wire         clk,
//       input  wire         reset_n,
//       input  wire         init,
//       input  wire         next,
//       input  wire         encdec,      // 1=enc, 0=dec
//       input  wire [127:0] key,
//       input  wire [127:0] block,
//       output wire [127:0] result,
//       output wire         result_valid,
//       output wire         ready
//   );
//
// Runs known-answer tests for both encryption and decryption.
// Includes timeouts to avoid hanging simulations.
//======================================================================

`timescale 1ns/1ps

module aes_tb;

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
  reg         encdec;
  reg [127:0] key;
  reg [127:0] block;

  wire [127:0] result;
  wire         result_valid;
  wire         ready;

  // -------------------------------------------------------------------
  // Instantiate DUT
  // -------------------------------------------------------------------
  aes dut (
    .clk          (clk),
    .reset_n      (reset_n),
    .init         (init),
    .next         (next),
    .encdec       (encdec),
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
        if (cycles > 600) begin
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
        if (cycles > 1200) begin
          $display("ERROR: Timeout waiting for result_valid");
          any_fail = 1;
          disable wait_result_valid;
        end
      end
    end
  endtask

  // Run one operation (enc or dec) with init/next handshake
  task run_op_test;
    input        mode_enc;   // 1=enc, 0=dec
    input [127:0] in_key;
    input [127:0] in_block;
    input [127:0] exp_result;
    reg   [127:0] got;
    begin
      test_num = test_num + 1;

      encdec = mode_enc;
      key    = in_key;
      block  = in_block;

      // Init (key expansion/load)
      init = 1'b1;
      @(posedge clk);
      init = 1'b0;

      // Wait ready
      wait_ready;

      // Start operation
      next = 1'b1;
      @(posedge clk);
      next = 1'b0;

      // Wait result_valid
      wait_result_valid;
      #1;
      got = result;

      if (got === exp_result) begin
        $display("Test %0d passed", test_num);
      end else begin
        $display("Test %0d failed", test_num);
        $display("  mode     = %s", (mode_enc ? "ENC" : "DEC"));
        $display("  key      = 0x%032x", in_key);
        $display("  block_in = 0x%032x", in_block);
        $display("  exp      = 0x%032x", exp_result);
        $display("  got      = 0x%032x", got);
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
    encdec   = 1'b1;
    key      = 128'h0;
    block    = 128'h0;
    test_num = 0;
    any_fail = 0;

    // reset
    repeat (3) @(posedge clk);
    reset_n = 1;
    @(posedge clk);

    // ---------------------------------------------------------------
    // Vector 1 (FIPS-197 classic)
    // key: 00010203..0f
    // pt : 00112233..ff
    // ct : 69c4e0d8..c55a
    // ---------------------------------------------------------------
    run_op_test(
      1'b1,
      128'h00010203_04050607_08090a0b_0c0d0e0f,
      128'h00112233_44556677_8899aabb_ccddeeff,
      128'h69c4e0d8_6a7b0430_d8cdb780_70b4c55a
    );

    run_op_test(
      1'b0,
      128'h00010203_04050607_08090a0b_0c0d0e0f,
      128'h69c4e0d8_6a7b0430_d8cdb780_70b4c55a,
      128'h00112233_44556677_8899aabb_ccddeeff
    );

    // ---------------------------------------------------------------
    // Vector 2 (SP 800-38A example)
    // key: 2b7e1516..4f3c
    // pt : 6bc1bee2..172a
    // ct : 3ad77bb4..ef97
    // ---------------------------------------------------------------
    run_op_test(
      1'b1,
      128'h2b7e1516_28aed2a6_abf71588_09cf4f3c,
      128'h6bc1bee2_2e409f96_e93d7e11_7393172a,
      128'h3ad77bb4_0d7a3660_a89ecaf3_2466ef97
    );

    run_op_test(
      1'b0,
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