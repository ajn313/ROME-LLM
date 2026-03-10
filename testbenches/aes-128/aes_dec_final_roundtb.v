//======================================================================
// aes_dec_final_round_tb.v  (Verilog-2001 only)
// Testbench for AES decryption FINAL round:
//   state_out = AddRoundKey( InvSubBytes( InvShiftRows(state_in) ), round_key )
//
// Assumed DUT interface:
//   module aes_dec_final_round(
//       input  wire [127:0] state_in,
//       input  wire [127:0] round_key,
//       output wire [127:0] state_out
//   );
//
// Golden reference is composed of:
//   aes_inv_shift_rows -> aes_inv_sub_bytes -> aes_add_round_key
//======================================================================

`timescale 1ns/1ps

module aes_dec_final_round_tb;

  // Inputs
  reg  [127:0] state_in;
  reg  [127:0] round_key;

  // DUT output
  wire [127:0] dut_out;

  // Reference path wires
  wire [127:0] ref_isr_out;
  wire [127:0] ref_isb_out;
  wire [127:0] ref_out;

  // DUT instantiation
  aes_dec_final_round dut (
    .state_in  (state_in),
    .round_key (round_key),
    .state_out (dut_out)
  );

  // Golden reference: InvShiftRows -> InvSubBytes -> AddRoundKey
  aes_inv_shift_rows u_ref_inv_shift_rows (
    .state_in  (state_in),
    .state_out (ref_isr_out)
  );

  aes_inv_sub_bytes u_ref_inv_sub_bytes (
    .state_in  (ref_isr_out),
    .state_out (ref_isb_out)
  );

  aes_add_round_key u_ref_add_round_key (
    .state_in  (ref_isb_out),
    .round_key (round_key),
    .state_out (ref_out)
  );

  integer test_num;
  integer any_fail;

  task run_test;
    input [127:0] s;
    input [127:0] k;
    begin
      test_num = test_num + 1;

      state_in  = s;
      round_key = k;
      #2;

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

    // Test 4: mixed state + mixed key
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