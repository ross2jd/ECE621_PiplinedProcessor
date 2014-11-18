///////////////////////////////////////////////////////////////////////////////
// Company: University of Waterloo
// Author(s): Jordan Ross, Mustafa Faraj
//
// Created Date: 09/10/2014
// Design Name:
// Module Name: decode
// Project Name: ECE621_PipelinedProcessor
// Description: This module simply takes as an input the instruction and then
// splits apart the instruction in the bits cooresponding to the fields in any
// of the instruction types to be used by the control logic and data path.
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
    output wire [4:0]rs,
    output wire [4:0]rt,
    output wire [4:0]rd,
    output wire [4:0]sha,
    output wire [5:0]func,
    output wire [15:0]immed,
    output wire [25:0]target,
    output wire [5:0]opcode
);
    
    assign {opcode, rs, rt, rd, sha, func} = insn_in;
    assign target = insn_in[25:0];
    assign immed = insn_in[15:0];

endmodule