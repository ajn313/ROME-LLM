`timescale 1ns / 1ps

module control_unit_tb;

    reg  [3:0] opcode;
    wire reg_dst;
    wire alu_src;
    wire mem_to_reg;
    wire reg_write;
    wire mem_read;
    wire mem_write;
    wire branch;
    wire jump;
    wire [1:0] alu_op;

    reg all_passed;

    reg expected_reg_dst;
    reg expected_alu_src;
    reg expected_mem_to_reg;
    reg expected_reg_write;
    reg expected_mem_read;
    reg expected_mem_write;
    reg expected_branch;
    reg expected_jump;
    reg [1:0] expected_alu_op;

    Control_Unit uut (
        .opcode(opcode),
        .reg_dst(reg_dst),
        .alu_src(alu_src),
        .mem_to_reg(mem_to_reg),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch),
        .jump(jump),
        .alu_op(alu_op)
    );

    initial begin
        all_passed = 1'b1;

        // Test 1: R-type
        opcode = 4'b0000;
        expected_reg_dst    = 1'b1;
        expected_alu_src    = 1'b0;
        expected_mem_to_reg = 1'b0;
        expected_reg_write  = 1'b1;
        expected_mem_read   = 1'b0;
        expected_mem_write  = 1'b0;
        expected_branch     = 1'b0;
        expected_jump       = 1'b0;
        expected_alu_op     = 2'b10;
        #5;
        if ((reg_dst === expected_reg_dst) &&
            (alu_src === expected_alu_src) &&
            (mem_to_reg === expected_mem_to_reg) &&
            (reg_write === expected_reg_write) &&
            (mem_read === expected_mem_read) &&
            (mem_write === expected_mem_write) &&
            (branch === expected_branch) &&
            (jump === expected_jump) &&
            (alu_op === expected_alu_op))
            $display("Test 1 passed");
        else begin
            $display("Test 1 failed");
            $display("  opcode=%b", opcode);
            $display("  Expected reg_dst=%b alu_src=%b mem_to_reg=%b reg_write=%b mem_read=%b mem_write=%b branch=%b jump=%b alu_op=%b",
                     expected_reg_dst, expected_alu_src, expected_mem_to_reg, expected_reg_write,
                     expected_mem_read, expected_mem_write, expected_branch, expected_jump, expected_alu_op);
            $display("  Got      reg_dst=%b alu_src=%b mem_to_reg=%b reg_write=%b mem_read=%b mem_write=%b branch=%b jump=%b alu_op=%b",
                     reg_dst, alu_src, mem_to_reg, reg_write,
                     mem_read, mem_write, branch, jump, alu_op);
            all_passed = 1'b0;
        end

        // Test 2: ADDI
        opcode = 4'b0001;
        expected_reg_dst    = 1'b0;
        expected_alu_src    = 1'b1;
        expected_mem_to_reg = 1'b0;
        expected_reg_write  = 1'b1;
        expected_mem_read   = 1'b0;
        expected_mem_write  = 1'b0;
        expected_branch     = 1'b0;
        expected_jump       = 1'b0;
        expected_alu_op     = 2'b00;
        #5;
        if ((reg_dst === expected_reg_dst) &&
            (alu_src === expected_alu_src) &&
            (mem_to_reg === expected_mem_to_reg) &&
            (reg_write === expected_reg_write) &&
            (mem_read === expected_mem_read) &&
            (mem_write === expected_mem_write) &&
            (branch === expected_branch) &&
            (jump === expected_jump) &&
            (alu_op === expected_alu_op))
            $display("Test 2 passed");
        else begin
            $display("Test 2 failed");
            $display("  opcode=%b", opcode);
            $display("  Expected reg_dst=%b alu_src=%b mem_to_reg=%b reg_write=%b mem_read=%b mem_write=%b branch=%b jump=%b alu_op=%b",
                     expected_reg_dst, expected_alu_src, expected_mem_to_reg, expected_reg_write,
                     expected_mem_read, expected_mem_write, expected_branch, expected_jump, expected_alu_op);
            $display("  Got      reg_dst=%b alu_src=%b mem_to_reg=%b reg_write=%b mem_read=%b mem_write=%b branch=%b jump=%b alu_op=%b",
                     reg_dst, alu_src, mem_to_reg, reg_write,
                     mem_read, mem_write, branch, jump, alu_op);
            all_passed = 1'b0;
        end

        // Test 3: LW
        opcode = 4'b0010;
        expected_reg_dst    = 1'b0;
        expected_alu_src    = 1'b1;
        expected_mem_to_reg = 1'b1;
        expected_reg_write  = 1'b1;
        expected_mem_read   = 1'b1;
        expected_mem_write  = 1'b0;
        expected_branch     = 1'b0;
        expected_jump       = 1'b0;
        expected_alu_op     = 2'b00;
        #5;
        if ((reg_dst === expected_reg_dst) &&
            (alu_src === expected_alu_src) &&
            (mem_to_reg === expected_mem_to_reg) &&
            (reg_write === expected_reg_write) &&
            (mem_read === expected_mem_read) &&
            (mem_write === expected_mem_write) &&
            (branch === expected_branch) &&
            (jump === expected_jump) &&
            (alu_op === expected_alu_op))
            $display("Test 3 passed");
        else begin
            $display("Test 3 failed");
            $display("  opcode=%b", opcode);
            $display("  Expected reg_dst=%b alu_src=%b mem_to_reg=%b reg_write=%b mem_read=%b mem_write=%b branch=%b jump=%b alu_op=%b",
                     expected_reg_dst, expected_alu_src, expected_mem_to_reg, expected_reg_write,
                     expected_mem_read, expected_mem_write, expected_branch, expected_jump, expected_alu_op);
            $display("  Got      reg_dst=%b alu_src=%b mem_to_reg=%b reg_write=%b mem_read=%b mem_write=%b branch=%b jump=%b alu_op=%b",
                     reg_dst, alu_src, mem_to_reg, reg_write,
                     mem_read, mem_write, branch, jump, alu_op);
            all_passed = 1'b0;
        end

        // Test 4: SW
        opcode = 4'b0011;
        expected_reg_dst    = 1'b0;
        expected_alu_src    = 1'b1;
        expected_mem_to_reg = 1'b0;
        expected_reg_write  = 1'b0;
        expected_mem_read   = 1'b0;
        expected_mem_write  = 1'b1;
        expected_branch     = 1'b0;
        expected_jump       = 1'b0;
        expected_alu_op     = 2'b00;
        #5;
        if ((reg_dst === expected_reg_dst) &&
            (alu_src === expected_alu_src) &&
            (mem_to_reg === expected_mem_to_reg) &&
            (reg_write === expected_reg_write) &&
            (mem_read === expected_mem_read) &&
            (mem_write === expected_mem_write) &&
            (branch === expected_branch) &&
            (jump === expected_jump) &&
            (alu_op === expected_alu_op))
            $display("Test 4 passed");
        else begin
            $display("Test 4 failed");
            $display("  opcode=%b", opcode);
            $display("  Expected reg_dst=%b alu_src=%b mem_to_reg=%b reg_write=%b mem_read=%b mem_write=%b branch=%b jump=%b alu_op=%b",
                     expected_reg_dst, expected_alu_src, expected_mem_to_reg, expected_reg_write,
                     expected_mem_read, expected_mem_write, expected_branch, expected_jump, expected_alu_op);
            $display("  Got      reg_dst=%b alu_src=%b mem_to_reg=%b reg_write=%b mem_read=%b mem_write=%b branch=%b jump=%b alu_op=%b",
                     reg_dst, alu_src, mem_to_reg, reg_write,
                     mem_read, mem_write, branch, jump, alu_op);
            all_passed = 1'b0;
        end

        // Test 5: BEQ
        opcode = 4'b0100;
        expected_reg_dst    = 1'b0;
        expected_alu_src    = 1'b0;
        expected_mem_to_reg = 1'b0;
        expected_reg_write  = 1'b0;
        expected_mem_read   = 1'b0;
        expected_mem_write  = 1'b0;
        expected_branch     = 1'b1;
        expected_jump       = 1'b0;
        expected_alu_op     = 2'b01;
        #5;
        if ((reg_dst === expected_reg_dst) &&
            (alu_src === expected_alu_src) &&
            (mem_to_reg === expected_mem_to_reg) &&
            (reg_write === expected_reg_write) &&
            (mem_read === expected_mem_read) &&
            (mem_write === expected_mem_write) &&
            (branch === expected_branch) &&
            (jump === expected_jump) &&
            (alu_op === expected_alu_op))
            $display("Test 5 passed");
        else begin
            $display("Test 5 failed");
            $display("  opcode=%b", opcode);
            $display("  Expected reg_dst=%b alu_src=%b mem_to_reg=%b reg_write=%b mem_read=%b mem_write=%b branch=%b jump=%b alu_op=%b",
                     expected_reg_dst, expected_alu_src, expected_mem_to_reg, expected_reg_write,
                     expected_mem_read, expected_mem_write, expected_branch, expected_jump, expected_alu_op);
            $display("  Got      reg_dst=%b alu_src=%b mem_to_reg=%b reg_write=%b mem_read=%b mem_write=%b branch=%b jump=%b alu_op=%b",
                     reg_dst, alu_src, mem_to_reg, reg_write,
                     mem_read, mem_write, branch, jump, alu_op);
            all_passed = 1'b0;
        end

        // Test 6: J
        opcode = 4'b0101;
        expected_reg_dst    = 1'b0;
        expected_alu_src    = 1'b0;
        expected_mem_to_reg = 1'b0;
        expected_reg_write  = 1'b0;
        expected_mem_read   = 1'b0;
        expected_mem_write  = 1'b0;
        expected_branch     = 1'b0;
        expected_jump       = 1'b1;
        expected_alu_op     = 2'b00;
        #5;
        if ((reg_dst === expected_reg_dst) &&
            (alu_src === expected_alu_src) &&
            (mem_to_reg === expected_mem_to_reg) &&
            (reg_write === expected_reg_write) &&
            (mem_read === expected_mem_read) &&
            (mem_write === expected_mem_write) &&
            (branch === expected_branch) &&
            (jump === expected_jump) &&
            (alu_op === expected_alu_op))
            $display("Test 6 passed");
        else begin
            $display("Test 6 failed");
            $display("  opcode=%b", opcode);
            $display("  Expected reg_dst=%b alu_src=%b mem_to_reg=%b reg_write=%b mem_read=%b mem_write=%b branch=%b jump=%b alu_op=%b",
                     expected_reg_dst, expected_alu_src, expected_mem_to_reg, expected_reg_write,
                     expected_mem_read, expected_mem_write, expected_branch, expected_jump, expected_alu_op);
            $display("  Got      reg_dst=%b alu_src=%b mem_to_reg=%b reg_write=%b mem_read=%b mem_write=%b branch=%b jump=%b alu_op=%b",
                     reg_dst, alu_src, mem_to_reg, reg_write,
                     mem_read, mem_write, branch, jump, alu_op);
            all_passed = 1'b0;
        end

        // Test 7: Invalid / default opcode
        opcode = 4'b1111;
        expected_reg_dst    = 1'b0;
        expected_alu_src    = 1'b0;
        expected_mem_to_reg = 1'b0;
        expected_reg_write  = 1'b0;
        expected_mem_read   = 1'b0;
        expected_mem_write  = 1'b0;
        expected_branch     = 1'b0;
        expected_jump       = 1'b0;
        expected_alu_op     = 2'b00;
        #5;
        if ((reg_dst === expected_reg_dst) &&
            (alu_src === expected_alu_src) &&
            (mem_to_reg === expected_mem_to_reg) &&
            (reg_write === expected_reg_write) &&
            (mem_read === expected_mem_read) &&
            (mem_write === expected_mem_write) &&
            (branch === expected_branch) &&
            (jump === expected_jump) &&
            (alu_op === expected_alu_op))
            $display("Test 7 passed");
        else begin
            $display("Test 7 failed");
            $display("  opcode=%b", opcode);
            $display("  Expected reg_dst=%b alu_src=%b mem_to_reg=%b reg_write=%b mem_read=%b mem_write=%b branch=%b jump=%b alu_op=%b",
                     expected_reg_dst, expected_alu_src, expected_mem_to_reg, expected_reg_write,
                     expected_mem_read, expected_mem_write, expected_branch, expected_jump, expected_alu_op);
            $display("  Got      reg_dst=%b alu_src=%b mem_to_reg=%b reg_write=%b mem_read=%b mem_write=%b branch=%b jump=%b alu_op=%b",
                     reg_dst, alu_src, mem_to_reg, reg_write,
                     mem_read, mem_write, branch, jump, alu_op);
            all_passed = 1'b0;
        end

        if (all_passed)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule