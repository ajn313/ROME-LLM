`timescale 1ns / 1ps

module data_memory_tb;

    reg clk;
    reg mem_read;
    reg mem_write;
    reg [15:0] addr;
    reg [15:0] write_data;
    wire [15:0] read_data;

    reg all_passed;

    Data_Memory uut (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .addr(addr),
        .write_data(write_data),
        .read_data(read_data)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        all_passed = 1'b1;

        mem_read   = 1'b0;
        mem_write  = 1'b0;
        addr       = 16'h0000;
        write_data = 16'h0000;

        // Test 1: Write 0x1234 to address 0x0003
        addr       = 16'h0003;
        write_data = 16'h1234;
        mem_write  = 1'b1;
        mem_read   = 1'b0;
        @(posedge clk);
        #1;
        mem_write  = 1'b0;
        mem_read   = 1'b1;
        #1;
        if (read_data === 16'h1234)
            $display("Test 1 passed");
        else begin
            $display("Test 1 failed");
            $display("  Address = %h, Expected = 1234, Got = %h", addr, read_data);
            all_passed = 1'b0;
        end

        // Test 2: Write 0xABCD to address 0x0007
        addr       = 16'h0007;
        write_data = 16'hABCD;
        mem_write  = 1'b1;
        mem_read   = 1'b0;
        @(posedge clk);
        #1;
        mem_write  = 1'b0;
        mem_read   = 1'b1;
        #1;
        if (read_data === 16'hABCD)
            $display("Test 2 passed");
        else begin
            $display("Test 2 failed");
            $display("  Address = %h, Expected = ABCD, Got = %h", addr, read_data);
            all_passed = 1'b0;
        end

        // Test 3: Re-read address 0x0003 and confirm old value is preserved
        addr      = 16'h0003;
        mem_read  = 1'b1;
        mem_write = 1'b0;
        #5;
        if (read_data === 16'h1234)
            $display("Test 3 passed");
        else begin
            $display("Test 3 failed");
            $display("  Address = %h, Expected = 1234, Got = %h", addr, read_data);
            all_passed = 1'b0;
        end

        // Test 4: Overwrite address 0x0003 with 0x0F0F
        addr       = 16'h0003;
        write_data = 16'h0F0F;
        mem_write  = 1'b1;
        mem_read   = 1'b0;
        @(posedge clk);
        #1;
        mem_write  = 1'b0;
        mem_read   = 1'b1;
        #1;
        if (read_data === 16'h0F0F)
            $display("Test 4 passed");
        else begin
            $display("Test 4 failed");
            $display("  Address = %h, Expected = 0F0F, Got = %h", addr, read_data);
            all_passed = 1'b0;
        end

        // Test 5: Disabled write must not change address 0x0007
        addr       = 16'h0007;
        write_data = 16'h5555;
        mem_write  = 1'b0;
        mem_read   = 1'b1;
        @(posedge clk);
        #1;
        if (read_data === 16'hABCD)
            $display("Test 5 passed");
        else begin
            $display("Test 5 failed");
            $display("  Address = %h, Expected = ABCD, Got = %h", addr, read_data);
            all_passed = 1'b0;
        end

        // Test 6: Write zero to a new address
        addr       = 16'h000A;
        write_data = 16'h0000;
        mem_write  = 1'b1;
        mem_read   = 1'b0;
        @(posedge clk);
        #1;
        mem_write  = 1'b0;
        mem_read   = 1'b1;
        #1;
        if (read_data === 16'h0000)
            $display("Test 6 passed");
        else begin
            $display("Test 6 failed");
            $display("  Address = %h, Expected = 0000, Got = %h", addr, read_data);
            all_passed = 1'b0;
        end

        // Test 7: Write all ones to another address
        addr       = 16'h000F;
        write_data = 16'hFFFF;
        mem_write  = 1'b1;
        mem_read   = 1'b0;
        @(posedge clk);
        #1;
        mem_write  = 1'b0;
        mem_read   = 1'b1;
        #1;
        if (read_data === 16'hFFFF)
            $display("Test 7 passed");
        else begin
            $display("Test 7 failed");
            $display("  Address = %h, Expected = FFFF, Got = %h", addr, read_data);
            all_passed = 1'b0;
        end

        // Test 8: Confirm previously written address 0x0003 still holds overwritten value
        addr      = 16'h0003;
        mem_read  = 1'b1;
        mem_write = 1'b0;
        #5;
        if (read_data === 16'h0F0F)
            $display("Test 8 passed");
        else begin
            $display("Test 8 failed");
            $display("  Address = %h, Expected = 0F0F, Got = %h", addr, read_data);
            all_passed = 1'b0;
        end

        if (all_passed)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule