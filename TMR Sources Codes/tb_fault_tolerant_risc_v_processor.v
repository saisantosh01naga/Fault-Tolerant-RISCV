`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.06.2025 18:37:14
// Design Name: 
// Module Name: tb_fault_tolerant_risc_v_processor
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_fault_tolerant_risc_v_processor;


  // Clock & reset
  reg clk;
  reg reset;

  // Error injection control
  reg inject_error;
  reg [1:0] error_type;
  reg [5:0] error_position;

  // DUT outputs
  wire [31:0] pc_out;
  wire [31:0] data_memory_addr;
  wire        data_memory_write_enable;
  wire        error_detected;
  wire        recovery_active;
  wire        single_error_corrected;
  wire        double_error_detected;

  // Instantiate DUT
  fault_tolerant_risc_v_processor dut (
    .clk                   (clk),
    .reset                 (reset),
    .inject_error          (inject_error),
    .error_type            (error_type),
    .error_position        (error_position),
    .pc_out                (pc_out),
    .data_memory_addr      (data_memory_addr),
    .data_memory_write_enable(data_memory_write_enable),
    .instruction_addr      (),                // unused for this bench
    .error_detected        (error_detected),
    .recovery_active       (recovery_active),
    .single_error_corrected(single_error_corrected),
    .double_error_detected (double_error_detected)
  );

  // Clock generation: 100 MHz
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Reset and test sequence
  initial begin
    // VCD dump
    $dumpfile("tb_fault_tolerant_risc_v.vcd");
    $dumpvars(0, tb_fault_tolerant_risc_v_processor);

    // Initial conditions
    reset         = 1;
    inject_error  = 0;
    error_type    = 2'b00;
    error_position= 6'd0;

    // Hold reset for 3 cycles
    repeat (3) @(posedge clk);
    reset = 0;
    $display("[%0t] Reset deasserted", $time);

    // Wait two cycles before starting tests
    repeat (2) @(posedge clk);

    // Test 1: Normal operation
    $display("[%0t] Test 1: No error injection", $time);
    monitor_signals;  // capture baseline

    // Test 2: Single-bit error
    $display("[%0t] Test 2: Single-bit error at pos 5", $time);
    apply_error(2'b01, 6'd5);
    monitor_signals;

    // Test 3: Double-bit error
    $display("[%0t] Test 3: Double-bit error at pos 10", $time);
    apply_error(2'b10, 6'd10);
    monitor_signals;

    // Test 4: Random error scenarios
    repeat (3) begin
      @(posedge clk);
      apply_error($urandom_range(0,2), $urandom_range(0,31));
      monitor_signals;
    end

    // Test 5: Recovery activation
    $display("[%0t] Test 5: Trigger recovery", $time);
    apply_error(2'b01, 6'd15);
    wait (recovery_active);
    $display("[%0t] Recovery started", $time);
    wait (!recovery_active);
    $display("[%0t] Recovery completed", $time);

    $finish;
  end

  // Task: inject and clear error on next posedge
  task apply_error(input [1:0] etype, input [5:0] epos);
    begin
      @(posedge clk);
      inject_error   <= 1;
      error_type     <= etype;
      error_position <= epos;
      @(posedge clk);
      inject_error   <= 0;
    end
  endtask

  // Task: display key signals
  task monitor_signals;
    begin
      $display("[%0t] PC=%0h  ErrDet=%b  RecAct=%b  SEC=%b  DEC=%b  Addr=%0h  WE=%b",
               $time, pc_out,
               error_detected, recovery_active,
               single_error_corrected, double_error_detected,
               data_memory_addr, data_memory_write_enable);
    end
  endtask

  // Assertions: PC must advance when no error/recovery
  always @(posedge clk) begin
    if (!reset && !error_detected && !recovery_active) begin
      // Ensure PC increments by 4 each cycle
      // ($past is a SystemVerilog function; adjust as needed in your simulator)
      `ifdef SV
        assert(pc_out - $past(pc_out) == 32'd4)
          else $error("[%0t] PC did not advance by 4", $time);
      `endif
    end
  end

  // Timeout protection
  initial begin
    #20000;
    $display("[%0t] Simulation timed out", $time);
    $finish;
  end

endmodule

 /*   // Test bench signals
    reg clk;
    reg reset;
    reg inject_error;
    reg [1:0] error_type;
    reg [5:0] error_position;
    
    wire [31:0] pc_out;
    wire [31:0] data_memory_addr;
    wire [31:0] data_memory_write_data;
    wire data_memory_write_enable;
    wire [31:0] instruction_addr;
    wire error_detected;
    wire recovery_active;
    wire single_error_corrected;
    wire double_error_detected;

    // Instantiate the DUT (Device Under Test)
    fault_tolerant_risc_v_processor dut (
        .clk(clk),
        .reset(reset),
        .inject_error(inject_error),
        .error_type(error_type),
        .error_position(error_position),
        .pc_out(pc_out),
        .data_memory_addr(data_memory_addr),
        .data_memory_write_data(data_memory_write_data),
        .data_memory_write_enable(data_memory_write_enable),
        .instruction_addr(instruction_addr),
        .error_detected(error_detected),
        .recovery_active(recovery_active),
        .single_error_corrected(single_error_corrected),
        .double_error_detected(double_error_detected)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // Test scenarios
    initial begin
        // Initialize signals
        reset = 1;
        inject_error = 0;
        error_type = 2'b00;
        error_position = 6'b000000;
        
        // Create VCD file for waveform analysis
        $dumpfile("fault_tolerant_risc_v.vcd");
        $dumpvars(0, tb_fault_tolerant_risc_v_processor);
        
        // Reset sequence
        #20;
        reset = 0;
        $display("Reset released at time %0t", $time);
        
        // Test 1: Normal operation (no errors)
        #100;
        $display("Test 1: Normal operation");
        monitor_signals();
        
        // Test 2: Single-bit error injection
        #50;
        $display("Test 2: Single-bit error injection");
        inject_error = 1;
        error_type = 2'b01;
        error_position = 6'd5;
        #10;
        inject_error = 0;
        #100;
        monitor_signals();
        
        // Test 3: Double-bit error injection
        #50;
        $display("Test 3: Double-bit error injection");
        inject_error = 1;
        error_type = 2'b10;
        error_position = 6'd10;
        #10;
        inject_error = 0;
        #100;
        monitor_signals();
        
        // Test 4: Multiple error scenarios
        repeat(5) begin
            #50;
            inject_error = 1;
            error_type = $random % 3;
            error_position = $random % 32;
            #10;
            inject_error = 0;
            #50;
            monitor_signals();
        end
        
        // Test 5: Recovery mechanism testing
        #100;
        $display("Test 5: Recovery mechanism testing");
        test_recovery_mechanism();
        
        #200;
        $display("All tests completed at time %0t", $time);
        $finish;
    end

    // Monitor task for signal observation
    task monitor_signals;
        begin
            $display("Time: %0t", $time);
            $display("  PC: 0x%08h", pc_out);
            $display("  Error Detected: %b", error_detected);
            $display("  Recovery Active: %b", recovery_active);
            $display("  Single Error Corrected: %b", single_error_corrected);
            $display("  Double Error Detected: %b", double_error_detected);
            $display("  Memory Address: 0x%08h", data_memory_addr);
            $display("  Memory Write Enable: %b", data_memory_write_enable);
            $display("  ----------------------------------------");
        end
    endtask

    // Recovery mechanism testing task
    task test_recovery_mechanism;
        begin
            // Inject multiple errors to trigger recovery
            inject_error = 1;
            error_type = 2'b01;
            error_position = 6'd15;
            #10;
            inject_error = 0;
            
            // Wait for recovery to complete
            wait(recovery_active);
            $display("Recovery mechanism activated at time %0t", $time);
            
            wait(!recovery_active);
            $display("Recovery mechanism completed at time %0t", $time);
        end
    endtask

    // Assertion-based verification
    always @(posedge clk) begin
        // Check that PC increments properly during normal operation
        if (!reset && !error_detected && !recovery_active) begin
            // Add assertions for normal operation
        end
        
        // Check error detection logic
        if (single_error_corrected) begin
            $display("Single error corrected at time %0t", $time);
        end
        
        if (double_error_detected) begin
            $display("Double error detected at time %0t", $time);
        end
    end

    // Timeout mechanism
    initial begin
        #50000; // 50 microseconds timeout
        $display("Simulation timeout");
        $finish;
    end

endmodule*/
