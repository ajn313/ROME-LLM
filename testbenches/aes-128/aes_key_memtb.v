//======================================================================
// aes_key_mem_tb.v  (Verilog-2001 only)
// Testbench for AES-128 key memory / key expansion storage
//
// Assumed DUT interface:
//   module aes_key_mem(
//       input  wire         clk,
//       input  wire         reset_n,
//       input  wire         init,
//       input  wire [127:0] key,
//       input  wire [3:0]   round,
//       output wire [127:0] round_key,
//       output wire         ready
//   );
//
// Tests the FIPS-197 AES-128 key schedule for rounds 0..10.
// Includes a timeout-based wait for ready to avoid hanging simulations.
//======================================================================

`timescale 1ns/1ps

module aes_key_mem_tb;

  // -------------------------------------------------------------------
  // Clock / reset
  // -------------------------------------------------------------------
  reg clk;
  reg reset_n;

  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100MHz
  end

  // -------------------------------------------------------------------
  // DUT signals
  // -------------------------------------------------------------------
  reg         init;
  reg [127:0] key;
  reg [3:0]   round;
  wire [127:0] round_key;
  wire        ready;

  // -------------------------------------------------------------------
  // Instantiate DUT
  // -------------------------------------------------------------------
  aes_key_mem dut (
    .clk       (clk),
    .reset_n   (reset_n),
    .init      (init),
    .key       (key),
    .round     (round),
    .round_key (round_key),
    .ready     (ready)
  );

  // -------------------------------------------------------------------
  // Test bookkeeping
  // -------------------------------------------------------------------
  integer test_num;
  integer any_fail;

  // -------------------------------------------------------------------
  // Utility: wait for ready with timeout (prevents hang)
  // -------------------------------------------------------------------
  task wait_ready;
    integer cycles;
    begin
      cycles = 0;
      while (ready !== 1'b1) begin
        @(posedge clk);
        cycles = cycles + 1;
        if (cycles > 200) begin
          $display("ERROR: Timeout waiting for ready");
          any_fail = 1;
          disable wait_ready;
        end
      end
    end
  endtask

  // -------------------------------------------------------------------
  // Check one round key
  // Notes:
  // - Many designs present round_key combinationally from internal memory
  //   once ready is high. We sample it 1 cycle after setting round.
  // -------------------------------------------------------------------
  task check_round_key;
    input [3:0]   r;
    input [127:0] exp;
    reg   [127:0] got;
    begin
      test_num = test_num + 1;

      round = r;
      @(posedge clk);
      #1; // small settle time after the clock edge
      got = round_key;

      if (got === exp) begin
        $display("Test %0d passed", test_num);
      end else begin
        $display("Test %0d failed", test_num);
        $display("  round   = %0d", r);
        $display("  exp     = 0x%032x", exp);
        $display("  got     = 0x%032x", got);
        any_fail = 1;
      end
    end
  endtask

  // -------------------------------------------------------------------
  // Main
  // -------------------------------------------------------------------
  initial begin
    // init
    reset_n  = 0;
    init     = 0;
    key      = 128'h0;
    round    = 4'h0;
    test_num = 0;
    any_fail = 0;

    // reset sequence
    repeat (3) @(posedge clk);
    reset_n = 1;
    @(posedge clk);

    // Load/expand the standard AES-128 example key (FIPS-197)
    // Key = 2b7e1516 28aed2a6 abf71588 09cf4f3c
    key  = 128'h2b7e1516_28aed2a6_abf71588_09cf4f3c;

    // Pulse init for 1 cycle
    init = 1;
    @(posedge clk);
    init = 0;

    // Wait for ready (or timeout)
    wait_ready;

    // Check round keys 0..10 (FIPS-197)
    check_round_key(4'd0,  128'h2b7e1516_28aed2a6_abf71588_09cf4f3c);
    check_round_key(4'd1,  128'ha0fafe17_88542cb1_23a33939_2a6c7605);
    check_round_key(4'd2,  128'hf2c295f2_7a96b943_5935807a_7359f67f);
    check_round_key(4'd3,  128'h3d80477d_4716fe3e_1e237e44_6d7a883b);
    check_round_key(4'd4,  128'hef44a541_a8525b7f_b671253b_db0bad00);
    check_round_key(4'd5,  128'hd4d1c6f8_7c839d87_caf2b8bc_11f915bc);
    check_round_key(4'd6,  128'h6d88a37a_110b3efd_dbf98641_ca0093fd);
    check_round_key(4'd7,  128'h4e54f70e_5f5fc9f3_84a64fb2_4ea6dc4f);
    check_round_key(4'd8,  128'head27321_b58dbad2_312bf560_7f8d292f);
    check_round_key(4'd9,  128'hac7766f3_19fadc21_28d12941_575c006e);
    check_round_key(4'd10, 128'hd014f9a8_c9ee2589_e13f0cc8_b6630ca6);

    // Summary
    if (any_fail == 0)
      $display("All tests passed!");
    else
      $display("Some tests failed");

    $finish;
  end

endmodule