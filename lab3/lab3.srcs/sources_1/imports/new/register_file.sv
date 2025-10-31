`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/10/2025 09:12:20 AM
// Design Name: 
// Module Name: register_file
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


module reg_file #(
    
    parameter WIDTH = 32,
    parameter NUM_REG = 16
  
    )(
    input wire clk,
    input wire we,
    
    input wire [WIDTH-1:0] d_in,
    
    // Write channel
    input wire [3:0] rd_sel,
    
    // Read channel
    input wire [3:0] rs_sel,
    input wire [3:0] rt_sel,
    
    output wire [WIDTH-1:0] rs,
    output wire [WIDTH-1:0] rt
    
    );
    
    reg[WIDTH-1:0] regIn [NUM_REG-1:0]; // 16 general purpose registers.
    
    integer i;
    
    // Initialize flip-flops.
    initial begin
        for(i=0; i < NUM_REG; i=i+1)
            regIn[i] = '0;
    end
    
    // Read from x0 (xero register) is always 0.
    assign rs = (rs_sel == 4'b0000) ? '0 : regIn[rs_sel[3:0]];
    assign rt = (rt_sel == 4'b0000) ? '0 : regIn[rt_sel[3:0]];
    
    always @ (posedge clk) begin
        
        if (we && rd_sel != 4'b0000) begin
            regIn[rd_sel[3:0]] <= d_in;   
        end  
          
    end
    
endmodule
