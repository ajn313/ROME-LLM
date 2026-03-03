//======================================================================
// aes_sbox_tb.v  (Verilog-2001, no SystemVerilog)
// Testbench for forward AES S-box
//
// Assumed DUT interface:
//   module aes_sbox(
//       input  wire [7:0] sbox_in,
//       output wire [7:0] sbox_out
//   );
//======================================================================

`timescale 1ns/1ps

module aes_sbox_tb;

  // -------------------------------------------------------------------
  // DUT I/O
  // -------------------------------------------------------------------
  reg  [7:0] sbox_in;
  wire [7:0] sbox_out;

  // -------------------------------------------------------------------
  // Instantiate DUT
  // -------------------------------------------------------------------
  aes_sbox dut (
    .sbox_in (sbox_in),
    .sbox_out(sbox_out)
  );

  // -------------------------------------------------------------------
  // Test bookkeeping
  // -------------------------------------------------------------------
  integer test_num;
  integer any_fail;

  // -------------------------------------------------------------------
  // Single test procedure (Verilog task)
  // -------------------------------------------------------------------
  task run_test;
    input [7:0] in_val;
    input [7:0] exp_val;
    begin
      test_num = test_num + 1;

      sbox_in = in_val;
      #1;  // allow combinational settle

      if (sbox_out === exp_val) begin
        $display("Test %0d passed", test_num);
      end else begin
        $display("Test %0d failed", test_num);
        $display("  in=0x%02x exp=0x%02x got=0x%02x", in_val, exp_val, sbox_out);
        any_fail = 1;
      end
    end
  endtask

  // -------------------------------------------------------------------
  // Main
  // -------------------------------------------------------------------
  initial begin
    // init
    sbox_in   = 8'h00;
    test_num  = 0;
    any_fail  = 0;

    // A handful of well-known AES S-box values (FIPS-197)
    // 00 -> 63
    run_test(8'h00, 8'h63);

    // 01 -> 7c
    run_test(8'h01, 8'h7c);

    // 09 -> 01
    run_test(8'h09, 8'h01);

    // 0f -> 76
    run_test(8'h0f, 8'h76);

    // 10 -> ca
    run_test(8'h10, 8'hca);

    // 53 -> ed  (classic example)
    run_test(8'h53, 8'hed);

    // 7c -> 84
    run_test(8'h7c, 8'h84);

    // ff -> 16
    run_test(8'hff, 8'h16);

    // Summary
    if (any_fail == 0) begin
      $display("All tests passed!");
    end else begin
      $display("Some tests failed");
    end

    $finish;
  end

endmodule