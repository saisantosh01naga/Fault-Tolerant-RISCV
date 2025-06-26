`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.06.2025 22:52:09
// Design Name: 
// Module Name: voter_block
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


module voter_block(
    input [31:0] core_a_alu, core_b_alu, core_c_alu,
    input [31:0] core_a_pc, core_b_pc, core_c_pc,
    input core_a_mem_write, core_b_mem_write, core_c_mem_write,
    input [31:0] core_a_write_data, core_b_write_data, core_c_write_data,
    output reg [2:0] voter_state,
    output reg [31:0] voted_alu_result,
    output reg [31:0] voted_pc,
    output reg voted_mem_write,
    output reg [31:0] voted_write_data
);
    
    always @(*) begin
        // Default values
        voter_state = 3'b000;
        voted_alu_result = core_a_alu;
        voted_pc = core_a_pc;
        voted_mem_write = core_a_mem_write;
        voted_write_data = core_a_write_data;
        
        // Compare cores A and B
        if ((core_a_alu == core_b_alu) && (core_a_pc == core_b_pc) && 
            (core_a_mem_write == core_b_mem_write) && (core_a_write_data == core_b_write_data)) begin
            voter_state[0] = 1'b1;
            voted_alu_result = core_a_alu;
            voted_pc = core_a_pc;
            voted_mem_write = core_a_mem_write;
            voted_write_data = core_a_write_data;
        end
        
        // Compare cores B and C
        if ((core_b_alu == core_c_alu) && (core_b_pc == core_c_pc) && 
            (core_b_mem_write == core_c_mem_write) && (core_b_write_data == core_c_write_data)) begin
            voter_state[1] = 1'b1;
            voted_alu_result = core_b_alu;
            voted_pc = core_b_pc;
            voted_mem_write = core_b_mem_write;
            voted_write_data = core_b_write_data;
        end
        
        // Compare cores A and C
        if ((core_a_alu == core_c_alu) && (core_a_pc == core_c_pc) && 
            (core_a_mem_write == core_c_mem_write) && (core_a_write_data == core_c_write_data)) begin
            voter_state[2] = 1'b1;
            voted_alu_result = core_a_alu;
            voted_pc = core_a_pc;
            voted_mem_write = core_a_mem_write;
            voted_write_data = core_a_write_data;
        end
    end
endmodule

