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
module memory_sign_extender(
	input [31:0] in_data, // The data that you want to sign extend
	input [1:0] data_size, // 0 - word ; 1 - half word ; 2 - byte
	input sign_extend, // Whether to sign extend or not
	output reg [31:0] out_data
);
	always @(in_data or data_size or sign_extend) begin
		if (data_size == 2 && sign_extend) begin
			out_data[31:0] <= { {24{in_data[7]}}, in_data[7:0] };
		end
		else if (data_size == 1 && sign_extend) begin
			out_data[31:0] <= { {16{in_data[15]}}, in_data[15:0] };
		end
		else begin
			out_data <= in_data;
		end
	end	
endmodule
