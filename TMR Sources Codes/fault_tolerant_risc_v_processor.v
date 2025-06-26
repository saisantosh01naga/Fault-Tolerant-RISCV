`timescale 1ns/1ps

module fault_tolerant_risc_v_processor(
  input  wire        clk,
  input  wire        reset,
  input  wire        inject_error,
  input  wire [1:0]  error_type,
  input  wire [5:0]  error_position,
  output wire [31:0] pc_out,
  output wire [31:0] data_memory_addr,
  output wire [31:0] data_memory_write_data,
  output wire        data_memory_write_enable,
  output wire [31:0] instruction_addr,
  output wire        error_detected,
  output wire        recovery_active,
  output wire        single_error_corrected,
  output wire        double_error_detected,
  output wire        multiple_error_detected
);

  // Wires for TMR and MDMHC
  wire [31:0] tmr_write_data, tmr_data_addr, corrected_data;
  wire        tmr_mem_write, tmr_mem_read;
  wire [31:0] error_injected;
  wire        tmr_error_detected;  // Added for TMR error detection
  
  // MDMHC Encoder
  wire [67:0] encoded_data;
  mdmhc_encoder encoder_inst (
      .clk(clk),
      .in(tmr_write_data),      // Corrected port name
      .out(encoded_data)        // Corrected port name
  );

  // Error injection into ENCODED data
  wire [67:0] encoded_data_with_errors;  // Only one declaration
  reg [67:0] error_mask_encoded;

  // Generate error mask for encoded data
reg [67:0] error_mask_latched;
reg [2:0] error_inject_counter;

always @(posedge clk) begin
    if (reset) begin
        error_mask_encoded <= 68'h0;
        error_mask_latched <= 68'h0;
        error_inject_counter <= 3'd0;
    end else begin
        // Latch the error mask when inject_error goes high
        if (inject_error && error_inject_counter == 3'd0) begin
            error_inject_counter <= 3'd5; // Hold error for 5 cycles
            
            case (error_type)
                2'b01: begin // Single bit error
                    if (error_position < 68) begin
                        error_mask_latched <= 68'h0;
                        error_mask_latched[error_position] <= 1'b1;
                    end
                end
                
                2'b10: begin // Double bit error
                    if (error_position < 67) begin
                        error_mask_latched <= 68'h0;
                        error_mask_latched[error_position] <= 1'b1;
                        error_mask_latched[error_position + 1] <= 1'b1;
                    end
                end
                
                2'b11: begin // Random errors
                    error_mask_latched <= {$random, $random} & 68'h0FFFFFFFFFFFFFFFF;
                end
                
                default: error_mask_latched <= 68'h0;
            endcase
        end
        
        // Count down and clear when done
        if (error_inject_counter > 0) begin
            error_inject_counter <= error_inject_counter - 1;
            error_mask_encoded <= error_mask_latched;
        end else begin
            error_mask_encoded <= 68'h0;
        end
    end
end

  // Apply error mask to encoded data
  assign encoded_data_with_errors = encoded_data ^ error_mask_encoded;

  // MDMHC Decoder with error detection
  wire mdmhc_single_error_corrected;
  wire mdmhc_double_error_detected;
  wire mdmhc_multiple_error_detected;

  mdmhc_decoder_wrapper decoder_wrapper_inst (
      .clk(clk),
      .reset(reset),
      .encoded_data_in(encoded_data_with_errors),
      .decoded_data_out(corrected_data),
      .single_error_corrected(mdmhc_single_error_corrected),
      .double_error_detected(mdmhc_double_error_detected),
      .multiple_error_detected(mdmhc_multiple_error_detected)
  );
  
  // TMR lockstep system
  tmr_risc_v_system tmr_sys (
    .clk(clk), 
    .rst(reset),
    .instruction(corrected_data),
    .data_memory_read(),  // internal to TMR
    .final_pc(pc_out),
    .final_write_data(tmr_write_data),
    .final_data_addr(tmr_data_addr),
    .final_mem_write(tmr_mem_write),
    .final_mem_read(tmr_mem_read),
    .error_detected(tmr_error_detected),  // Use separate wire
    .recovery_active(recovery_active)
  );

  // Data memory with recovery mux/demux
  data_memory_system mem_sys (
    .clk(clk), 
    .rst(reset),
    .addr(tmr_data_addr),
    .write_data(tmr_write_data),
    .mem_write(tmr_mem_write),
    .mem_read(tmr_mem_read),
    .mux_data_sel(), 
    .demux_sel(),
    .recovery_data(), 
    .read_data(),
    .recovery_read_data()
  );

  // Output assignments
  assign instruction_addr         = pc_out;
  assign data_memory_addr         = tmr_data_addr;
  assign data_memory_write_data   = tmr_write_data;
  assign data_memory_write_enable = tmr_mem_write;
  
  // Connect MDMHC error detection outputs to top-level outputs
  assign single_error_corrected   = mdmhc_single_error_corrected;
  assign double_error_detected    = mdmhc_double_error_detected;
  assign multiple_error_detected  = mdmhc_multiple_error_detected;
  
  // Combined error detection from both TMR and MDMHC
  reg error_detected_reg;
  always @(posedge clk) begin
      if (reset) begin
          error_detected_reg <= 1'b0;
      end else begin
          error_detected_reg <= tmr_error_detected |         // TMR errors
                               mdmhc_single_error_corrected | // MDMHC errors
                               mdmhc_double_error_detected | 
                               mdmhc_multiple_error_detected;
      end
  end
  
  // Assign the registered error detection to output
  assign error_detected = error_detected_reg;

endmodule

/*module fault_tolerant_risc_v_processor(
    input clk,
    input reset,
    input inject_error,
    input [1:0] error_type,
    input [5:0] error_position,
    output [31:0] pc_out,
    output [31:0] data_memory_addr,
    output [31:0] data_memory_write_data,
    output data_memory_write_enable,
    output [31:0] instruction_addr,
    output error_detected,
    output recovery_active,
    output single_error_corrected,
    output double_error_detected
);

    // Internal signals
    wire [31:0] tmr_read_data, tmr_alu_result, tmr_write_data, tmr_data_addr;
    wire tmr_mem_write, tmr_mem_read;
    wire [31:0] error_injected_data;
    wire [38:0] encoded_data;
    wire [31:0] corrected_data;
    wire mux_data_sel, demux_sel;
    wire [31:0] recovery_data, recovery_read_data;
    
    // Error injection
    error_injection error_inject (
        .clk(clk),
        .rst(reset),
        .inject_enable(inject_error),
        .error_type(error_type),
        .error_position(error_position),
        .data_in(tmr_write_data),
        .data_out(error_injected_data)
    );
    
    // SECDED encoding
    secded_encoder encoder (
        .data_in(error_injected_data),
        .encoded_data(encoded_data)
    );
    
    // SECDED decoding
    secded_decoder decoder (
        .encoded_data(encoded_data),
        .corrected_data(corrected_data),
        .single_error_detected(single_error_corrected),
        .double_error_detected(double_error_detected),
        .no_error()
    );
    
    // TMR RISC-V system
    tmr_risc_v_system tmr_system (
        .clk(clk),
        .rst(reset),
        .instruction(corrected_data),  // SECDED protected instructions
        .data_memory_read(tmr_read_data),
        .final_pc(pc_out),
        .final_alu_result(tmr_alu_result),
        .final_write_data(tmr_write_data),
        .final_data_addr(tmr_data_addr),
        .final_mem_write(tmr_mem_write),
        .final_mem_read(tmr_mem_read),
        .error_detected(error_detected),
        .recovery_active(recovery_active)
    );
    
    // Data memory system
    data_memory_system data_mem_sys (
        .clk(clk),
        .rst(reset),
        .addr(tmr_data_addr),
        .write_data(corrected_data),
        .mem_write(tmr_mem_write),
        .mem_read(tmr_mem_read),
        .mux_data_sel(mux_data_sel),
        .demux_sel(demux_sel),
        .recovery_data(recovery_data),
        .read_data(tmr_read_data),
        .recovery_read_data(recovery_read_data)
    );
    
    // Output assignments
    assign instruction_addr = pc_out;
    assign data_memory_addr = tmr_data_addr;
    assign data_memory_write_data = corrected_data;
    assign data_memory_write_enable = tmr_mem_write;
endmodule*/
