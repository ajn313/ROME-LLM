`timescale 1ns / 1ps
module verilog_leftrotate_tb;
  
  // Component declaration
  left_rotate leftrotate_inst (
    .inputData(inputData),
    .shiftVal(shiftVal),
    .outputData(outputData)
  );

  // Signals
  reg [31:0] inputData;
  reg [4:0] shiftVal;
  wire [31:0] outputData;

  // Test stimulus
  initial begin
    inputData = 32'b11110000000000000000000000000000;
    shiftVal = 5'b00000; // Equivalent to 32'b00000
    // output should be F0000000
    #100;

    inputData = 32'b11110000000000000000000000000000;
    shiftVal = 5'b00001; // Equivalent to 32'b00001
    // output should be E0000001
    #100;

    inputData = 32'b00000000000000000000000000001111;
    shiftVal = 5'b00001; // Equivalent to 32'b00001
    // output should be 1E
    #100;

    inputData = 32'b00001111000000000000000000000000;
    shiftVal = 5'b00010; // Equivalent to 32'b00010
    // output should be 3C000000
    #100;

    inputData = 32'b01010101010101010101010101010101;
    shiftVal = 5'b00100; // Equivalent to 32'b00100
    // output should be 55555555
    #100;

    inputData = 32'b11001100110011001100110011001100;
    shiftVal = 5'b00101; // Equivalent to 32'b00101
    // output should be 99999999
    #100;

    inputData = 32'b10101010101010101010101010101010;
    shiftVal = 5'b11010; // Equivalent to 32'b11010
    // output should be AAAAAAAA
    #100;

    inputData = 32'b01100110011001100110011001100110;
    shiftVal = 5'b11100; // Equivalent to 32'b11100
    // output should be 66666666
    #100;

    inputData = 32'b01100110011001100110011001100110;
    shiftVal = 5'b11110; // Equivalent to 32'b11110
    // output should be 99999999
    #100;

    inputData = 32'b00110011001100110011001100110011;
    shiftVal = 5'b11111; // Equivalent to 32'b11111
    // output should be 99999999
    #100;

    $stop;
  end

endmodule
