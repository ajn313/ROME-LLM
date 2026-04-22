`timescale 1ns / 1ps

module instruction_decoder_tb;

    reg  [15:0] instruction;
    wire [3:0]  opcode;
    wire [2:0]  rs;
    wire [2:0]  rt;
    wire [2:0]  rd;
    wire [2:0]  funct;
    wire [6:0]  imm7;
    wire [11:0] jump_addr;

    reg all_passed;

    reg [3:0]  expected_opcode;
    reg [2:0]  expected_rs;
    reg [2:0]  expected_rt;
    reg [2:0]  expected_rd;
    reg [2:0]  expected_funct;
    reg [6:0]  expected_imm7;
    reg [11:0] expected_jump_addr;

    Instruction_Decoder uut (
        .instruction(instruction),
        .opcode(opcode),
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .funct(funct),
        .imm7(imm7),
        .jump_addr(jump_addr)
    );

    initial begin
        all_passed = 1'b1;

        // Test 1: All zeros
        instruction         = 16'h0000;
        expected_opcode     = 4'b0000;
        expected_rs         = 3'b000;
        expected_rt         = 3'b000;
        expected_rd         = 3'b000;
        expected_funct      = 3'b000;
        expected_imm7       = 7'b0000000;
        expected_jump_addr  = 12'h000;
        #5;
        if ((opcode === expected_opcode) &&
            (rs === expected_rs) &&
            (rt === expected_rt) &&
            (rd === expected_rd) &&
            (funct === expected_funct) &&
            (imm7 === expected_imm7) &&
            (jump_addr === expected_jump_addr))
            $display("Test 1 passed");
        else begin
            $display("Test 1 failed");
            $display("  instruction = %h", instruction);
            $display("  Expected opcode=%b rs=%b rt=%b rd=%b funct=%b imm7=%b jump_addr=%h",
                     expected_opcode, expected_rs, expected_rt, expected_rd,
                     expected_funct, expected_imm7, expected_jump_addr);
            $display("  Got      opcode=%b rs=%b rt=%b rd=%b funct=%b imm7=%b jump_addr=%h",
                     opcode, rs, rt, rd, funct, imm7, jump_addr);
            all_passed = 1'b0;
        end

        // Test 2: All ones
        instruction         = 16'hFFFF;
        expected_opcode     = 4'b1111;
        expected_rs         = 3'b111;
        expected_rt         = 3'b111;
        expected_rd         = 3'b111;
        expected_funct      = 3'b111;
        expected_imm7       = 7'b1111111;
        expected_jump_addr  = 12'hFFF;
        #5;
        if ((opcode === expected_opcode) &&
            (rs === expected_rs) &&
            (rt === expected_rt) &&
            (rd === expected_rd) &&
            (funct === expected_funct) &&
            (imm7 === expected_imm7) &&
            (jump_addr === expected_jump_addr))
            $display("Test 2 passed");
        else begin
            $display("Test 2 failed");
            $display("  instruction = %h", instruction);
            $display("  Expected opcode=%b rs=%b rt=%b rd=%b funct=%b imm7=%b jump_addr=%h",
                     expected_opcode, expected_rs, expected_rt, expected_rd,
                     expected_funct, expected_imm7, expected_jump_addr);
            $display("  Got      opcode=%b rs=%b rt=%b rd=%b funct=%b imm7=%b jump_addr=%h",
                     opcode, rs, rt, rd, funct, imm7, jump_addr);
            all_passed = 1'b0;
        end

        // Test 3: Mixed pattern 1
        instruction         = 16'b1010_011_100_101_110;
        expected_opcode     = 4'b1010;
        expected_rs         = 3'b011;
        expected_rt         = 3'b100;
        expected_rd         = 3'b101;
        expected_funct      = 3'b110;
        expected_imm7       = 7'b0101110;
        expected_jump_addr  = 12'b011100101110;
        #5;
        if ((opcode === expected_opcode) &&
            (rs === expected_rs) &&
            (rt === expected_rt) &&
            (rd === expected_rd) &&
            (funct === expected_funct) &&
            (imm7 === expected_imm7) &&
            (jump_addr === expected_jump_addr))
            $display("Test 3 passed");
        else begin
            $display("Test 3 failed");
            $display("  instruction = %h", instruction);
            $display("  Expected opcode=%b rs=%b rt=%b rd=%b funct=%b imm7=%b jump_addr=%h",
                     expected_opcode, expected_rs, expected_rt, expected_rd,
                     expected_funct, expected_imm7, expected_jump_addr);
            $display("  Got      opcode=%b rs=%b rt=%b rd=%b funct=%b imm7=%b jump_addr=%h",
                     opcode, rs, rt, rd, funct, imm7, jump_addr);
            all_passed = 1'b0;
        end

        // Test 4: Mixed pattern 2
        instruction         = 16'b0101_110_001_011_001;
        expected_opcode     = 4'b0101;
        expected_rs         = 3'b110;
        expected_rt         = 3'b001;
        expected_rd         = 3'b011;
        expected_funct      = 3'b001;
        expected_imm7       = 7'b1011001;
        expected_jump_addr  = 12'b110001011001;
        #5;
        if ((opcode === expected_opcode) &&
            (rs === expected_rs) &&
            (rt === expected_rt) &&
            (rd === expected_rd) &&
            (funct === expected_funct) &&
            (imm7 === expected_imm7) &&
            (jump_addr === expected_jump_addr))
            $display("Test 4 passed");
        else begin
            $display("Test 4 failed");
            $display("  instruction = %h", instruction);
            $display("  Expected opcode=%b rs=%b rt=%b rd=%b funct=%b imm7=%b jump_addr=%h",
                     expected_opcode, expected_rs, expected_rt, expected_rd,
                     expected_funct, expected_imm7, expected_jump_addr);
            $display("  Got      opcode=%b rs=%b rt=%b rd=%b funct=%b imm7=%b jump_addr=%h",
                     opcode, rs, rt, rd, funct, imm7, jump_addr);
            all_passed = 1'b0;
        end

        // Test 5: Immediate-heavy lower bits
        instruction         = 16'b0011_001_010_111_111;
        expected_opcode     = 4'b0011;
        expected_rs         = 3'b001;
        expected_rt         = 3'b010;
        expected_rd         = 3'b111;
        expected_funct      = 3'b111;
        expected_imm7       = 7'b1111111;
        expected_jump_addr  = 12'b001010111111;
        #5;
        if ((opcode === expected_opcode) &&
            (rs === expected_rs) &&
            (rt === expected_rt) &&
            (rd === expected_rd) &&
            (funct === expected_funct) &&
            (imm7 === expected_imm7) &&
            (jump_addr === expected_jump_addr))
            $display("Test 5 passed");
        else begin
            $display("Test 5 failed");
            $display("  instruction = %h", instruction);
            $display("  Expected opcode=%b rs=%b rt=%b rd=%b funct=%b imm7=%b jump_addr=%h",
                     expected_opcode, expected_rs, expected_rt, expected_rd,
                     expected_funct, expected_imm7, expected_jump_addr);
            $display("  Got      opcode=%b rs=%b rt=%b rd=%b funct=%b imm7=%b jump_addr=%h",
                     opcode, rs, rt, rd, funct, imm7, jump_addr);
            all_passed = 1'b0;
        end

        // Test 6: Jump-address-oriented pattern
        instruction         = 16'b1001_101_011_000_100;
        expected_opcode     = 4'b1001;
        expected_rs         = 3'b101;
        expected_rt         = 3'b011;
        expected_rd         = 3'b000;
        expected_funct      = 3'b100;
        expected_imm7       = 7'b1000100;
        expected_jump_addr  = 12'b101011000100;
        #5;
        if ((opcode === expected_opcode) &&
            (rs === expected_rs) &&
            (rt === expected_rt) &&
            (rd === expected_rd) &&
            (funct === expected_funct) &&
            (imm7 === expected_imm7) &&
            (jump_addr === expected_jump_addr))
            $display("Test 6 passed");
        else begin
            $display("Test 6 failed");
            $display("  instruction = %h", instruction);
            $display("  Expected opcode=%b rs=%b rt=%b rd=%b funct=%b imm7=%b jump_addr=%h",
                     expected_opcode, expected_rs, expected_rt, expected_rd,
                     expected_funct, expected_imm7, expected_jump_addr);
            $display("  Got      opcode=%b rs=%b rt=%b rd=%b funct=%b imm7=%b jump_addr=%h",
                     opcode, rs, rt, rd, funct, imm7, jump_addr);
            all_passed = 1'b0;
        end

        if (all_passed)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule