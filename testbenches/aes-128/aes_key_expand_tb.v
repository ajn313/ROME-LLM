//======================================================================
// aes_key_expand_tb.v  (Verilog-2001 only)
// Testbench for AES-128 key expansion step
//
// Assumed DUT interface:
//   module aes_key_expand(
//       input  wire [127:0] key_in,
//       input  wire [3:0]   round,   // 1..10
//       output wire [127:0] key_out
//   );
//
// Uses the standard AES-128 key schedule example (FIPS-197):
// RoundKey[0]  = 2b7e1516 28aed2a6 abf71588 09cf4f3c
// RoundKey[1]  = a0fafe17 88542cb1 23a33939 2a6c7605
// RoundKey[2]  = f2c295f2 7a96b943 5935807a 7359f67f
// RoundKey[3]  = 3d80477d 4716fe3e 1e237e44 6d7a883b
// RoundKey[4]  = ef44a541 a8525b7f b671253b db0bad00
// RoundKey[5]  = d4d1c6f8 7c839d87 caf2b8bc 11f915bc
// RoundKey[6]  = 6d88a37a 110b3efd dbf98641 ca0093fd
// RoundKey[7]  = 4e54f70e 5f5fc9f3 84a64fb2 4ea6dc4f
// RoundKey[8]  = ead27321 b58dbad2 312bf560 7f8d292f
// RoundKey[9]  = ac7766f3 19fadc21 28d12941 575c006e
// RoundKey[10] = d014f9a8 c9ee2589 e13f0cc8 b6630ca6
//======================================================================

`timescale 1ns/1ps

module aes_key_expand_tb;

  reg  [127:0] key_in;
  reg  [3:0]   round;
  wire [127:0] key_out;

  aes_key_expand dut (
    .key_in  (key_in),
    .round   (round),
    .key_out (key_out)
  );

  integer test_num;
  integer any_fail;

  task run_test;
    input [127:0] in_key;
    input [3:0]   in_round;
    input [127:0] exp_key;
    begin
      test_num = test_num + 1;

      key_in = in_key;
      round  = in_round;
      #1;

      if (key_out === exp_key) begin
        $display("Test %0d passed", test_num);
      end else begin
        $display("Test %0d failed", test_num);
        $display("  key_in =0x%032x", in_key);
        $display("  round  =%0d",     in_round);
        $display("  exp    =0x%032x", exp_key);
        $display("  got    =0x%032x", key_out);
        any_fail = 1;
      end
    end
  endtask

  initial begin
    key_in   = 128'h0;
    round    = 4'h0;
    test_num = 0;
    any_fail = 0;

    // RoundKey[0] -> RoundKey[1]
    run_test(
      128'h2b7e1516_28aed2a6_abf71588_09cf4f3c,
      4'd1,
      128'ha0fafe17_88542cb1_23a33939_2a6c7605
    );

    // RoundKey[1] -> RoundKey[2]
    run_test(
      128'ha0fafe17_88542cb1_23a33939_2a6c7605,
      4'd2,
      128'hf2c295f2_7a96b943_5935807a_7359f67f
    );

    // RoundKey[2] -> RoundKey[3]
    run_test(
      128'hf2c295f2_7a96b943_5935807a_7359f67f,
      4'd3,
      128'h3d80477d_4716fe3e_1e237e44_6d7a883b
    );

    // RoundKey[3] -> RoundKey[4]
    run_test(
      128'h3d80477d_4716fe3e_1e237e44_6d7a883b,
      4'd4,
      128'hef44a541_a8525b7f_b671253b_db0bad00
    );

    // RoundKey[4] -> RoundKey[5]
    run_test(
      128'hef44a541_a8525b7f_b671253b_db0bad00,
      4'd5,
      128'hd4d1c6f8_7c839d87_caf2b8bc_11f915bc
    );

    // RoundKey[5] -> RoundKey[6]
    run_test(
      128'hd4d1c6f8_7c839d87_caf2b8bc_11f915bc,
      4'd6,
      128'h6d88a37a_110b3efd_dbf98641_ca0093fd
    );

    // RoundKey[6] -> RoundKey[7]
    run_test(
      128'h6d88a37a_110b3efd_dbf98641_ca0093fd,
      4'd7,
      128'h4e54f70e_5f5fc9f3_84a64fb2_4ea6dc4f
    );

    // RoundKey[7] -> RoundKey[8]
    run_test(
      128'h4e54f70e_5f5fc9f3_84a64fb2_4ea6dc4f,
      4'd8,
      128'head27321_b58dbad2_312bf560_7f8d292f
    );

    // RoundKey[8] -> RoundKey[9]
    run_test(
      128'head27321_b58dbad2_312bf560_7f8d292f,
      4'd9,
      128'hac7766f3_19fadc21_28d12941_575c006e
    );

    // RoundKey[9] -> RoundKey[10]
    run_test(
      128'hac7766f3_19fadc21_28d12941_575c006e,
      4'd10,
      128'hd014f9a8_c9ee2589_e13f0cc8_b6630ca6
    );

    // Summary
    if (any_fail == 0)
      $display("All tests passed!");
    else
      $display("Some tests failed");

    $finish;
  end

endmodule