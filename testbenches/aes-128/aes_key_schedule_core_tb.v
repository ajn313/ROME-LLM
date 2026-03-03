//======================================================================
// aes_key_schedule_core_tb.v  (Verilog-2001 only)
// Testbench for AES-128 key schedule core g():
//   g(word_in, round) = SubWord(RotWord(word_in)) ^ {Rcon(round),24'h0}
//
// Assumed DUT interface:
//   module aes_key_schedule_core(
//       input  wire [31:0] word_in,
//       input  wire [3:0]  round,
//       output wire [31:0] word_out
//   );
//
// Test vectors are derived from the standard AES-128 key expansion example
// (key = 2b7e1516 28aed2a6 abf71588 09cf4f3c):
//   g(w3,  1) = 8b84eb01   where w3  = 09cf4f3c
//   g(w7,  2) = 52386be5   where w7  = 2a6c7605
//   g(w11, 3) = cf42d28f   where w11 = 7359f67f
//   g(w15, 4) = d2c4e23c   where w15 = 6d7a883b
//   g(w19, 5) = 3b9563b9   where w19 = db0bad00
//   g(w23, 6) = b9596582   where w23 = 11f915bc
//   g(w27, 7) = 23dc5474   where w27 = ca0093fd
//   g(w31, 8) = a486842f   where w31 = 4ea6dc4f
//   g(w35, 9) = 46a515d2   where w35 = 7f8d292f
//   g(w39,10) = 7c639f5b   where w39 = 575c006e
//======================================================================

`timescale 1ns/1ps

module aes_key_schedule_core_tb;

  reg  [31:0] word_in;
  reg  [3:0]  round;
  wire [31:0] word_out;

  aes_key_schedule_core dut (
    .word_in  (word_in),
    .round    (round),
    .word_out (word_out)
  );

  integer test_num;
  integer any_fail;

  task run_test;
    input [31:0] in_w;
    input [3:0]  in_r;
    input [31:0] exp_w;
    begin
      test_num = test_num + 1;

      word_in = in_w;
      round   = in_r;
      #1;

      if (word_out === exp_w) begin
        $display("Test %0d passed", test_num);
      end else begin
        $display("Test %0d failed", test_num);
        $display("  word_in =0x%08x", in_w);
        $display("  round   =0x%01x", in_r);
        $display("  exp     =0x%08x", exp_w);
        $display("  got     =0x%08x", word_out);
        any_fail = 1;
      end
    end
  endtask

  initial begin
    word_in  = 32'h00000000;
    round    = 4'h0;
    test_num = 0;
    any_fail = 0;

    // AES-128 key expansion example-derived g() vectors
    run_test(32'h09cf4f3c, 4'd1,  32'h8b84eb01);
    run_test(32'h2a6c7605, 4'd2,  32'h52386be5);
    run_test(32'h7359f67f, 4'd3,  32'hcf42d28f);
    run_test(32'h6d7a883b, 4'd4,  32'hd2c4e23c);
    run_test(32'hdb0bad00, 4'd5,  32'h3b9563b9);
    run_test(32'h11f915bc, 4'd6,  32'hb9596582);
    run_test(32'hca0093fd, 4'd7,  32'h23dc5474);
    run_test(32'h4ea6dc4f, 4'd8,  32'ha486842f);
    run_test(32'h7f8d292f, 4'd9,  32'h46a515d2);
    run_test(32'h575c006e, 4'd10, 32'h7c639f5b);

    // Summary
    if (any_fail == 0)
      $display("All tests passed!");
    else
      $display("Some tests failed");

    $finish;
  end

endmodule