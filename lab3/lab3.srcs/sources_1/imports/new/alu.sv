`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2025 11:26:26 PM
// Design Name: 
// Module Name: ALU
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


module ALU #(

    parameter OP_WIDTH = 4
    
    )(
    
    input wire [OP_WIDTH-1:0] op1,
    input wire [OP_WIDTH-1:0] op2,
    
    input wire [2:0] control,
    
    output wire [OP_WIDTH-1:0] res,
    output wire [OP_WIDTH-1:0] error
    );
    
    // localparam NOT = 3'b000;
    localparam XOR = 3'b001;
    localparam AND = 3'b010;
    localparam OR = 3'b011;
    localparam XNOR = 3'b100;
    localparam ADD = 3'b101;
    localparam SUB = 3'b110;
    localparam COMP = 3'b111;
    
    // 2.1 
    //assign res = !op1;
    
    // 2.2
    //assign res = (control == 1'b0) ? (!op1) :
                //(control == 1'b1) ? (op1 ^ op2) :
                //1'b0;
                
    // 2.5 Bit-wise arithmetic shift
    //assign op1 = 
        //(control == ADD) ? op1 >>> op2 :
        //{OP_WIDTH{1'b0}};
    
    // 2.4
    assign res = 
        // Logical XOR    
        (control == XOR) ? op1 ^ op2 :
        // Logical AND
        (control == AND) ? op1 & op2 :
        // Logical OR
        (control == OR) ? op1 | op2 :
        // Logical XNOR
        (control == XNOR) ? ~(op1) ^ ~(op2) :
        // Logical ADD
        (control == ADD) ? op1 + op2 :
        // Logical SUB
        (control == SUB) ? op1 - op2 :
        // Logical Comparison
        (control == COMP && op1 < op2) ? {OP_WIDTH{1'd1}} :
        {OP_WIDTH{1'd0}};
        
             
endmodule
