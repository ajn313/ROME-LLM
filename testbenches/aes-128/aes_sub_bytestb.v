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
    // Test 1: All 0x00 -> all 0x63
    // ---------------------------------------------------------------
    run_test(
      128'h00000000_00000000_00000000_00000000,
      128'h63636363_63636363_63636363_63636363
    );

    // ---------------------------------------------------------------
    // Test 2: Byte ramp 00..0f
    // ---------------------------------------------------------------
    run_test(
      128'h00010203_04050607_08090a0b_0c0d0e0f,
      128'h637c777b_f26b6fc5_3001672b_fed7ab76
    );

    // ---------------------------------------------------------------
    // Test 3: Mixed known values
    // ---------------------------------------------------------------
    run_test(
      128'h53ff107c_000f53ff_107c000f_ffffffff,
      128'hed16ca10_6376ed16_ca106376_16161616
    );

    // ---------------------------------------------------------------
    // Test 4: Another lane-mix / visibility pattern
    // ---------------------------------------------------------------
    run_test(
      128'h0053ff10_7c0f0109_0a0b0c0d_0e020304,
      128'h63ed16ca_10767c01_672bfed7_ab777bf2
    );

    if (any_fail == 0)
      $display("All tests passed!");
    else
      $display("Some tests failed");

    $finish;
  end

endmodule