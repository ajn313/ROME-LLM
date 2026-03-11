`timescale 1ns / 1ps

module shift_stage_1_tb;

  reg  [31:0] in;
  reg         sel;
  wire [31:0] out;

  reg failed;

  // DUT
  shift_stage_1 uut (
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

    // Test 2: sel=1, shift left by 1
    in  = 32'hF0000000;
    sel = 1'b1;
    #10;
    if (out === 32'hE0000000)
      $display("Test 2 passed");
    else begin
      $display("Test 2 failed");
      failed = 1;
    end

    // Test 3: small value shifted left
    in  = 32'h0000000F;
    sel = 1'b1;
    #10;
    if (out === 32'h0000001E)
      $display("Test 3 passed");
    else begin
      $display("Test 3 failed");
      failed = 1;
    end

    // Test 4: alternating pattern, pass-through
    in  = 32'h55555555;
    sel = 1'b0;
    #10;
    if (out === 32'h55555555)
      $display("Test 4 passed");
    else begin
      $display("Test 4 failed");
      failed = 1;
    end

    // Test 5: alternating pattern shifted left
    in  = 32'h55555555;
    sel = 1'b1;
    #10;
    if (out === 32'hAAAAAAAA)
      $display("Test 5 passed");
    else begin
      $display("Test 5 failed");
      failed = 1;
    end

    // Test 6: all ones shifted left
    in  = 32'hFFFFFFFF;
    sel = 1'b1;
    #10;
    if (out === 32'hFFFFFFFE)
      $display("Test 6 passed");
    else begin
      $display("Test 6 failed");
      failed = 1;
    end

    // Test 7: zero shifted left
    in  = 32'h00000000;
    sel = 1'b1;
    #10;
    if (out === 32'h00000000)
      $display("Test 7 passed");
    else begin
      $display("Test 7 failed");
      failed = 1;
    end

    // Test 8: MSB set only, shifted left should drop bit
    in  = 32'h80000000;
    sel = 1'b1;
    #10;
    if (out === 32'h00000000)
      $display("Test 8 passed");
    else begin
      $display("Test 8 failed");
      failed = 1;
    end

    if (failed == 0)
      $display("All tests passed!");
    else
      $display("Some tests failed");

    $stop;
  end

endmodule