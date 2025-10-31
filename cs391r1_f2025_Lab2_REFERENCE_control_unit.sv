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
    end else if (state == 1) begin
        alu_op1 <= rs;
        alu_op2 <= (curr_instruction[5]) ? curr_instruction[31:14] : rt;
        alu_control <= curr_instruction[3:0];
        state <= 2;
    end else if (state == 2) begin
        if (alu_error) begin
            error <= 1;
            state <= 0;
        end else begin
            we <= 1;
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