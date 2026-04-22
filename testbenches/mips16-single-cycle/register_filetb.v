`timescale 1ns / 1ps

module register_file_tb;

    reg clk;
    reg reset;
    reg reg_write;
    reg [2:0] read_reg1;
    reg [2:0] read_reg2;
    reg [2:0] write_reg;
    reg [15:0] write_data;
    wire [15:0] read_data1;
    wire [15:0] read_data2;

    reg all_passed;

    Register_File uut (
        .clk(clk),
        .reset(reset),
        .reg_write(reg_write),
        .read_reg1(read_reg1),
        .read_reg2(read_reg2),
        .write_reg(write_reg),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        all_passed = 1'b1;

        reset      = 1'b0;
        reg_write  = 1'b0;
        read_reg1  = 3'b000;
        read_reg2  = 3'b000;
        write_reg  = 3'b000;
        write_data = 16'h0000;

        // Test 1: Reset clears registers
        reset = 1'b1;
        read_reg1 = 3'b001;
        read_reg2 = 3'b010;
        @(posedge clk);
        #1;
        if ((read_data1 === 16'h0000) && (read_data2 === 16'h0000))
            $display("Test 1 passed");
        else begin
            $display("Test 1 failed");
            $display("  Expected read_data1 = 0000, Got = %h", read_data1);
            $display("  Expected read_data2 = 0000, Got = %h", read_data2);
            all_passed = 1'b0;
        end

        // Release reset
        reset = 1'b0;
        reg_write = 1'b0;

        // Test 2: Write one register and read it back on port 1
        write_reg  = 3'b011;
        write_data = 16'h1234;
        reg_write  = 1'b1;
        @(posedge clk);
        #1;
        reg_write  = 1'b0;
        read_reg1  = 3'b011;
        #1;
        if (read_data1 === 16'h1234)
            $display("Test 2 passed");
        else begin
            $display("Test 2 failed");
            $display("  Expected read_data1 = 1234, Got = %h", read_data1);
            all_passed = 1'b0;
        end

        // Test 3: Write another register and read it back on port 2
        write_reg  = 3'b101;
        write_data = 16'hABCD;
        reg_write  = 1'b1;
        @(posedge clk);
        #1;
        reg_write  = 1'b0;
        read_reg2  = 3'b101;
        #1;
        if (read_data2 === 16'hABCD)
            $display("Test 3 passed");
        else begin
            $display("Test 3 failed");
            $display("  Expected read_data2 = ABCD, Got = %h", read_data2);
            all_passed = 1'b0;
        end

        // Test 4: Read two different written registers simultaneously
        read_reg1 = 3'b011;
        read_reg2 = 3'b101;
        #1;
        if ((read_data1 === 16'h1234) && (read_data2 === 16'hABCD))
            $display("Test 4 passed");
        else begin
            $display("Test 4 failed");
            $display("  Expected read_data1 = 1234, Got = %h", read_data1);
            $display("  Expected read_data2 = ABCD, Got = %h", read_data2);
            all_passed = 1'b0;
        end

        // Test 5: Disabled write must not modify register contents
        write_reg  = 3'b011;
        write_data = 16'hFFFF;
        reg_write  = 1'b0;
        @(posedge clk);
        #1;
        read_reg1 = 3'b011;
        #1;
        if (read_data1 === 16'h1234)
            $display("Test 5 passed");
        else begin
            $display("Test 5 failed");
            $display("  Expected read_data1 to remain 1234, Got = %h", read_data1);
            all_passed = 1'b0;
        end

        // Test 6: Overwrite an existing register
        write_reg  = 3'b011;
        write_data = 16'h0F0F;
        reg_write  = 1'b1;
        @(posedge clk);
        #1;
        reg_write  = 1'b0;
        read_reg1  = 3'b011;
        #1;
        if (read_data1 === 16'h0F0F)
            $display("Test 6 passed");
        else begin
            $display("Test 6 failed");
            $display("  Expected read_data1 = 0F0F, Got = %h", read_data1);
            all_passed = 1'b0;
        end

        // Test 7: Reset clears previously written values
        reset = 1'b1;
        @(posedge clk);
        #1;
        reset = 1'b0;
        read_reg1 = 3'b011;
        read_reg2 = 3'b101;
        #1;
        if ((read_data1 === 16'h0000) && (read_data2 === 16'h0000))
            $display("Test 7 passed");
        else begin
            $display("Test 7 failed");
            $display("  Expected read_data1 = 0000, Got = %h", read_data1);
            $display("  Expected read_data2 = 0000, Got = %h", read_data2);
            all_passed = 1'b0;
        end

        if (all_passed)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule