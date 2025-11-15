`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/30/2025 11:19:04 PM
// Design Name: 
// Module Name: control_unit_bram
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


module control_unit_bram(
    input clk,
    input reset,
    
    output reg s_axi_araddr,
    output reg s_axi_arvalid,
    
    input  wire [31:0] s_axi_rdata,
    input  wire s_axi_rvalid,
    output reg  s_axi_rready,  
      
    output reg error
    );
    
reg[31:0] curr_instruction;
reg[3:0] state; // 0 means ready, 1 means sending to ALU, 2 means writing to register
reg [31:0] pc;

assign state = 0;

// Register
reg we;
reg [31:0] d_in;
reg [4:0] rd_sel;
reg [4:0] rs_sel;
reg [4:0] rt_sel;
wire [31:0] rs;
wire [31:0] rt;

// Additional Fields In Instruction
reg[6:0] opcode;
reg[2:0] funct3;
reg[6:0] funct7;
reg[31:0] immid;

reg_file regFile(
    .clk(clk),
    .we(we),
    .d_in(d_in),
    .rd_sel(rd_sel),
    .rs_sel(rs_sel),
    .rt_sel(rt_sel),
    .rs(rs),
    .rt(rt)
);

reg[31:0] alu_op1;
reg[31:0] alu_op2;
reg[3:0] alu_control;
wire[31:0] alu_res;
wire alu_error;

ALU alu(
    .op1(alu_op1),
    .op2(alu_op2),
    .control(alu_control),
    .res(alu_res),
    .error(alu_error)
);

always @(posedge clk) begin
    if (reset) begin
            pc <= 0;
            state <= 0;
            we <= 0;
            s_axi_arvalid <= 0;
            s_axi_araddr  <= 0;
            s_axi_rready  <= 0;
            error <= 0;
        
    end else if (state == 0) begin
    
        s_axi_araddr  <= pc[21:2]; // assuming 32-bit word aligned, 4-byte increments
        s_axi_arvalid <= 1;
        s_axi_rready  <= 1;
        state <= 1;
        end
        
        state <= 1;
        error <= 0;
    end   
    // Sending instructions to ALU
    end else if (state == 1) begin
        if (s_axi_rvalid) begin
            curr_instruction <= s_axi_rdata;
             s_axi_arvalid <= 0; // deassert address
             s_axi_rready <= 0;  // deassert ready
             state <= 2;         // move to EXECUTE
         end
    end
    end else if (state == 2) begin 
        opcode <= curr_instruction[6:0];
        funct3 <= curr_instruction[14:12];
        funct7 <= curr_instruction[31:25];
        immid <= 0;

                // LUI
                if (opcode == 7'b0110111) begin
                    rd_sel <= curr_instruction[11:7];
                    d_in <= {curr_instruction[31:12], 12'b0};
                    we <= (rd_sel != 0);
                end
                // I-type
                else if (opcode == 7'b0010011) begin
                    rd_sel <= curr_instruction[11:7];
                    rs_sel <= curr_instruction[19:15];
                    immid <= {{20{curr_instruction[31]}}, curr_instruction[31:20]}; // sign-extend
                    alu_op1 <= rs;
                    case (funct3)
                        3'b000: begin alu_control <= 4'b0000; alu_op2 <= immid; end // ADDI
                        3'b100: begin alu_control <= 4'b0010; alu_op2 <= immid; end // XORI
                        3'b110: begin alu_control <= 4'b0011; alu_op2 <= immid; end // ORI
                        3'b111: begin alu_control <= 4'b0100; alu_op2 <= immid; end // ANDI
                        3'b001: begin alu_control <= 4'b0101; alu_op2 <= curr_instruction[24:20]; end // SLLI
                        3'b101: begin alu_op2 <= curr_instruction[24:20]; alu_control <= (funct7==7'b0100000)?4'b0111:4'b0110; end // SRLI/SRAI
                        default: begin alu_control <= 4'b1111; end
                    endcase
                    we <= (rd_sel != 0);
                end
                // R-type
                else if (opcode == 7'b0110011) begin
                    rd_sel <= curr_instruction[11:7];
                    rs_sel <= curr_instruction[19:15];
                    rt_sel <= curr_instruction[24:20];
                    alu_op1 <= rs;
                    alu_op2 <= rt;
                    case(funct3)
                        3'b000: alu_control <= (funct7==7'b0100000)?4'b0001:4'b0000; // SUB/ADD
                        3'b100: alu_control <= 4'b0010; // XOR
                        3'b110: alu_control <= 4'b0011; // OR
                        3'b111: alu_control <= 4'b0100; // AND
                        3'b001: alu_control <= 4'b0105; // SLL
                        3'b101: alu_control <= (funct7==7'b0100000)?4'b0111:4'b0110; // SRA/SRL
                        default: alu_control <= 4'b1111;
                    endcase
                    we <= (rd_sel != 0);
                end
                else begin
                    error <= 1; // unknown instruction
                end

                state <= 3; // move to WRITEBACK
            end
            
            // WRITEBACK: finish write, increment PC
            3: begin
                we <= 0;
                pc <= pc + 4;
                state <= 0; // back to READY/FETCH
            end
            
            endcase
        end
end

endmodule
