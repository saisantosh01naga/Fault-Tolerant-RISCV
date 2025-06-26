module recovery_register (
    input wire clk,
    input wire rst,
    input wire write_enable,
    input wire read_enable,
    input wire [4:0] addr,
    input wire [31:0] write_data,
    output wire [31:0] read_data,
    input wire [31:0] pc_backup,
    input wire pc_write_enable,
    output wire [31:0] pc_restore
);
    // Recovery register file (32 registers)
    reg [31:0] recovery_registers [31:0];
    
    // PC backup register
    reg [31:0] pc_backup_reg;
    
    // Additional control registers
    reg [31:0] control_state_backup; //why is this needed
    reg [31:0] alu_flags_backup;
    
    integer i;  // Declare integer outside always block
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                recovery_registers[i] <= 32'b0;
            end
            pc_backup_reg <= 32'b0;
            control_state_backup <= 32'b0;
            alu_flags_backup <= 32'b0;
        end else begin
            if (write_enable && addr != 5'b0) begin
                recovery_registers[addr] <= write_data;
            end
            
            if (pc_write_enable) begin
                pc_backup_reg <= pc_backup;
            end
        end
    end
    
    assign read_data = (read_enable) ? recovery_registers[addr] : 32'b0;
    assign pc_restore = pc_backup_reg;
endmodule
