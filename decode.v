///////////////////////////////////////////////////////////////////////////////
// Company: University of Waterloo
// Author(s): Jordan Ross, Mustafa Faraj
//
// Created Date: 09/10/2014
// Design Name:
// Module Name: fetch
// Project Name: ECE621_PipelinedProcessor
// Description: 
// 
// Dependencies: memory.v
// 
// Revision:
// 0.01 - File Created.
//
// Additional Comments:
//
///////////////////////////////////////////////////////////////////////////////
module decode(
    input [31:0]insn_in,          // Instruction bits to decode
    input [31:0]pc_in             // Program counter for the instruction.
);
    reg [4:0]rs = 5'hx;
    reg [4:0]rt = 5'hx;
    reg [4:0]rd = 5'hx;
    reg [4:0]sha = 5'hx;
    reg [5:0]func = 6'hx;
    reg [15:0]immed = 16'hx;
    reg [25:0]target = 26'hx;
    reg [5:0]opcode = 6'hx;
    
    reg illegal_insn = 0;
    
    always @(pc_in) begin
        opcode = insn_in[31:26];
        
        if (((opcode & 6'b111000)>> 3) == 3'h0) begin
            if ((opcode & 6'b000111) == 3'h0) begin
                rs = insn_in[25:21];
                rt = insn_in[20:16];
                rd = insn_in[15:11];
                sha = insn_in[10:6];
                func = insn_in[5:0];
            end else if (((opcode & 6'b000111)  == 3'd2) || ((opcode & 6'b000111) == 3'd2)) begin
                target = insn_in[25:0];
            end else begin
                illegal_insn = 1;
            end
        end else if (((opcode & 6'b111000)>> 3) == 3'd1) begin
            rs = insn_in[25:21];
            rt = insn_in[20:16];
            immed = insn_in[15:0];
        end else if (((opcode & 6'b111000)>> 3) == 3'd3) begin
            rs = insn_in[25:21];
            rt = insn_in[20:16];
            rd = insn_in[15:11];
            sha = insn_in[10:6];
            func = insn_in[5:0];
        end else if (((opcode & 6'b111000)>> 3) == 3'd4) begin
            rs = insn_in[25:21];
            rt = insn_in[20:16];
            immed = insn_in[15:0];
        end else if (((opcode & 6'b111000)>> 3) == 3'd5) begin
            rs = insn_in[25:21];
            rt = insn_in[20:16];
            immed = insn_in[15:0];
        end else begin
            illegal_insn = 1;
        end
    end
endmodule