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

    task run_test;
        input integer tnum;
        input [15:0] instr;
        begin
            instruction = instr;

            expected_opcode    = instr[15:12];
            expected_rs        = instr[11:9];
            expected_rt        = instr[8:6];
            expected_rd        = instr[5:3];
            expected_funct     = instr[2:0];
            expected_imm7      = instr[6:0];
            expected_jump_addr = instr[11:0];

            #5;

            if ((opcode === expected_opcode) &&
                (rs === expected_rs) &&
                (rt === expected_rt) &&
                (rd === expected_rd) &&
                (funct === expected_funct) &&
                (imm7 === expected_imm7) &&
                (jump_addr === expected_jump_addr)) begin
                $display("Test %0d passed", tnum);
            end else begin
                $display("Test %0d failed", tnum);
                $display("  instruction = %h", instruction);
                $display("  Expected opcode=%b rs=%b rt=%b rd=%b funct=%b imm7=%b jump_addr=%h",
                         expected_opcode, expected_rs, expected_rt, expected_rd,
                         expected_funct, expected_imm7, expected_jump_addr);
                $display("  Got      opcode=%b rs=%b rt=%b rd=%b funct=%b imm7=%b jump_addr=%h",
                         opcode, rs, rt, rd, funct, imm7, jump_addr);
                all_passed = 1'b0;
            end
        end
    endtask

    initial begin
        all_passed = 1'b1;

        // Test 1: all zeros
        run_test(1, 16'h0000);

        // Test 2: all ones
        run_test(2, 16'hFFFF);

        // Test 3: mixed pattern 1
        // instruction = 1010_011_100_101_110
        //
        // opcode    = 1010
        // rs        = 011
        // rt        = 100
        // rd        = 101
        // funct     = 110
        // imm7      = instruction[6:0]  = 0101110
        // jump_addr = instruction[11:0] = 011100101110
        run_test(3, 16'b1010_011_100_101_110);

        // Test 4: mixed pattern 2
        // instruction = 0101_110_001_011_001
        //
        // opcode    = 0101
        // rs        = 110
        // rt        = 001
        // rd        = 011
        // funct     = 001
        // imm7      = instruction[6:0]  = 1011001
        // jump_addr = instruction[11:0] = 110001011001
        run_test(4, 16'b0101_110_001_011_001);

        // Test 5: immediate-heavy lower bits
        run_test(5, 16'b0011_001_010_111_111);

        // Test 6: jump-address-oriented pattern
        run_test(6, 16'b1001_101_011_000_100);

        if (all_passed)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule
