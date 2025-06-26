module tmr_risc_v_system (
    input wire clk,
    input wire rst,
    input wire [31:0] instruction,
    input wire [31:0] data_memory_read,
    output wire [31:0] final_pc,
    output wire [31:0] final_alu_result,
    output wire [31:0] final_write_data,
    output wire [31:0] final_data_addr,
    output wire final_mem_write,
    output wire final_mem_read,
    output wire error_detected,
    output wire recovery_active
);

    // Core A signals - PROPERLY DECLARED
    wire [31:0] core_a_pc, core_a_alu_result, core_a_write_data, core_a_data_addr;
    wire core_a_mem_write, core_a_mem_read, core_a_reg_write;
    wire core_a_unrecognized;
    wire [31:0] core_a_wb_data;
    
    // Core B signals - PROPERLY DECLARED
    wire [31:0] core_b_pc, core_b_alu_result, core_b_write_data, core_b_data_addr;
    wire core_b_mem_write, core_b_mem_read, core_b_reg_write;
    wire core_b_unrecognized;
    wire [31:0] core_b_wb_data;
    
    // Core C signals - PROPERLY DECLARED
    wire [31:0] core_c_pc, core_c_alu_result, core_c_write_data, core_c_data_addr;
    wire core_c_mem_write, core_c_mem_read, core_c_reg_write;
    wire core_c_unrecognized;
    wire [31:0] core_c_wb_data;
    
    // Voter signals
    wire [2:0] voter_state;
    wire [31:0] voted_alu_result, voted_write_data, voted_pc;
    wire voted_mem_write;
    
    // Control signals - PROPERLY DECLARED
    wire mux_instr_sel;
    wire [31:0] lockstep_instruction;
    wire recovery_mode, lockstep_mode;
    wire mux_data_sel, demux_sel;
    wire rollback_enable, partial_rollback, full_rollback;
    wire [31:0] recovery_read_data, recovery_pc_restore;
    
    // Input multiplexer for instruction selection
    wire [31:0] selected_instruction;
    assign selected_instruction = mux_instr_sel ? lockstep_instruction : instruction;
    
    // Instantiate three RISC-V cores with COMPLETE port connections
    RISC_V_PROCESSOR core_a (
        .clk(clk),
        .reset(rst),
        .instruction(selected_instruction),
        .read_data(data_memory_read),
        .pc(core_a_pc),
        .alu_result(core_a_alu_result),
        .write_data(core_a_write_data),
        .data_addr(core_a_data_addr),
        .mem_write(core_a_mem_write),
        .mem_read(core_a_mem_read),
        .reg_write(core_a_reg_write),
        .unrecognized(core_a_unrecognized),
        .wb_data(core_a_wb_data)
    );
    
    RISC_V_PROCESSOR core_b (
        .clk(clk),
        .reset(rst),
        .instruction(selected_instruction),
        .read_data(data_memory_read),
        .pc(core_b_pc),
        .alu_result(core_b_alu_result),
        .write_data(core_b_write_data),
        .data_addr(core_b_data_addr),
        .mem_write(core_b_mem_write),
        .mem_read(core_b_mem_read),
        .reg_write(core_b_reg_write),
        .unrecognized(core_b_unrecognized),
        .wb_data(core_b_wb_data)
    );
    
    RISC_V_PROCESSOR core_c (
        .clk(clk),
        .reset(rst),
        .instruction(selected_instruction),
        .read_data(data_memory_read),
        .pc(core_c_pc),
        .alu_result(core_c_alu_result),
        .write_data(core_c_write_data),
        .data_addr(core_c_data_addr),
        .mem_write(core_c_mem_write),
        .mem_read(core_c_mem_read),
        .reg_write(core_c_reg_write),
        .unrecognized(core_c_unrecognized),
        .wb_data(core_c_wb_data)
    );
    
    // Instantiate voter block with complete connections
    voter_block voter (
        .core_a_alu(core_a_alu_result),
        .core_b_alu(core_b_alu_result),
        .core_c_alu(core_c_alu_result),
        .core_a_pc(core_a_pc),
        .core_b_pc(core_b_pc),
        .core_c_pc(core_c_pc),
        .core_a_mem_write(core_a_mem_write),
        .core_b_mem_write(core_b_mem_write),
        .core_c_mem_write(core_c_mem_write),
        .core_a_write_data(core_a_write_data),
        .core_b_write_data(core_b_write_data),
        .core_c_write_data(core_c_write_data),
        .voter_state(voter_state),
        .voted_alu_result(voted_alu_result),
        .voted_pc(voted_pc),
        .voted_mem_write(voted_mem_write),
        .voted_write_data(voted_write_data)
    );
    
    // Instantiate lockstep controller
    lockstep_controller lockstep_ctrl (
        .clk(clk),
        .rst(rst),
        .voter_state(voter_state),
        .voted_data(voted_alu_result),
        .recovery_mode(recovery_mode),
        .lockstep_mode(lockstep_mode),
        .mux_data_sel(mux_data_sel),
        .mux_instr_sel(mux_instr_sel),
        .demux_sel(demux_sel),
        .lockstep_instruction(lockstep_instruction),
        .rollback_enable(rollback_enable),
        .partial_rollback(partial_rollback),
        .full_rollback(full_rollback)
    );
    
    // Instantiate recovery register
    recovery_register recovery_reg (
        .clk(clk),
        .rst(rst),
        .write_enable(lockstep_mode | partial_rollback),
        .read_enable(full_rollback),
        .addr(5'b00001),
        .write_data(voted_alu_result),
        .read_data(recovery_read_data),
        .pc_backup(voted_pc),
        .pc_write_enable(lockstep_mode),
        .pc_restore(recovery_pc_restore)
    );
    
    // Output assignments
    assign final_pc = voted_pc;
    assign final_alu_result = voted_alu_result;
    assign final_write_data = voted_write_data;
    assign final_data_addr = voted_alu_result;
    assign final_mem_write = voted_mem_write;
    assign final_mem_read = core_a_mem_read;
    assign error_detected = (voter_state != 3'b111);
    assign recovery_active = recovery_mode;
endmodule
