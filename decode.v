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
    input clk,
    input stall,
    input [31:0]insn_in,          // Instruction bits to decode
    input [31:0]pc_in,     // Program counter for the instruction.
    
    output wire [4:0]rs,
    output wire [4:0]rt,
    output wire [4:0]rd,
    output wire [4:0]sha,
    output wire [5:0]func,
    output wire [15:0]immed,
    output wire [25:0]target,
    output wire [5:0]opcode,
    output wire [31:0]pc_out,
    output wire [31:0]insn_out
);
    //reg illegal_insn;
    reg [31:0] pc_in_r;
    assign pc_out = pc_in_r;
    assign insn_out = (stall)? 32'b0: insn_in;
    
    assign {opcode, rs, rt, rd, sha, func} = insn_in;
    assign target = insn_in[25:0];
    assign immed = insn_in[15:0];
    
    always @ (posedge clk) pc_in_r <= pc_in;
       

    //We dont need to do this part of the decode here, the decoder is only responsible
    //for slicing up the instruction into the appropriate fields.
    //For now the logic of 'decoding' an instruction into assembly is being done in the TB
    //in the future that logic will go into the control unit
    
    
    /*
    // If we only decode on the change of the instruction this should be valid
    always @(insn_in) begin
        illegal_insn = 0;
        opcode = insn_in[31:26];
        
        if (((opcode & 6'b111000)>> 3) == 3'h0) begin
            if ((opcode & 6'b000111) == 3'h0) begin
                rs = insn_in[25:21];
                rt = insn_in[20:16];
                rd = insn_in[15:11];
                sha = insn_in[10:6];
                func = insn_in[5:0];
            end else if (((opcode & 6'b000111)  == 3'd2) || ((opcode & 6'b000111) == 3'd3)) begin
                target = insn_in[25:0];
            end else begin
                rs = insn_in[25:21];
                rt = insn_in[20:16];
                immed = insn_in[15:0];
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
    */
endmodule