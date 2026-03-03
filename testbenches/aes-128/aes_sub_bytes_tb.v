//======================================================================
// aes_sub_bytes_tb.v  (Verilog-2001 only)
// Testbench for AES SubBytes (16 parallel forward S-box lookups)
//
// Assumed DUT interface:
//   module aes_sub_bytes(
//       input  wire [127:0] state_in,
//       output wire [127:0] state_out
//   );
//
// Assumed byte packing for this TB:
//   state_in[127:120] = byte15 ... state_in[7:0] = byte0
//======================================================================

`timescale 1ns/1ps

module aes_sub_bytes_tb;

  reg  [127:0] state_in;
  wire [127:0] state_out;

  aes_sub_bytes dut (
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
    // Test 1: All 0x00 -> all 0x63 (since S(00)=63)
    // ---------------------------------------------------------------
    run_test(
      128'h00000000_00000000_00000000_00000000,
      128'h63636363_63636363_63636363_63636363
    );

    // ---------------------------------------------------------------
    // Test 2: Byte ramp 00..0f (MSB..LSB) with known S-box outputs
    //
    // Inputs:  00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f
    // Outputs: 63 7c 77 7b f2 6b 6f c5 30 01 67 2b fe d7 ab 76
    // ---------------------------------------------------------------
    run_test(
      128'h00010203_04050607_08090a0b_0c0d0e0f,
      128'h637c777b_f26b6fc5_3001672b_fed7ab76
    );

    // ---------------------------------------------------------------
    // Test 3: Mixed known values (checks independent byte lanes)
    // Using known pairs:
    //   S(53)=ed, S(ff)=16, S(10)=ca, S(7c)=84, S(00)=63, S(0f)=76
    // ---------------------------------------------------------------
    run_test(
      128'h53ff107c_000f53ff_107c000f_ffffffff,
      128'hed16ca84_6376ed16_ca846376_16161616
    );

    // ---------------------------------------------------------------
    // Test 4: Another lane-mix / visibility pattern
    // Inputs per byte (MSB..LSB):
    //   00 53 ff 10  7c 0f 01 09  0a 0b 0c 0d  0e 02 03 04
    // Expected outputs:
    //   63 ed 16 ca  84 76 7c 01  67 2b fe d7  ab 77 7b f2
    // ---------------------------------------------------------------
    run_test(
      128'h0053ff10_7c0f0109_0a0b0c0d_0e020304,
      128'h63ed16ca_84767c01_672bfed7_ab777bf2
    );

    // Summary
    if (any_fail == 0)
      $display("All tests passed!");
    else
      $display("Some tests failed");

    $finish;
  end

endmodule