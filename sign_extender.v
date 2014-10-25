///////////////////////////////////////////////////////////////////////////////
// Company: University of Waterloo
// Author(s): Jordan Ross, Mustafa Faraj
//
// Created Date: 21/10/2014
// Design Name:
// Module Name: sign_extender
// Project Name: ECE621_PipelinedProcessor
// Description: This module is for the sign extension of a 16-bit number to a 
// 32-bit number
// 
// Dependencies:
// 
// Revision:
// 0.01 - File Created.
//
// Additional Comments:
//
///////////////////////////////////////////////////////////////////////////////
module sign_extender(
	input [15:0] in_data, // The data that you want to sign extend
	output reg [31:0] out_data
);
	always @(in_data) begin
		out_data[31:0] <= { {16{in_data[15]}}, in_data[15:0] };
	end	
endmodule
