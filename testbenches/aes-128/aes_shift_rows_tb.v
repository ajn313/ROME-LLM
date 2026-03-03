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
//   Row3: shift left by 3 (right by 1)
//======================================================================

`timescale 1ns/1ps

module aes_shift_rows_tb;

  // DUT signals
  reg  [127:0] state_in;
  wire [127:0] state_out;

  // Instantiate DUT
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
    // Test 1: Identity-ish visibility pattern (00..0f as state bytes)
    //
    // Define input bytes sRC as:
    //   s00=00 s10=01 s20=02 s30=03
    //   s01=04 s11=05 s21=06 s31=07
    //   s02=08 s12=09 s22=0a s32=0b
    //   s03=0c s13=0d s23=0e s33=0f
    //
    // After ShiftRows:
    //   Row0: s00 s01 s02 s03 -> 00 04 08 0c
    //   Row1: s10 s11 s12 s13 -> 05 09 0d 01
    //   Row2: s20 s21 s22 s23 -> 0a 0e 02 06
    //   Row3: s30 s31 s32 s33 -> 0f 03 07 0b
    // ---------------------------------------------------------------
    run_test(
      128'h00010203_04050607_08090a0b_0c0d0e0f,
      128'h00050a0f_04090e03_080d0207_0c01060b
    );

    // ---------------------------------------------------------------
    // Test 2: All zeros should remain zeros
    // ---------------------------------------------------------------
    run_test(
      128'h00000000_00000000_00000000_00000000,
      128'h00000000_00000000_00000000_00000000
    );

    // ---------------------------------------------------------------
    // Test 3: Single-bit / single-byte marker (easy to spot movement)
    // Put marker at s13 (row1,col3). In packing, s13 is byte [23:16].
    // After ShiftRows, row1 left shift by 1:
    //   (row1,col3) moves to (row1,col2).
    // So marker should end up at s12 position (byte [55:48]).
    // ---------------------------------------------------------------
    run_test(
      128'h00000000_00000000_00000000_0000AA00,
      128'h00000000_00000000_00AA0000_00000000
    );

    // ---------------------------------------------------------------
    // Test 4: Another marker: s32 (row3,col2). In packing, s32 is byte [39:32].
    // Row3 left shift by 3 (equivalently right shift by 1):
    //   (row3,col2) moves to (row3,col3).
    // So marker should end up at s33 position (byte [7:0]).
    // ---------------------------------------------------------------
    run_test(
      128'h00000000_00000000_000000BB_00000000,
      128'h00000000_00000000_00000000_000000BB
    );

    // Summary
    if (any_fail == 0)
      $display("All tests passed!");
    else
      $display("Some tests failed");

    $finish;
  end

endmodules