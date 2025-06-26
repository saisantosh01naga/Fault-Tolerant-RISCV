module data_memory_system (
    input wire clk,
    input wire rst,
    input wire [31:0] addr,
    input wire [31:0] write_data,
    input wire mem_write,
    input wire mem_read,
    input wire mux_data_sel,
    input wire demux_sel,
    input wire [31:0] recovery_data,
    output wire [31:0] read_data,
    output wire [31:0] recovery_read_data
);
    // Data memory
    reg [31:0] data_mem [0:1023]; // 1KB data memory
    
    // Recovery memory
    reg [31:0] recovery_mem [0:255]; // 256 words recovery memory
    
    wire [31:0] selected_write_data;
    wire [31:0] mem_read_data, recovery_mem_read_data;
    wire write_to_recovery, write_to_main;
    
    initial begin: init
        integer i;
        for(i = 0; i < 1023; i = i + 1) begin
            data_mem[i] <= 0;  
        end 
        i = 0;
        for(i = 0; i < 255; i = i + 1) begin
            recovery_mem[i] <= 0;
        end
    end
    
    // Input multiplexer for write data selection
    assign selected_write_data = mux_data_sel ? recovery_data : write_data;
    
    // Demultiplexer for write destination selection
    assign write_to_main = mem_write & ~demux_sel;
    assign write_to_recovery = mem_write & demux_sel;
    
    // Main data memory
    always @(posedge clk) begin
        if (write_to_main) begin
            data_mem[addr[9:0]] <= selected_write_data;
        end
    end
    
    assign mem_read_data = data_mem[addr[9:0]];
    
    // Recovery memory
    always @(posedge clk) begin
        if (write_to_recovery) begin
            recovery_mem[addr[7:0]] <= selected_write_data;
        end
    end
    
    assign recovery_mem_read_data = recovery_mem[addr[7:0]];
    
    // Output multiplexer for read data selection
    assign read_data = mux_data_sel ? recovery_mem_read_data : mem_read_data;
    assign recovery_read_data = recovery_mem_read_data;
endmodule

