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

	always @(dest or destVal) begin
		// This is where we will do our writes
		if (write_enable == 1'b1) begin
			case (dest)
				5'd0 : register[0] = 0;
				5'd1 : register[1] = destVal;
				5'd2 : register[2] = destVal;
				5'd3 : register[3] = destVal;
				5'd4 : register[4] = destVal;
				5'd5 : register[5] = destVal;
				5'd6 : register[6] = destVal;
				5'd7 : register[7] = destVal;
				5'd8 : register[8] = destVal;
				5'd9 : register[9] = destVal;
				5'd10 : register[10] = destVal;
				5'd11 : register[11] = destVal;
				5'd12 : register[12] = destVal;
				5'd13 : register[13] = destVal;
				5'd14 : register[14] = destVal;
				5'd15 : register[15] = destVal;
				5'd16 : register[16] = destVal;
				5'd17 : register[17] = destVal;
				5'd18 : register[18] = destVal;
				5'd19 : register[19] = destVal;
				5'd20 : register[20] = destVal;
				5'd21 : register[21] = destVal;
				5'd22 : register[22] = destVal;
				5'd23 : register[23] = destVal;
				5'd24 : register[24] = destVal;
				5'd25 : register[25] = destVal;
				5'd26 : register[26] = destVal;
				5'd27 : register[27] = destVal;
				5'd28 : register[28] = destVal;
				5'd29 : register[29] = destVal;
				5'd30 : register[30] = destVal;
				5'd31 : register[31] = destVal;
				default : register[0] = 0;
			endcase
			//register[dest] = destVal;
			//register[0] = 0; // r0 is always 0
		end
	end

	always @(posedge clk) begin
		// This is where we will do our reads
		s1val = register[source1];
		s2val = register[source2];
	end


endmodule