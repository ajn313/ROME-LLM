//======================================================================
// aes_inv_shift_rows_tb.v  (Verilog-2001 only)
// Testbench for inverse AES ShiftRows
//
// Assumed DUT interface:
//   module aes_inv_shift_rows(
//       input  wire [127:0] state_in,
//       output wire [127:0] state_out
//   );
//
// Assumed state packing (FIPS-197 column-major):
//   state_in[127:120] = s00, [119:112] = s10, [111:104] = s20, [103:96]  = s30
//   state_in[95:88]   = s01, [87:80]   = s11, [79:72]   = s21, [71:64]   = s31
//   state_in[63:56]   = s02, [55:48]   = s12, [47:40]   = s22, [39:32]   = s32
//   state_in[31:24]   = s03, [23:16]   = s13, [15:8]    = s23, [7:0]     = s33
//
// Inverse ShiftRows:
//   Row0: no shift
//   Row1: shift right by 1
//   Row2: shift right by 2
//   Row3: shift right by 3 (left by 1)
//======================================================================

`timescale 1ns/1ps

module aes_inv_shift_rows_tb;

  // DUT signals
  reg  [127:0] state_in;
  wire [127:0] state_out;

  // Instantiate DUT
  aes_inv_shift_rows dut (
    .state_in (state_in),
    .state_out(state_out)
  );

  integer test_num;
  integer any_fail;

  task run_test;
    input [127:0] in_val;
    input [127:0] exp_val;
    begin
      test_num = test_num + 1;

      state_in = in_val;
      #1;

      if (state_out === exp_val) begin
        $display("Test %0d passed", test_num);
      end else begin
        $display("Test %0d failed", test_num);
        $display("  in =0x%032x", in_val);
        $display("  exp=0x%032x", exp_val);
        $display("  got=0x%032x", state_out);
        any_fail = 1;
      end
    end
  endtask

  initial begin
    state_in  = 128'h0;
    test_num  = 0;
    any_fail  = 0;

    // ---------------------------------------------------------------
    // Test 1: Known forward-shifted pattern (same as previous TB's output)
    // If we inverse-shift it, we should recover the original 00..0f state.
    // forward shift of 00..0f (column-major) was:
    //   00050a0f 04090e03 080d0207 0c01060b
    // inverse should restore:
    //   00010203 04050607 08090a0b 0c0d0e0f
    // ---------------------------------------------------------------
    run_test(
      128'h00050a0f_04090e03_080d0207_0c01060b,
      128'h00010203_04050607_08090a0b_0c0d0e0f
    );

    // ---------------------------------------------------------------
    // Test 2: All zeros should remain zeros
    // ---------------------------------------------------------------
    run_test(
      128'h00000000_00000000_00000000_00000000,
      128'h00000000_00000000_00000000_00000000
    );

    // ---------------------------------------------------------------
    // Test 3: Marker movement check
    // Put marker at s12 (row1,col2). In packing, s12 is byte [55:48].
    // Inverse shift row1 right by 1:
    //   (row1,col2) moves to (row1,col3) => s13 position (byte [23:16]).
    // ---------------------------------------------------------------
    run_test(
      128'h00000000_00000000_00AA0000_00000000,
      128'h00000000_00000000_00000000_0000AA00
    );

    // ---------------------------------------------------------------
    // Test 4: Marker at s33 (row3,col3). In packing, s33 is byte [7:0].
    // Inverse shift row3 right by 3 (equiv left by 1):
    //   (row3,col3) moves to (row3,col2) => s32 position (byte [39:32]).
    // ---------------------------------------------------------------
    run_test(
      128'h00000000_00000000_00000000_000000BB,
      128'h00000000_00000000_000000BB_00000000
    );

    // Summary
    if (any_fail == 0)
      $display("All tests passed!");
    else
      $display("Some tests failed");

    $finish;
  end

endmodule