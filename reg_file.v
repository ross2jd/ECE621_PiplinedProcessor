///////////////////////////////////////////////////////////////////////////////
// Company: University of Waterloo
// Author(s): Jordan Ross, Mustafa Faraj
//
// Created Date: 19/10/2014
// Design Name:
// Module Name: reg_file
// Project Name: ECE621_PipelinedProcessor
// Description: This module is the register file module for the piplined
// processor.
// 
// Dependencies:
// 
// Revision:
// 0.01 - File Created.
//
// Additional Comments:
//
///////////////////////////////////////////////////////////////////////////////
module reg_file(
	input clk,
	input write_enable,
	input [4:0]source1,
	input [4:0]source2,
	input [4:0]dest,
	input [31:0]destVal,
	output reg [31:0]s1val,
	output reg [31:0]s2val
);
	// MIPS has 32 registers each of 32 bits in side
	reg [31:0] register[0:31];

	always @(negedge clk) begin
		// This is where we will do our writes
		if (write_enable == 1'b1) begin
			register[dest] = destVal;
		end
	end

	always @(posedge clk) begin
		// This is where we will do our reads
		s1val = register[source1];
		s2val = register[source2];
	end


endmodule