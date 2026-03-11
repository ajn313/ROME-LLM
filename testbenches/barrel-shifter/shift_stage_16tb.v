`timescale 1ns / 1ps

module shift_stage_16_tb;

  reg  [31:0] in;
  reg         sel;
  wire [31:0] out;

  reg failed;

  // DUT
  shift_stage_16 uut (
    .in(in),
    .sel(sel),
    .out(out)
  );

  initial begin
    failed = 0;

    // Test 1: sel=0, pass-through
    in  = 32'hF0000000;
    sel = 1'b0;
    #10;
    if (out === 32'hF0000000)
      $display("Test 1 passed");
    else begin
      $display("Test 1 failed");
      failed = 1;
    end

    // Test 2: rotate left by 16
    in  = 32'hF0000000;
    sel = 1'b1;
    #10;
    if (out === 32'h0000F000)
      $display("Test 2 passed");
    else begin
      $display("Test 2 failed");
      failed = 1;
    end

    // Test 3: low nibble rotates into upper half
    in  = 32'h0000000F;
    sel = 1'b1;
    #10;
    if (out === 32'h000F0000)
      $display("Test 3 passed");
    else begin
      $display("Test 3 failed");
      failed = 1;
    end

    // Test 4: halfword swap on mixed pattern
    in  = 32'h12345678;
    sel = 1'b1;
    #10;
    if (out === 32'h56781234)
      $display("Test 4 passed");
    else begin
      $display("Test 4 failed");
      failed = 1;
    end

    // Test 5: alternating halfwords unchanged after rotate-by-16
    in  = 32'hA5A5A5A5;
    sel = 1'b1;
    #10;
    if (out === 32'hA5A5A5A5)
      $display("Test 5 passed");
    else begin
      $display("Test 5 failed");
      failed = 1;
    end

    // Test 6: zero input
    in  = 32'h00000000;
    sel = 1'b1;
    #10;
    if (out === 32'h00000000)
      $display("Test 6 passed");
    else begin
      $display("Test 6 failed");
      failed = 1;
    end

    // Test 7: single MSB wraps into bit 15
    in  = 32'h80000000;
    sel = 1'b1;
    #10;
    if (out === 32'h00008000)
      $display("Test 7 passed");
    else begin
      $display("Test 7 failed");
      failed = 1;
    end

    // Test 8: single low bit shifts left by 16
    in  = 32'h00000001;
    sel = 1'b1;
    #10;
    if (out === 32'h00010000)
      $display("Test 8 passed");
    else begin
      $display("Test 8 failed");
      failed = 1;
    end

    // Test 9: pass-through on another mixed pattern
    in  = 32'h89ABCDEF;
    sel = 1'b0;
    #10;
    if (out === 32'h89ABCDEF)
      $display("Test 9 passed");
    else begin
      $display("Test 9 failed");
      failed = 1;
    end

    if (failed == 0)
      $display("All tests passed!");
    else
      $display("Some tests failed");

    $stop;
  end

endmodule