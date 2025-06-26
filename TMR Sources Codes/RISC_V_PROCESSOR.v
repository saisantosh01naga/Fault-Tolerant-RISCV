`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/12/2024 04:38:48 AM
// Design Name: 
// Module Name: RISC_V_PROCESSOR
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
module RISC_V_PROCESSOR(
    input clk,
    input reset,
    input [31:0] instruction,
    input [31:0] read_data,
    output [31:0] pc,
    output [31:0] alu_result,
    output [31:0] write_data,
    output [31:0] data_addr,
    output mem_write,
    output mem_read,
    output reg_write,
    output reg unrecognized,
    output [31:0] wb_data
);
    
    // IF STAGE SIGNALS
    wire [31:0] if_pc, if_instruction;
    
    // DECODE SIGNALS
    wire [31:0] id_pc, id_instruction;
    wire [6:0] id_ex_control;
    wire [1:0] id_mem_control, id_wb_control;
    wire [31:0] id_rs1, id_rs2, id_imm;
    
    // STALLING CONTROL STAGE
    wire stall;
    
    // EXECUTE STAGE SIGNALS
    wire [2:0] ex_funct_3;
    wire [6:0] ex_funct_7;
    wire [31:0] ex_pc, ex_rs1, ex_rs2, ex_imm;
    wire [4:0] ex_rd;
    wire [6:0] ex_ex_control;
    wire [1:0] ex_mem_control, ex_wb_control;
    wire [4:0] ex_Rs1, ex_Rs2;
    wire [6:0] ex_opcode;
    wire [31:0] ex_result, ex_branch_address;
    wire ex_branch;
    
    // FORWARDING SIGNALS
    wire [1:0] forward_m1, forward_m2;
    wire [31:0] ex_input1, ex_input2;
    
    // MEMORY STAGE SIGNALS
    wire [4:0] mem_rd;
    wire [31:0] mem_branch_address;
    wire [1:0] mem_mem_control, mem_wb_control;
    wire [31:0] mem_result, mem_write_data;
    wire mem_branch;
    wire [31:0] mem_read_data;
    
    // WRITE BACK SIGNALS
    wire [4:0] wb_rd;
    wire [1:0] wb_control;
    wire [31:0] wb_result, wb_read_data;
    wire [31:0] wb_data_internal;
    
    // Additional signals
    wire id_unrecognized;
    reg ex_unrecognized, mem_unrecognized;
    
    // IF STAGE
    INSTRUCTION_FETCH if_s(
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .branch(mem_branch),
        .branch_address(mem_branch_address),
        .pc(if_pc),
        .instruction(if_instruction)
    );
    
    // IF ID PIPELINING REGISTERS
    IF_ID p1(
        .clk(clk),
        .reset(reset),
        .if_pc(if_pc),
        .if_instruction(if_instruction),
        .stall(stall),
        .branch(mem_branch),
        .id_pc(id_pc),
        .id_instruction(id_instruction)
    );
    
    // STALLING STAGE
    wire [4:0] id_s1 = id_instruction[19:15];
    wire [4:0] id_s2 = id_instruction[24:20];
    wire [6:0] id_opcode = id_instruction[6:0];
    
    STALLING_UNIT stalling_unit(
        .if_id_opcode(id_opcode),
        .id_ex_rd(ex_rd),
        .id_ex_mem_read(ex_mem_control[1]),
        .if_id_rs1(id_s1),
        .if_id_rs2(id_s2),
        .stall(stall)
    );
    
    // DECODE STAGE
    DECODE dc_s(
        .clk(clk),
        .reset(reset),
        .instruction(id_instruction),
        .wb_reg_write(wb_control[0]),
        .wb_rd(wb_rd),
        .wb_data(wb_data_internal),
        .stall(stall),
        .ex_control(id_ex_control),
        .mem_control(id_mem_control),
        .wb_control(id_wb_control),
        .rs1(id_rs1),
        .rs2(id_rs2),
        .immediate(id_imm),
        .unrecognized(id_unrecognized)
    );
    
    always @(posedge clk) begin
        ex_unrecognized <= id_unrecognized;
        mem_unrecognized <= ex_unrecognized;
        unrecognized <= mem_unrecognized;
    end
    
    // ID EX PIPELINING REGISTERS
    ID_EX p2(
        .clk(clk),
        .reset(reset),
        .branch(mem_branch),
        .id_rd(id_instruction[11:7]),
        .id_pc(id_pc),
        .id_rs1(id_rs1),
        .id_rs2(id_rs2),
        .id_immediate(id_imm),
        .id_funct_3(id_instruction[14:12]),
        .id_funct_7(id_instruction[31:25]),
        .id_ex_control(id_ex_control),
        .id_mem_control(id_mem_control),
        .id_wb_control(id_wb_control),
        .id_Rs1(id_s1),
        .id_Rs2(id_s2),
        .id_opcode(id_instruction[6:0]),
        .ex_rd(ex_rd),
        .ex_pc(ex_pc),
        .ex_rs1(ex_rs1),
        .ex_rs2(ex_rs2),
        .ex_immediate(ex_imm),
        .ex_funct_3(ex_funct_3),
        .ex_funct_7(ex_funct_7),
        .ex_ex_control(ex_ex_control),
        .ex_mem_control(ex_mem_control),
        .ex_wb_control(ex_wb_control),
        .ex_Rs1(ex_Rs1),
        .ex_Rs2(ex_Rs2),
        .ex_opcode(ex_opcode)
    );
    
    // FORWARDING UNIT
    FORWARDING_UNIT forwarding_unit(
        .ex_mem_reg_write(mem_wb_control[0]),
        .mem_wb_reg_write(wb_control[0]),
        .ex_mem_rd(mem_rd),
        .mem_wb_rd(wb_rd),
        .id_ex_rs1(ex_Rs1),
        .id_ex_rs2(ex_Rs2),
        .id_ex_opcode(ex_opcode),
        .forward_m1(forward_m1),
        .forward_m2(forward_m2)
    );
    
    // FORWARDING MUXES
    FORWARDING_MUXES m1(
        .a(ex_rs1),
        .b(mem_result),
        .c(wb_data_internal),
        .control(forward_m1),
        .result(ex_input1)
    );
    
    FORWARDING_MUXES m2(
        .a(ex_rs2),
        .b(mem_result),
        .c(wb_data_internal),
        .control(forward_m2),
        .result(ex_input2)
    );
    
    // EXECUTION UNIT
    EXECUTE_STAGE ex_s(
        .pc(ex_pc),
        .rs1(ex_input1),
        .rs2(ex_input2),
        .imm(ex_imm),
        .ex_control(ex_ex_control),
        .funct_3(ex_funct_3),
        .funct_7(ex_funct_7),
        .result(ex_result),
        .branch_address(ex_branch_address),
        .branch(ex_branch)
    );
    
    EX_MEM p3(
        .clk(clk),
        .reset(reset),
        .ex_rd(ex_rd),
        .ex_mem_control(ex_mem_control),
        .ex_wb_control(ex_wb_control),
        .ex_branch(ex_branch),
        .ex_rs2(ex_input2),
        .ex_result(ex_result),
        .ex_branch_address(ex_branch_address),
        .mem_rd(mem_rd),
        .mem_mem_control(mem_mem_control),
        .mem_wb_control(mem_wb_control),
        .mem_branch(mem_branch),
        .mem_write_data(mem_write_data),
        .mem_result(mem_result),
        .mem_branch_address(mem_branch_address)
    );
    
    MEM_STAGE mr_s(
        .clk(clk),
        .reset(reset),
        .address(mem_result),
        .mem_control(mem_mem_control),
        .write_data(mem_write_data),
        .read_data(mem_read_data)
    );
    
    MEM_WB P4(
        .clk(clk),
        .reset(reset),
        .mem_rd(mem_rd),
        .mem_wb_control(mem_wb_control),
        .mem_result(mem_result),
        .read_data(mem_read_data),
        .wb_rd(wb_rd),
        .wb_control(wb_control),
        .wb_result(wb_result),
        .wb_read_data(wb_read_data)
    );
    
    // WRITE BACK STAGE
    assign wb_data_internal = wb_control[1] ? wb_read_data : wb_result;
    
    // Output assignments
    assign pc = if_pc;
    assign alu_result = ex_result;
    assign write_data = mem_write_data;
    assign data_addr = mem_result;
    assign mem_write = mem_mem_control[0];
    assign mem_read = mem_mem_control[1];
    assign reg_write = wb_control[0];
    assign wb_data = wb_data_internal;

endmodule

