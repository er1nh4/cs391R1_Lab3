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
    
    parameter BITWIDTH = 32
  
    )(
    input wire clk,
    input wire we,
    
    input wire [BITWIDTH-1:0] d_in,
    
    // Write channel
    input wire [4:0] rd_sel,
    
    // Read channel
    input wire [4:0] rs_sel,
    input wire [4:0] rt_sel,
    
    output wire [BITWIDTH-1:0] rs,
    output wire [BITWIDTH-1:0] rt
    
    );
    
    reg[BITWIDTH-1:0] regIn [BITWIDTH-1:0]; // 16 general purpose registers.
    
    integer i;
    
    // Initialize flip-flops.
    initial begin
        for(i=0; i < BITWIDTH; i=i+1)
            regIn[i] = 32'd0;
    end
    
    // Read from x0 (xero register) is always 0.
    assign rs = (rs_sel == 5'b00000) ? '0 : regIn[rs_sel[4:0]];
    assign rt = (rt_sel == 5'b00000) ? '0 : regIn[rt_sel[4:0]];
    
    always @ (posedge clk) begin
        
        if (we && rd_sel != 5'b00000) begin
            regIn[rd_sel[4:0]] <= d_in;   
        end  
          
    end
    
endmodule
