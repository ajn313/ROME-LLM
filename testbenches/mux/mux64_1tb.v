`timescale 1ns/1ps

module tb_mux64_1;

  reg  [5:0]  sel;
  reg  [63:0] in;
  wire        out;

  // DUT
  mux64_1 dut (
    .sel(sel),
    .in (in),
    .out(out)
  );

  integer testnum;
  integer fail_count;
  reg expected;

  task run_test;
    input integer tnum;
    input [63:0]  in_vec;
    input [5:0]   sel_val;
    reg           exp;
    begin
      // Apply inputs
      in  = in_vec;
      sel = sel_val;

      // Allow combinational logic to settle
      #1;

      // Expected value
      exp = in_vec[sel_val];

      // Check
      if (out === exp) begin
        $display("Test %0d passed", tnum);
      end else begin
        $display("Test %0d failed (sel=%0d, in=0x%016h, expected=%0b, got=%0b)",
                 tnum, sel_val, in_vec, exp, out);
        fail_count = fail_count + 1;
      end
    end
  endtask

  initial begin
    // Initialize
    sel        = 6'd0;
    in         = 64'd0;
    testnum    = 0;
    fail_count = 0;

    // Test 1: all zeros
    testnum = testnum + 1;
    run_test(testnum, 64'h0000_0000_0000_0000, 6'd0);

    // Test 2: all ones
    testnum = testnum + 1;
    run_test(testnum, 64'hFFFF_FFFF_FFFF_FFFF, 6'd37);

    // Test 3: LSB set
    testnum = testnum + 1;
    run_test(testnum, 64'h0000_0000_0000_0001, 6'd0);

    // Test 4: MSB set
    testnum = testnum + 1;
    run_test(testnum, 64'h8000_0000_0000_0000, 6'd63);

    // Test 5–6: alternating pattern
    testnum = testnum + 1;
    run_test(testnum, 64'hAAAA_AAAA_AAAA_AAAA, 6'd1);
    testnum = testnum + 1;
    run_test(testnum, 64'hAAAA_AAAA_AAAA_AAAA, 6'd2);

    // Test 7–9: mixed pattern
    testnum = testnum + 1;
    run_test(testnum, 64'h0123_4567_89AB_CDEF, 6'd4);
    testnum = testnum + 1;
    run_test(testnum, 64'h0123_4567_89AB_CDEF, 6'd31);
    testnum = testnum + 1;
    run_test(testnum, 64'h0123_4567_89AB_CDEF, 6'd60);

    // Final summary
    if (fail_count == 0) begin
      $display("All tests passed!");
    end else begin
      $display("%0d test(s) failed.", fail_count);
    end

    $finish;
  end

endmodule
