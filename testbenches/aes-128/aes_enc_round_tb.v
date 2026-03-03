//======================================================================
// aes_enc_round_tb.v  (Verilog-2001 only)
// Testbench for AES encryption round:
//   state_out = AddRoundKey( MixColumns( ShiftRows( SubBytes(state_in) ) ), round_key )
//
// Assumed DUT interface:
//   module aes_enc_round(
//       input  wire [127:0] state_in,
//       input  wire [127:0] round_key,
//       output wire [127:0] state_out
//   );
//
// This TB uses an internal "golden" reference datapath composed of:
//   aes_sub_bytes, aes_shift_rows, aes_mix_columns, aes_add_round_key
// and compares DUT output against it.
//
// NOTE: Module port names must match your RTL. If your ports differ,
// rename connections accordingly (still Verilog-2001).
//======================================================================

`timescale 1ns/1ps

module aes_enc_round_tb;

  // -------------------------------------------------------------------
  // Inputs to both DUT and reference
  // -------------------------------------------------------------------
  reg  [127:0] state_in;
  reg  [127:0] round_key;

  // DUT output
  wire [127:0] dut_out;

  // Reference internal wires
  wire [127:0] ref_sb_out;
  wire [127:0] ref_sr_out;
  wire [127:0] ref_mc_out;
  wire [127:0] ref_out;

  // -------------------------------------------------------------------
  // Instantiate DUT
  // -------------------------------------------------------------------
  aes_enc_round dut (
    .state_in  (state_in),
    .round_key (round_key),
    .state_out (dut_out)
  );

  // -------------------------------------------------------------------
  // Golden reference: SubBytes -> ShiftRows -> MixColumns -> AddRoundKey
  // -------------------------------------------------------------------
  aes_sub_bytes u_ref_sub_bytes (
    .state_in  (state_in),
    .state_out (ref_sb_out)
  );

  aes_shift_rows u_ref_shift_rows (
    .state_in  (ref_sb_out),
    .state_out (ref_sr_out)
  );

  aes_mix_columns u_ref_mix_columns (
    .state_in  (ref_sr_out),
    .state_out (ref_mc_out)
  );

  aes_add_round_key u_ref_add_round_key (
    .state_in  (ref_mc_out),
    .round_key (round_key),
    .state_out (ref_out)
  );

  // -------------------------------------------------------------------
  // Test bookkeeping
  // -------------------------------------------------------------------
  integer test_num;
  integer any_fail;

  task run_test;
    input [127:0] s;
    input [127:0] k;
    begin
      test_num = test_num + 1;

      state_in  = s;
      round_key = k;
      #2; // allow combinational settle through multiple stages

      if (dut_out === ref_out) begin
        $display("Test %0d passed", test_num);
      end else begin
        $display("Test %0d failed", test_num);
        $display("  state_in =0x%032x", s);
        $display("  round_key=0x%032x", k);
        $display("  ref_out  =0x%032x", ref_out);
        $display("  dut_out  =0x%032x", dut_out);
        any_fail = 1;
      end
    end
  endtask

  // -------------------------------------------------------------------
  // Main
  // -------------------------------------------------------------------
  initial begin
    state_in  = 128'h0;
    round_key = 128'h0;
    test_num  = 0;
    any_fail  = 0;

    // Test 1: all zeros
    run_test(
      128'h00000000_00000000_00000000_00000000,
      128'h00000000_00000000_00000000_00000000
    );

    // Test 2: byte ramp state, zero key
    run_test(
      128'h00010203_04050607_08090a0b_0c0d0e0f,
      128'h00000000_00000000_00000000_00000000
    );

    // Test 3: zero state, patterned key
    run_test(
      128'h00000000_00000000_00000000_00000000,
      128'h0f0e0d0c_0b0a0908_07060504_03020100
    );

    // Test 4: mixed state + mixed key (wiring/byte order stress)
    run_test(
      128'h00112233_44556677_8899aabb_ccddeeff,
      128'h00010203_04050607_08090a0b_0c0d0e0f
    );

    // Test 5: another mixed pattern
    run_test(
      128'hffeeddcc_bbaa9988_77665544_33221100,
      128'hdeadbeef_cafebabe_01234567_89abcdef
    );

    // Summary
    if (any_fail == 0)
      $display("All tests passed!");
    else
      $display("Some tests failed");

    $finish;
  end

endmodule