module control_unit(
    input  wire clk,
    input  wire rst,
    
    input  wire[31:0] instruction,
    input  wire       valid,
    output wire       ready,
    
    output reg error
);

reg[31:0] curr_instruction;
reg[3:0] state; // 0 means ready, 1 means sending to ALU, 2 means writing to register

assign ready = state == 0;

reg we;
reg[31:0] d_in;
reg[3:0] rd_sel;
reg[3:0] rs_sel;
reg[3:0] rt_sel;
wire[31:0] rs;
wire[31:0] rt;

// Additional Fields From Instruction
reg[6:0] opcode;
reg[2:0] funct3;
reg[6:0] funct7;
reg[31:0] immid = 32'd0;

register_file reg_file(
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

alu alu(
    .op1(alu_op1),
    .op2(alu_op2),
    .control(alu_control),
    .res(alu_res),
    .error(alu_error)
);

always @(posedge clk) begin
    if (rst) begin
        state <= 0;
        we <= 0;
        error <= 0;
        
        
    end else if (state == 0 && valid) begin
    
        curr_instruction <= instruction;
        
        if (instruction[5]) begin
            rs_sel <= instruction[13:10];
        end else begin
            rs_sel <= instruction[13:10];
            rt_sel <= instruction[17:14];
        end
        
        state <= 1;
        error <= 0;
    
    // Sending instructions to ALU
    end else if (state == 1) begin
    
        // Obtaining additional fields
        opcode <= curr_instruction[6:0];
        funct3 <= curr_instruction[14:12];
        funct7 <= curr_instruction[31:25];
    
        // Adding support for LUI (load-upper immediate) instruction
        // Opcode for Load Upper Imm = 0110111, rd = imm << 12.
        if (opcode == 7'b0110111) begin 
            d_in <= {curr_instruction[31:12], 12'b0};
            rd_sel <= curr_instruction[11:7];
            we <= (rd_sel != 4'b0000);
            state <= 3;
        
        // Adding support for I-Type instruction
        end else if (opcode == 7'b001011) begin
            immid <= {curr_instruction[31:12], 12'b0};
            alu_op1 <= rs;
            
            // Setting ALU_CONTROL line
            case (funct3) 
                // ADDI (0)
                3'b000: begin
                    alu_control <= 4'b0000; 
                    alu_op2 <= immid; 
                    end
                // XORI (4)
                3'b100: begin 
                    alu_control <= 4'b0010; 
                    alu_op2 <= immid; 
                    end
                // ORI (6)
                3'b110: begin
                    alu_control <= 4'b0011; 
                    alu_op2 <= immid;
                    end
                // ANDI (7)
                3'b111: begin 
                    alu_control <= 4'b0100; 
                    alu_op2 <= immid; 
                    end
                // SLLI (1)
                3'b001: begin 
                    alu_control <= 4'b0101; 
                    alu_op2 <= curr_instruction[24:20];
                     end
                // SRLI : SRAI (5)
                3'b101: begin
                    alu_op2 <= curr_instruction[24:20];
                    alu_control <= (funct7 == 7'b0100000) ? 4'b0111 : 4'b0110;
                end
                default: begin alu_control <= 4'b1111; end
            endcase
      
            // Move onto next state
            state <= 2;

        // Adding support for R-type instructions       
        end else if(opcode == 7'b0110011) begin
            alu_op1 <= rs;
            alu_op2 <= (curr_instruction[5]) ? curr_instruction[31:14] : rt;
            
            // Setting ALU_CONTROL
            case (funct3) 
                // SUB, ADD (O)
                3'b000: alu_control <= (funct7 == 7'b0100000) ? 4'b0001 : 4'b0000;
                // XOR (4)
                3'b100: alu_control <= 4'b0010;
                // OR (6)
                3'b110: alu_control <= 4'b0011;
                // AND (7)
                3'b111: alu_control <= 4'b0100;
                // SLL (1)
                3'b001: alu_control <= 4'b0101;
                // SRA : SRL (5)
                3'b101: alu_control <= (funct7 == 7'b0100000) ? 4'b0111 : 4'b0110;
                default: alu_control <= 4'b1111; // invalid
            endcase
            
            // Move ontro next state.
            state <= 2;      
        
        // Some invalid opcode.
        end else begin
            error <= 1;
            state <= 0;
        end
        
    // Execute ALU and writing to register file.
    end else if (state == 2) begin
    
        if (alu_error) begin
            error <= 1;
            state <= 0;
        end else begin
        
            // Write-enable only when rd_sel !=  0.
            if (rd_sel != 4'b0000) begin
                we <= 1;
            end else begin
                we <= 0;
            end
           
            d_in <= alu_res;
            
            rd_sel <= curr_instruction[9:6];
            state <= 3;
        end
        
    end else if (state == 3) begin
        we <= 0;
        state <= 0;
    end
end

endmodule