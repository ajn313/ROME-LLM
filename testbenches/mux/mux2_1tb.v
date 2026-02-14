`timescale 1ns / 1ps

module tb_mux2_1;

    // Inputs
    reg in1;
    reg in2;
    reg select;

    // Output
    wire out;

    // Instantiate the Unit Under Test (UUT)
    mux2_1 uut (
        .in1(in1), 
        .in2(in2), 
        .select(select), 
        .out(out)
    );

    // Test cases
    integer i;
    initial begin
        // Initialize Inputs
        in1 = 0;
        in2 = 0;
        select = 0;

        // Add stimulus here
        for (i = 0; i < 4; i = i + 1) begin
            {in1, in2, select} = i;  // Apply test vectors
            #10;  // Wait 10 time units

            // Check the output and display the result
            if ((select == 0 && out == in1) || (select == 1 && out == in2)) begin
                $display("Test %d passed!", i);
            end else begin
                $display("Test %d failed!", i);
            end
        end
        
        // Additional test case: inputs are the same but select toggles
        in1 = 1; in2 = 1;
        select = 0;  // First check with select 0
        #10;
        if (out == in1) begin
            $display("Test 4 passed!");
        end else begin
            $display("Test 4 failed!");
        end
        
        select = 1;  // Now check with select 1
        #10;
        if (out == in2) begin
            $display("Test 5 passed!");
        end else begin
            $display("Test 5 failed!");
        end

        $finish;  // Terminate simulation
    end
endmodule
