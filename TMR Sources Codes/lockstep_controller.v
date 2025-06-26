module lockstep_controller (
    input wire clk,
    input wire rst,
    input wire [2:0] voter_state,
    input wire [31:0] voted_data,
    output reg recovery_mode,
    output reg lockstep_mode,
    output reg mux_data_sel,
    output reg mux_instr_sel,
    output reg demux_sel,
    output reg [31:0] lockstep_instruction,
    output reg rollback_enable,
    output reg partial_rollback,
    output reg full_rollback
);

    // State encoding using parameters (Verilog-compatible)
    parameter IDLE = 3'd0;
    parameter NORMAL_EXEC = 3'd1;
    parameter LOCKSTEP_PHASE = 3'd2;
    parameter PARTIAL_ROLLBACK_PHASE = 3'd3;
    parameter FULL_ROLLBACK_PHASE = 3'd4;

    reg [2:0] current_state, next_state;

    // Hardcoded instructions
    parameter STORE_INSTR = 32'h00A02023;  // sw x10, 0(x0)
    parameter LOAD_INSTR  = 32'h00002503;   // lw x10, 0(x0)
    parameter NOP_INSTR   = 32'h00000013;   // nop
    
    reg [31:0] voted_reg;

    // State register
    always @(posedge clk or posedge rst) begin
        if (rst) current_state <= IDLE;
        else current_state <= next_state;
    end

    // Next state logic
    always @(*) begin
        next_state = current_state;
        case (current_state)
            IDLE: next_state = NORMAL_EXEC;
            
            NORMAL_EXEC: begin
                case (voter_state)
                    3'b111: next_state = LOCKSTEP_PHASE;
                    3'b100, 3'b010, 3'b001: next_state = PARTIAL_ROLLBACK_PHASE;
                    3'b000: next_state = FULL_ROLLBACK_PHASE;
                    default: next_state = NORMAL_EXEC;
                endcase
            end
            
            LOCKSTEP_PHASE: next_state = NORMAL_EXEC;
            PARTIAL_ROLLBACK_PHASE: next_state = NORMAL_EXEC;
            FULL_ROLLBACK_PHASE: next_state = NORMAL_EXEC;
        endcase
    end

    // Output logic
    always @(*) begin
        // Default assignments
        recovery_mode = 0;
        lockstep_mode = 0;
        mux_data_sel = 0;
        mux_instr_sel = 0;
        demux_sel = 0;
        lockstep_instruction = NOP_INSTR;
        rollback_enable = 0;
        partial_rollback = 0;
        full_rollback = 0;
        voted_reg = voted_data;

        case (current_state)
            LOCKSTEP_PHASE: begin
                lockstep_mode = 1;
                mux_instr_sel = 1;
                demux_sel = 1;
                lockstep_instruction = STORE_INSTR;
            end
            
            PARTIAL_ROLLBACK_PHASE: begin
                recovery_mode = 1;
                partial_rollback = 1;
                rollback_enable = 1;
                mux_instr_sel = 1;
                lockstep_instruction = STORE_INSTR;
            end
            
            FULL_ROLLBACK_PHASE: begin
                recovery_mode = 1;
                full_rollback = 1;
                rollback_enable = 1;
                mux_data_sel = 1;
                mux_instr_sel = 1;
                lockstep_instruction = LOAD_INSTR;
                voted_reg = 0;
            end
        endcase
    end
endmodule
