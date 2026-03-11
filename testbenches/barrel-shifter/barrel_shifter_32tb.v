`timescale 1ns / 1ps

module barrel_shifter_32tb;

  // Signals
  reg  [31:0] inputData;
  reg  [4:0]  shiftVal;
  wire [31:0] outputData;

  reg failed;

  // Component declaration
  barrel_shifter_32 barrel_shifter_32_inst (
    .inputData(inputData),
    .shiftVal(shiftVal),
    .outputData(outputData)
  );

  initial begin
    failed = 0;

    // Test 1
    inputData = 32'b11110000000000000000000000000000;
    shiftVal  = 5'b00000;
    #10;
    if (outputData === 32'hF0000000)
      $display("Test 1 passed");
    else begin
      $display("Test 1 failed");
      failed = 1;
    end

    // Test 2
    inputData = 32'b11110000000000000000000000000000;
    shiftVal  = 5'b00001;
    #10;
    if (outputData === 32'hE0000001)
      $display("Test 2 passed");
    else begin
      $display("Test 2 failed");
      failed = 1;
    end

    // Test 3
    inputData = 32'b00000000000000000000000000001111;
    shiftVal  = 5'b00001;
    #10;
    if (outputData === 32'h0000001E)
      $display("Test 3 passed");
    else begin
      $display("Test 3 failed");
      failed = 1;
    end

    // Test 4
    inputData = 32'b00001111000000000000000000000000;
    shiftVal  = 5'b00010;
    #10;
    if (outputData === 32'h3C000000)
      $display("Test 4 passed");
    else begin
      $display("Test 4 failed");
      failed = 1;
    end

    // Test 5
    inputData = 32'b01010101010101010101010101010101;
    shiftVal  = 5'b00100;
    #10;
    if (outputData === 32'h55555555)
      $display("Test 5 passed");
    else begin
      $display("Test 5 failed");
      failed = 1;
    end

    // Test 6
    inputData = 32'b11001100110011001100110011001100;
    shiftVal  = 5'b00101;
    #10;
    if (outputData === 32'h99999999)
      $display("Test 6 passed");
    else begin
      $display("Test 6 failed");
      failed = 1;
    end

    // Test 7
    inputData = 32'b10101010101010101010101010101010;
    shiftVal  = 5'b11010;
    #10;
    if (outputData === 32'hAAAAAAAA)
      $display("Test 7 passed");
    else begin
      $display("Test 7 failed");
      failed = 1;
    end

    // Test 8
    inputData = 32'b01100110011001100110011001100110;
    shiftVal  = 5'b11100;
    #10;
    if (outputData === 32'h66666666)
      $display("Test 8 passed");
    else begin
      $display("Test 8 failed");
      failed = 1;
    end

    // Test 9
    inputData = 32'b01100110011001100110011001100110;
    shiftVal  = 5'b11110;
    #10;
    if (outputData === 32'h99999999)
      $display("Test 9 passed");
    else begin
      $display("Test 9 failed");
      failed = 1;
    end

    // Test 10
    inputData = 32'b00110011001100110011001100110011;
    shiftVal  = 5'b11111;
    #10;
    if (outputData === 32'h99999999)
      $display("Test 10 passed");
    else begin
      $display("Test 10 failed");
      failed = 1;
    end

    if (failed == 0)
      $display("All tests passed!");
    else
      $display("Some tests failed");

    $stop;
  end

endmodule