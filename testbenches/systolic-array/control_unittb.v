`timescale 1ns / 1ps

module control_unit_tb;

  reg clk;
  reg rst;
  reg start;

  wire en;
  wire done;
  wire load_inputs;
  wire capture_outputs;
  wire [3:0] cycle_count;

  integer failures;
  reg seen_en;
  reg seen_load_inputs;
  reg seen_capture_outputs;
  reg seen_done;

  control_unit uut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .en(en),
    .done(done),
    .load_inputs(load_inputs),
    .capture_outputs(capture_outputs),
    .cycle_count(cycle_count)
  );

  always #5 clk = ~clk;

  task check_reset_state;
    input integer test_num;
    begin
      if ((en === 1'b0) &&
          (done === 1'b0) &&
          (load_inputs === 1'b0) &&
          (capture_outputs === 1'b0) &&
          (cycle_count === 4'd0)) begin
        $display("Test %0d passed", test_num);
      end else begin
        $display("Test %0d failed", test_num);
        $display("  Expected reset state: en=0 done=0 load_inputs=0 capture_outputs=0 cycle_count=0");
        $display("  Actual: en=%b done=%b load_inputs=%b capture_outputs=%b cycle_count=%0d",
                 en, done, load_inputs, capture_outputs, cycle_count);
        failures = failures + 1;
      end
    end
  endtask

  task check_started_activity;
    input integer test_num;
    begin
      if (seen_load_inputs && seen_en) begin
        $display("Test %0d passed", test_num);
      end else begin
        $display("Test %0d failed", test_num);
        $display("  Expected controller to assert load_inputs and en after start");
        failures = failures + 1;
      end
    end
  endtask

  task check_counter_progress;
    input integer test_num;
    input [3:0] previous_count;
    begin
      if (cycle_count > previous_count) begin
        $display("Test %0d passed", test_num);
      end else begin
        $display("Test %0d failed", test_num);
        $display("  Expected cycle_count to increase");
        $display("  Previous=%0d Current=%0d", previous_count, cycle_count);
        failures = failures + 1;
      end
    end
  endtask

  task check_completion_seen;
    input integer test_num;
    begin
      if (seen_capture_outputs && seen_done) begin
        $display("Test %0d passed", test_num);
      end else begin
        $display("Test %0d failed", test_num);
        $display("  Expected controller to eventually assert capture_outputs and done");
        failures = failures + 1;
      end
    end
  endtask

  initial begin
    failures = 0;
    clk = 0;
    rst = 0;
    start = 0;
    seen_en = 0;
    seen_load_inputs = 0;
    seen_capture_outputs = 0;
    seen_done = 0;

    // Test 1: Reset clears controller state
    rst = 1;
    @(posedge clk);
    #1;
    check_reset_state(1);

    // Release reset
    rst = 0;

    // Test 2: Idle state remains inactive without start
    repeat (2) @(posedge clk);
    #1;
    if ((en === 1'b0) && (done === 1'b0) && (cycle_count === 4'd0)) begin
      $display("Test 2 passed");
    end else begin
      $display("Test 2 failed");
      $display("  Expected idle controller before start");
      failures = failures + 1;
    end

    // Issue a one-cycle start pulse
    start = 1;
    @(posedge clk);
    #1;
    start = 0;

    // Observe activity for several cycles
    repeat (10) begin
      @(posedge clk);
      #1;
      if (en === 1'b1)
        seen_en = 1;
      if (load_inputs === 1'b1)
        seen_load_inputs = 1;
      if (capture_outputs === 1'b1)
        seen_capture_outputs = 1;
      if (done === 1'b1)
        seen_done = 1;
    end

    // Test 3: Start should trigger load/enable activity
    check_started_activity(3);

    // Test 4: Counter should have progressed during operation
    check_counter_progress(4, 4'd0);

    // Continue observing for completion
    repeat (10) begin
      @(posedge clk);
      #1;
      if (en === 1'b1)
        seen_en = 1;
      if (load_inputs === 1'b1)
        seen_load_inputs = 1;
      if (capture_outputs === 1'b1)
        seen_capture_outputs = 1;
      if (done === 1'b1)
        seen_done = 1;
    end

    // Test 5: Controller should eventually capture outputs and assert done
    check_completion_seen(5);

    // Test 6: Reset after completion should clear everything again
    rst = 1;
    @(posedge clk);
    #1;
    check_reset_state(6);

    if (failures == 0)
      $display("All tests passed!");
    else
      $display("Some tests failed");

    $finish;
  end

endmodule