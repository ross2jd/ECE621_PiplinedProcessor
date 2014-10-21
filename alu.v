///////////////////////////////////////////////////////////////////////////////
// Company: University of Waterloo
// Author(s): Jordan Ross, Mustafa Faraj
//
// Created Date: 21/10/2014
// Design Name:
// Module Name: alu
// Project Name: ECE621_PipelinedProcessor
// Description: This module is for the ALU for the pipelined processor. It provides
// support for the following subset of MIPS instructions:
// 1. add, addiu, addu, sub, subu, mul, div
// 2. slt, slti, sltu
// 3. sll, srl, sra, and, or, xor, nor
// 4. lw, sw, li (ori, lui), lb, sb, lbu, move
// 5. j, jal, jr, beq, bne, bgez, bgtz, blez, bltz
// 6. nop
// 
// Dependencies:
// 
// Revision:
// 0.01 - File Created.
//
// Additional Comments:
//
///////////////////////////////////////////////////////////////////////////////
module alu(
	input [31:0] op1, // operand 1 (always from rs)
	input [31:0] op2, // operand 2
	input [5:0] operation, // The arithmatic operation to perform
	output reg [31:0] result, // The arithmatic result based on the operation
	output reg zero // Indicates if the result of the operation is zero.
);
	// The operations that the ALU supports are:
	// 0: Addition TODO: Is there a difference here with unisgned vs. signed?
	// 1: Subtraction
	// 2: Multiply
	// 3: Divide
	// 4: Shift logical left (assumes the shift amount is in operand 2)
	// 5: Shift logical right (assumes the shift amount is in operand 2)
	// 6: Set on less than
	// 7: And
	// 8: Or
	// 9: Xor
	// 10: Nor

	always @(op1 or op2 or operation) begin
		case (operation) 
			0: result = op1+op2;
			1: result = op1-op2;
			2: result = op1*op2;
			3: begin
				if (op2 != 0) begin
					result = op1/op2;
				end
				// TODO: Otherwise we should trap here
			end
			4: result = op1 << op2;
			5: result = op1 >> op2;
			6: result = op1 < op2 ? 1 : 0;
			7: result = op1 & op2;
			8: result = op1 | op2;
			9: result = op1 ^ op2;
			10: result = ~(op1 | op2);
			11: result = op1 >>> op2;
			//11: SRA the upper most bit is duplicated
		endcase
		zero = result == 0 ? 1 : 0;
	end	
endmodule
