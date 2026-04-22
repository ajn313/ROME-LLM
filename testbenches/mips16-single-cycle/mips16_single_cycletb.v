`timescale 1ns / 1ps

module mips16_single_cycle_tb;

    reg clk;
    reg reset;

    reg all_passed;

    MIPS16_SingleCycle uut (
        .clk(clk),
        .reset(reset)
    );

    function [15:0] encode_r;
        input [2:0] rs;
        input [2:0] rt;
        input [2:0] rd;
        input [2:0] funct;
        begin
            encode_r = 16'h0000;
            encode_r[15:12] = 4'b0000;
            encode_r[11:9]  = rs;
            encode_r[8:6]   = rt;
            encode_r[5:3]   = rd;
            encode_r[2:0]   = funct;
        end
    endfunction

    function [15:0] encode_i;
        input [3:0] opcode;
        input [2:0] rs;
        input [2:0] rt;
        input [6:0] imm7;
        begin
            encode_i = 16'h0000;
            encode_i[15:12] = opcode;
            encode_i[11:9]  = rs;
            encode_i[8:6]   = rt;
            encode_i[6:0]   = imm7;
        end
    endfunction

    function [15:0] encode_j;
        input [11:0] jump_addr;
        begin
            encode_j = 16'h0000;
            encode_j[15:12] = 4'b0101;
            encode_j[11:0]  = jump_addr;
        end
    endfunction

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        all_passed = 1'b1;

        reset = 1'b1;

        // Program:
        // 0: addi r2, r0, 2
        // 1: addi r4, r0, 3
        // 2: add  r6, r2, r4
        // 3: sw   r6, 0(r0)
        // 4: lw   r2, 0(r0)
        // 5: beq  r2, r6, +1
        // 6: addi r4, r0, 0    // should be skipped
        // 7: j    9
        // 8: addi r4, r0, 2    // should be skipped
        // 9: sub  r1, r6, r4

        uut.instruction_memory_inst.memory[0] = encode_i(4'b0001, 3'b000, 3'b010, 7'b0000010);
        uut.instruction_memory_inst.memory[1] = encode_i(4'b0001, 3'b000, 3'b100, 7'b0000011);
        uut.instruction_memory_inst.memory[2] = encode_r(3'b010, 3'b100, 3'b110, 3'b000);
        uut.instruction_memory_inst.memory[3] = encode_i(4'b0011, 3'b000, 3'b110, 7'b0000000);
        uut.instruction_memory_inst.memory[4] = encode_i(4'b0010, 3'b000, 3'b010, 7'b0000000);
        uut.instruction_memory_inst.memory[5] = encode_i(4'b0100, 3'b010, 3'b110, 7'b0000001);
        uut.instruction_memory_inst.memory[6] = encode_i(4'b0001, 3'b000, 3'b100, 7'b0000000);
        uut.instruction_memory_inst.memory[7] = encode_j(12'd9);
        uut.instruction_memory_inst.memory[8] = encode_i(4'b0001, 3'b000, 3'b100, 7'b0000010);
        uut.instruction_memory_inst.memory[9] = encode_r(3'b110, 3'b100, 3'b001, 3'b001);

        uut.data_memory_inst.memory[0] = 16'h0000;

        @(posedge clk);
        #1;

        // Test 1: Reset puts PC at 0 and clears register file state
        if ((uut.program_counter_inst.pc_current === 16'h0000) &&
            (uut.register_file_inst.registers[1] === 16'h0000) &&
            (uut.register_file_inst.registers[2] === 16'h0000) &&
            (uut.register_file_inst.registers[4] === 16'h0000) &&
            (uut.register_file_inst.registers[6] === 16'h0000))
            $display("Test 1 passed");
        else begin
            $display("Test 1 failed");
            $display("  Expected PC=0000 and selected registers cleared");
            $display("  Got PC=%h r1=%h r2=%h r4=%h r6=%h",
                     uut.program_counter_inst.pc_current,
                     uut.register_file_inst.registers[1],
                     uut.register_file_inst.registers[2],
                     uut.register_file_inst.registers[4],
                     uut.register_file_inst.registers[6]);
            all_passed = 1'b0;
        end

        reset = 1'b0;

        // Execute instruction 0
        @(posedge clk);
        #1;
        if ((uut.program_counter_inst.pc_current === 16'h0001) &&
            (uut.register_file_inst.registers[2] === 16'h0002))
            $display("Test 2 passed");
        else begin
            $display("Test 2 failed");
            $display("  Expected PC=0001, r2=0002");
            $display("  Got PC=%h, r2=%h",
                     uut.program_counter_inst.pc_current,
                     uut.register_file_inst.registers[2]);
            all_passed = 1'b0;
        end

        // Execute instruction 1
        @(posedge clk);
        #1;
        if ((uut.program_counter_inst.pc_current === 16'h0002) &&
            (uut.register_file_inst.registers[4] === 16'h0003))
            $display("Test 3 passed");
        else begin
            $display("Test 3 failed");
            $display("  Expected PC=0002, r4=0003");
            $display("  Got PC=%h, r4=%h",
                     uut.program_counter_inst.pc_current,
                     uut.register_file_inst.registers[4]);
            all_passed = 1'b0;
        end

        // Execute instruction 2
        @(posedge clk);
        #1;
        if ((uut.program_counter_inst.pc_current === 16'h0003) &&
            (uut.register_file_inst.registers[6] === 16'h0005))
            $display("Test 4 passed");
        else begin
            $display("Test 4 failed");
            $display("  Expected PC=0003, r6=0005");
            $display("  Got PC=%h, r6=%h",
                     uut.program_counter_inst.pc_current,
                     uut.register_file_inst.registers[6]);
            all_passed = 1'b0;
        end

        // Execute instruction 3
        @(posedge clk);
        #1;
        if ((uut.program_counter_inst.pc_current === 16'h0004) &&
            (uut.data_memory_inst.memory[0] === 16'h0005))
            $display("Test 5 passed");
        else begin
            $display("Test 5 failed");
            $display("  Expected PC=0004, mem[0]=0005");
            $display("  Got PC=%h, mem[0]=%h",
                     uut.program_counter_inst.pc_current,
                     uut.data_memory_inst.memory[0]);
            all_passed = 1'b0;
        end

        // Execute instruction 4
        @(posedge clk);
        #1;
        if ((uut.program_counter_inst.pc_current === 16'h0005) &&
            (uut.register_file_inst.registers[2] === 16'h0005))
            $display("Test 6 passed");
        else begin
            $display("Test 6 failed");
            $display("  Expected PC=0005, r2=0005");
            $display("  Got PC=%h, r2=%h",
                     uut.program_counter_inst.pc_current,
                     uut.register_file_inst.registers[2]);
            all_passed = 1'b0;
        end

        // Execute instruction 5: branch should be taken to address 7
        @(posedge clk);
        #1;
        if ((uut.program_counter_inst.pc_current === 16'h0007) &&
            (uut.register_file_inst.registers[4] === 16'h0003))
            $display("Test 7 passed");
        else begin
            $display("Test 7 failed");
            $display("  Expected PC=0007 and r4 unchanged at 0003");
            $display("  Got PC=%h, r4=%h",
                     uut.program_counter_inst.pc_current,
                     uut.register_file_inst.registers[4]);
            all_passed = 1'b0;
        end

        // Execute instruction 7: jump should go to address 9
        @(posedge clk);
        #1;
        if ((uut.program_counter_inst.pc_current === 16'h0009) &&
            (uut.register_file_inst.registers[4] === 16'h0003))
            $display("Test 8 passed");
        else begin
            $display("Test 8 failed");
            $display("  Expected PC=0009 and r4 still 0003");
            $display("  Got PC=%h, r4=%h",
                     uut.program_counter_inst.pc_current,
                     uut.register_file_inst.registers[4]);
            all_passed = 1'b0;
        end

        // Execute instruction 9
        @(posedge clk);
        #1;
        if ((uut.program_counter_inst.pc_current === 16'h000A) &&
            (uut.register_file_inst.registers[1] === 16'h0002))
            $display("Test 9 passed");
        else begin
            $display("Test 9 failed");
            $display("  Expected PC=000A, r1=0002");
            $display("  Got PC=%h, r1=%h",
                     uut.program_counter_inst.pc_current,
                     uut.register_file_inst.registers[1]);
            all_passed = 1'b0;
        end

        if (all_passed)
            $display("All tests passed!");
        else
            $display("Some tests failed");

        $finish;
    end

endmodule