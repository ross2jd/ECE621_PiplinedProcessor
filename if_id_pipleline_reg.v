///////////////////////////////////////////////////////////////////////////////
// Company: University of Waterloo
// Author(s): Jordan Ross, Mustafa Faraj
//
// Created Date: 22/10/2014
// Design Name:
// Module Name: if_id_pipleline_reg
// Project Name: ECE621_PipelinedProcessor
// Description: This module is the IF/ID pipeline register it will latch the
// the following values.
// 1. PC
// 2. IR
// 
// Dependencies: memory.v
// 
// Revision:
// 0.01 - File Created.
//
// Additional Comments:
//
///////////////////////////////////////////////////////////////////////////////
module if_id_pipleline_reg(
    input clk,
    input [31:0]pc_in,
    //input [31:0]ir_in,
    output reg [31:0]pc_out    
    //output reg [31:0]ir_out
);

    always @(negedge clk) begin
        // write on the negative edge of the clock cycle
        pc_out = pc_in;
        //ir_out = ir_in;
    end
endmodule