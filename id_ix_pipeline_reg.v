///////////////////////////////////////////////////////////////////////////////
// Company: University of Waterloo
// Author(s): Jordan Ross, Mustafa Faraj
//
// Created Date: 23/10/2014
// Design Name:
// Module Name: id_ix_pipleline_reg
// Project Name: ECE621_PipelinedProcessor
// Description: This module is the ID/IX pipeline register it will latch the
// the following values.
// 1. PC
// 2. IR
// 3. A - source 1 value from reg file
// 4. B - source 2 value from reg file
// 
// Dependencies: None
// 
// Revision:
// 0.01 - File Created.
//
// Additional Comments:
//
///////////////////////////////////////////////////////////////////////////////
module id_ix_pipleline_reg(
    input clk,
    input [31:0]pc_in,
    input [31:0]ir_in,
    input [31:0]A_in,
    input [31:0]B_in,
    output reg [31:0]pc_out,
    output reg [31:0]ir_out,
    output reg [31:0]A_out,
    output reg [31:0]B_out

);

    always @(negedge clk) begin
        // write on the negative edge of the clock cycle
        pc_out = pc_in;
        ir_out = ir_in;
        A_out = A_in;
        B_out = B_in;
    end
endmodule