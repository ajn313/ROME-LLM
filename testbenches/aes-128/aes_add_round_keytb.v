//======================================================================
// aes_add_round_key_tb.v  (Verilog-2001 only)
// Testbench for AES AddRoundKey (state XOR round_key)
//
// Assumed DUT interface:
//   module aes_add_round_key(
//       input  wire [127:0] state_in,
//       input  wire [127:0] round_key,
//       output wire [127:0] state_out
//   );
//======================================================================

`timescale 1ns/1ps

module aes_add_round_key_tb;

  reg  [127:0] state_in;
  reg  [127:0] round_key;
  wire [127:0] state_out;

  aes_add_round_key dut (
    .state_in  (state_in),
    .round_key (round_key),
    .state_out (state_out)
  );

  integer test_num;
  integer any_fail;

  task run_test;
    input [127:0] s;
    input [127:0] k;
    input [127:0] exp;
    reg   [127:0] got;
    begin
      test_num = test_num + 1;

      state_in  = s;
      round_key = k;
      #1;

      got = state_out;

      if (got === exp) begin
        $display("Test %0d passed", test_num);
      end else begin
        $display("Test %0d failed", test_num);
        $display("  state_in =0x%032x", s);
        $display("  round_key=0x%032x", k);
        $display("  exp      =0x%032x", exp);
        $display("  got      =0x%032x", got);
        any_fail = 1;
      end
    end
  endtask

  initial begin
    state_in  = 128'h0;
    round_key = 128'h0;
    test_num  = 0;
    any_fail  = 0;

    // ---------------------------------------------------------------
    // Test 1: 0 XOR 0 = 0
    // ---------------------------------------------------------------
    run_test(
      128'h00000000_00000000_00000000_00000000,
      128'h00000000_00000000_00000000_00000000,
      128'h00000000_00000000_00000000_00000000
    );

    // ---------------------------------------------------------------
    // Test 2: state XOR 0 = state
    // ---------------------------------------------------------------
    run_test(
      128'h00112233_44556677_8899aabb_ccddeeff,
      128'h00000000_00000000_00000000_00000000,
      128'h00112233_44556677_8899aabb_ccddeeff
    );

    // ---------------------------------------------------------------
    // Test 3: 0 XOR key = key
    // ---------------------------------------------------------------
    run_test(
      128'h00000000_00000000_00000000_00000000,
      128'h0f0e0d0c_0b0a0908_07060504_03020100,
      128'h0f0e0d0c_0b0a0908_07060504_03020100
    );

    // ---------------------------------------------------------------
    // Test 4: Known XOR pattern (byte visibility)
    // ---------------------------------------------------------------
    run_test(
      128'hffff0000_aaaa5555_12345678_000000ff,
      128'h00ff00ff_5555aaaa_87654321_ff000000,
      128'hff0000ff_ffffffff_95511559_ff0000ff
    );

    // ---------------------------------------------------------------
    // Test 5: Another pattern (alternating bits)
    // ---------------------------------------------------------------
    run_test(
      128'haaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa,
      128'h55555555555555555555555555555555,
      128'hffffffffffffffffffffffffffffffff
    );

    // Summary
    if (any_fail == 0)
      $display("All tests passed!");
    else
      $display("Some tests failed");

    $finish;
  end

endmodule