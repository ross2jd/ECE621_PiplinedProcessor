///////////////////////////////////////////////////////////////////////////////
// Company: University of Waterloo
// Author(s): Jordan Ross, Mustafa Faraj
//
// Created Date: 26/10/2014
// Design Name:
// Module Name: branch_resolve
// Project Name: ECE621_PipelinedProcessor
// Description: This module is used to resolve branches based on the type and
// the zero and negative bits from the ALU
// 
// Dependencies:
// 
// Revision:
// 0.01 - File Created.
//
// Additional Comments:
//
///////////////////////////////////////////////////////////////////////////////
module branch_resolve(
	input zero,
	input neg,
	input [1:0]branch_type,
	input is_branch,
	output reg branch_taken // Indicates if the branch is taken or not
);
	always @(zero or neg or branch_type or is_branch) begin
		if (is_branch == 1'b1) begin
			case (branch_type)
				2'b00: branch_taken = zero;  //zero == 0 ? 1 : 0; // BEQ
				2'b01: branch_taken = !zero; //zero == 0 ? 0 : 1; // BNE
				2'b10: branch_taken = (neg | zero) == 0 ? 1 : 0; // BLEZ
				2'b11: branch_taken = neg == 0 ? 0 : 1; // BGTZ
			endcase
		end else begin
			branch_taken = 0;
		end
	end
endmodule
