//======================================================================
// aes_shift_rows_tb.v  (Verilog-2001 only)
// Testbench for forward AES ShiftRows
//
// Assumed DUT interface:
//   module aes_shift_rows(
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
// ShiftRows (forward):
//   Row0: no shift
//   Row1: shift left by 1
//   Row2: shift left by 2
//   Row3: shift left by 3
//======================================================================

`timescale 1ns/1ps

module aes_shift_rows_tb;

  reg  [127:0] state_in;
  wire [127:0] state_out;

  aes_shift_rows dut (
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
    // Test 1: Standard byte ramp
    // ---------------------------------------------------------------
    run_test(
      128'h00010203_04050607_08090a0b_0c0d0e0f,
      128'h00050a0f_04090e03_080d0207_0c01060b
    );

    // ---------------------------------------------------------------
    // Test 2: All zeros
    // ---------------------------------------------------------------
    run_test(
      128'h00000000_00000000_00000000_00000000,
      128'h00000000_00000000_00000000_00000000
    );

    // ---------------------------------------------------------------
    // Test 3: Distinct row-structured visibility test
    //
    // Input state by rows:
    //   Row0: 00 10 20 30
    //   Row1: 01 11 21 31
    //   Row2: 02 12 22 32
    //   Row3: 03 13 23 33
    //
    // Packed column-major input:
    //   col0 = 00 01 02 03
    //   col1 = 10 11 12 13
    //   col2 = 20 21 22 23
    //   col3 = 30 31 32 33
    //
    // After ShiftRows:
    //   Row0 -> 00 10 20 30
    //   Row1 -> 11 21 31 01
    //   Row2 -> 22 32 02 12
    //   Row3 -> 33 03 13 23
    //
    // Repacked column-major output:
    //   col0 = 00 11 22 33
    //   col1 = 10 21 32 03
    //   col2 = 20 31 02 13
    //   col3 = 30 01 12 23
    // ---------------------------------------------------------------
    run_test(
      128'h00010203_10111213_20212223_30313233,
      128'h00112233_10213203_20310213_30011223
    );

    // ---------------------------------------------------------------
    // Test 4: Another marker movement check
    // ---------------------------------------------------------------
    run_test(
      128'h00000000_00000000_000000bb_00000000,
      128'h00000000_00000000_00000000_000000bb
    );

    if (any_fail == 0)
      $display("All tests passed!");
    else
      $display("Some tests failed");

    $finish;
  end

endmodule