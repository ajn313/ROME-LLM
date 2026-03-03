//======================================================================
// aes_inv_mix_columns_tb.v  (Verilog-2001 only)
// Testbench for inverse AES MixColumns
//
// Assumed DUT interface:
//   module aes_inv_mix_columns(
//       input  wire [127:0] state_in,
//       output wire [127:0] state_out
//   );
//
// Assumed state packing (FIPS-197 column-major):
//   [127:120]=s00 [119:112]=s10 [111:104]=s20 [103:96]=s30
//   [95:88]  =s01 [87:80]  =s11 [79:72]  =s21 [71:64] =s31
//   [63:56]  =s02 [55:48]  =s12 [47:40]  =s22 [39:32] =s32
//   [31:24]  =s03 [23:16]  =s13 [15:8]   =s23 [7:0]   =s33
//
// Known example (paired with FIPS-197 forward example):
//   forward: [d4 bf 5d 30]^T -> [04 66 81 e5]^T
//   inverse: [04 66 81 e5]^T -> [d4 bf 5d 30]^T
//
// Inverse MixColumns matrix over GF(2^8):
//   [0e 0b 0d 09]
//   [09 0e 0b 0d]
//   [0d 09 0e 0b]
//   [0b 0d 09 0e]
//======================================================================

`timescale 1ns/1ps

module aes_inv_mix_columns_tb;

  reg  [127:0] state_in;
  wire [127:0] state_out;

  aes_inv_mix_columns dut (
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
    // Test 1: All zeros -> all zeros
    // ---------------------------------------------------------------
    run_test(
      128'h00000000_00000000_00000000_00000000,
      128'h00000000_00000000_00000000_00000000
    );

    // ---------------------------------------------------------------
    // Test 2: Inverse of the classic FIPS forward example (column 0)
    // Input column0:  04 66 81 e5 => state_in[127:96] = 046681e5
    // Expected out:   d4 bf 5d 30 => exp[127:96]      = d4bf5d30
    // ---------------------------------------------------------------
    run_test(
      128'h046681e5_00000000_00000000_00000000,
      128'hd4bf5d30_00000000_00000000_00000000
    );

    // ---------------------------------------------------------------
    // Test 3: Basis vector on column 0: [01 00 00 00]^T
    // Multiply inverse matrix by e0 gives first column of matrix:
    // Output = [0e 09 0d 0b]^T
    // ---------------------------------------------------------------
    run_test(
      128'h01000000_00000000_00000000_00000000,
      128'h0e090d0b_00000000_00000000_00000000
    );

    // ---------------------------------------------------------------
    // Test 4: Basis vector on column 0: [00 01 00 00]^T
    // Output = [0b 0e 09 0d]^T
    // ---------------------------------------------------------------
    run_test(
      128'h00010000_00000000_00000000_00000000,
      128'h0b0e090d_00000000_00000000_00000000
    );

    // ---------------------------------------------------------------
    // Test 5: Put the inverse-classic example on column 1 (wiring check)
    // Column1 occupies [95:64]
    // ---------------------------------------------------------------
    run_test(
      128'h00000000_046681e5_00000000_00000000,
      128'h00000000_d4bf5d30_00000000_00000000
    );

    // Summary
    if (any_fail == 0)
      $display("All tests passed!");
    else
      $display("Some tests failed");

    $finish;
  end

endmodule