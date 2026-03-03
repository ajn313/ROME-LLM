//======================================================================
// aes_inv_sbox_tb.v  (Verilog-2001 only)
// Testbench for inverse AES S-box
//
// Assumed DUT interface:
//   module aes_inv_sbox(
//       input  wire [7:0] sbox_in,
//       output wire [7:0] sbox_out
//   );
//======================================================================

`timescale 1ns/1ps

module aes_inv_sbox_tb;

  // -------------------------------------------------------------------
  // DUT signals
  // -------------------------------------------------------------------
  reg  [7:0] sbox_in;
  wire [7:0] sbox_out;

  // -------------------------------------------------------------------
  // DUT instance
  // -------------------------------------------------------------------
  aes_inv_sbox dut (
    .sbox_in (sbox_in),
    .sbox_out(sbox_out)
  );

  // -------------------------------------------------------------------
  // Test bookkeeping
  // -------------------------------------------------------------------
  integer test_num;
  integer any_fail;

  // -------------------------------------------------------------------
  // Test task
  // -------------------------------------------------------------------
  task run_test;
    input [7:0] in_val;
    input [7:0] exp_val;
    begin
      test_num = test_num + 1;

      sbox_in = in_val;
      #1; // combinational settle time

      if (sbox_out === exp_val) begin
        $display("Test %0d passed", test_num);
      end else begin
        $display("Test %0d failed", test_num);
        $display("  in=0x%02x exp=0x%02x got=0x%02x",
                  in_val, exp_val, sbox_out);
        any_fail = 1;
      end
    end
  endtask

  // -------------------------------------------------------------------
  // Main test sequence
  // -------------------------------------------------------------------
  initial begin
    sbox_in  = 8'h00;
    test_num = 0;
    any_fail = 0;

    // Known AES inverse S-box values (FIPS-197)
    // 63 -> 00
    run_test(8'h63, 8'h00);

    // 7c -> 01
    run_test(8'h7c, 8'h01);

    // 01 -> 09
    run_test(8'h01, 8'h09);

    // 76 -> 0f
    run_test(8'h76, 8'h0f);

    // ca -> 10
    run_test(8'hca, 8'h10);

    // ed -> 53 (classic AES example)
    run_test(8'hed, 8'h53);

    // 84 -> 7c
    run_test(8'h84, 8'h7c);

    // 16 -> ff
    run_test(8'h16, 8'hff);

    // ----------------------------------------------------------------
    // Summary
    // ----------------------------------------------------------------
    if (any_fail == 0)
      $display("All tests passed!");
    else
      $display("Some tests failed");

    $finish;
  end

endmodule