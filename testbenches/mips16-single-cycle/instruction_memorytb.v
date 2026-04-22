`timescale 1ns / 1ps

module instruction_memory_tb;

    reg  [15:0] addr;
    wire [15:0] instruction;

    reg all_passed;
    reg [15:0] expected;

    Instruction_Memory uut (
        .addr(addr),
        .instruction(instruction)
    );

    initial begin
        all_passed = 1'b1;

        // Test 1: Read instruction at address 0
        addr = 16'h0000;
        #5;
        expected = uut.memory[0];
        if (instruction === expected)
            $display("Test 1 passed");
        else begin
            $display("Test 1 failed");
            $display("  Address = %h, Expected = %h, Got = %h", addr, expected, instruction);
            all_passed = 1'b0;
        end

        // Test 2: Read instruction at address 1
        addr = 16'h0001;
        #5;
        expected = uut.memory[1];
        if (instruction === expected)
            $display("Test 2 passed");
        else begin
            $display("Test 2 failed");
            $display("  Address = %h, Expected = %h, Got = %h", addr, expected, instruction);
            all_passed = 1'b0;
        end

        // Test 3: Read instruction at address 2
        addr = 16'h0002;
        #5;
        expected = uut.memory[2];
        if (instruction === expected)
            $display("Test 3 passed");
        else begin
            $display("Test 3 failed");
            $display("  Address = %h, Expected = %h, Got = %h", addr, expected, instruction);
            all_passed = 1'b0;
        end

        // Test 4: Read instruction at address 5
        addr = 16'h0005;
        #5;
        expected = uut.memory[5];
        if (instruction === expected)
            $display("Test 4 passed");
        else begin
            $display("Test 4 failed");
            $display("  Address = %h, Expected = %h, Got = %h", addr, expected, instruction);
            all_passed = 1'b0;
        end

        // Test 5: Read instruction at address 10
        addr = 16'h000A;
        #5;
        expected = uut.memory[10];
        if (instruction === expected)
            $display("Test 5 passed");
        else begin
            $display("Test 5 failed");
            $display("  Address = %h, Expected = %h, Got = %h", addr, expected, instruction);
            all_passed = 1'b0;
        end

        // Test 6: Re-read address 0 to confirm consistent combinational behavior
        addr = 16'h0000;
        #5;
        expected = uut.memory[0];
        if (instruction === expected)
            $display("Test 6 passed");
        else begin
            $display("Test 6 failed");
            $display("  Address = %h, Expected = %h, Got = %h", addr, expected, instruction);
            all_passed = 1'b0;
        end

        if (all_passed)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule