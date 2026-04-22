`timescale 1ns / 1ps

module program_counter_tb;

    reg clk;
    reg reset;
    reg [15:0] pc_next;
    wire [15:0] pc_current;

    reg all_passed;

    Program_Counter uut (
        .clk(clk),
        .reset(reset),
        .pc_next(pc_next),
        .pc_current(pc_current)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        all_passed = 1'b1;

        reset = 1'b0;
        pc_next = 16'h0000;

        // Test 1: Reset clears PC
        reset = 1'b1;
        #2;
        @(posedge clk);
        #1;
        if (pc_current === 16'h0000)
            $display("Test 1 passed");
        else begin
            $display("Test 1 failed");
            $display("  Expected pc_current = 16'h0000, Got = %h", pc_current);
            all_passed = 1'b0;
        end

        // Test 2: PC loads first next value after reset deasserted
        reset = 1'b0;
        pc_next = 16'h0001;
        @(posedge clk);
        #1;
        if (pc_current === 16'h0001)
            $display("Test 2 passed");
        else begin
            $display("Test 2 failed");
            $display("  Expected pc_current = 16'h0001, Got = %h", pc_current);
            all_passed = 1'b0;
        end

        // Test 3: PC updates to another value
        pc_next = 16'h000A;
        @(posedge clk);
        #1;
        if (pc_current === 16'h000A)
            $display("Test 3 passed");
        else begin
            $display("Test 3 failed");
            $display("  Expected pc_current = 16'h000A, Got = %h", pc_current);
            all_passed = 1'b0;
        end

        // Test 4: PC handles a larger address
        pc_next = 16'h00F0;
        @(posedge clk);
        #1;
        if (pc_current === 16'h00F0)
            $display("Test 4 passed");
        else begin
            $display("Test 4 failed");
            $display("  Expected pc_current = 16'h00F0, Got = %h", pc_current);
            all_passed = 1'b0;
        end

        // Test 5: Reset works again after normal operation
        pc_next = 16'h1234;
        reset = 1'b1;
        @(posedge clk);
        #1;
        if (pc_current === 16'h0000)
            $display("Test 5 passed");
        else begin
            $display("Test 5 failed");
            $display("  Expected pc_current = 16'h0000, Got = %h", pc_current);
            all_passed = 1'b0;
        end

        // Test 6: PC resumes loading after second reset
        reset = 1'b0;
        pc_next = 16'hABCD;
        @(posedge clk);
        #1;
        if (pc_current === 16'hABCD)
            $display("Test 6 passed");
        else begin
            $display("Test 6 failed");
            $display("  Expected pc_current = 16'hABCD, Got = %h", pc_current);
            all_passed = 1'b0;
        end

        if (all_passed)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule