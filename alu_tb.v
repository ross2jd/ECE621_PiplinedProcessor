///////////////////////////////////////////////////////////////////////////////
// Company: University of Waterloo
// Author(s): Jordan Ross, Mustafa Faraj
//
// Created Date: 21/10/2014
// Design Name:
// Module Name: reg_file_tb
// Project Name: ECE621_PipelinedProcessor
// Description: This module is a test bench for the alu module.
// 
// Dependencies: alu.v
// 
// Revision:
// 0.01 - File Created and Initial Tests
// Additional Comments:
//
///////////////////////////////////////////////////////////////////////////////
module alu_tb;
    reg clk;        
    reg [31:0] op1; // operand 1 (always from rs)
    reg [31:0] op2; // operand 2
    reg [5:0] operation; // The arithmatic operation to perform
    wire [31:0] result;
    wire zero;

    // Instantiate the alu unit under test
    alu alu_uut(
        .op1(op1), // operand 1 (always from rs)
        .op2(op2), // operand 2
        .operation(operation), // The arithmatic operation to perform
        .result(result),
        .zero(zero)
    );

	initial begin
        clk = 1;
        op1 = 0;
        op2 = 1;
        operation = 0;
        $strobe("%d + %d = %d", op1, op2, result);
        #100
        operation = 1;
        $strobe("%d - %d = %h", op1, op2, result);
        #100;
        operation = 2;
        $strobe("%d * %d = %d", op1, op2, result);
        #100;
        operation = 3;
        $strobe("%d / %d = %d", op1, op2, result);
        #100;
        operation = 4;
        $strobe("%h << %h = %h", op1, op2, result);
        #100;
        operation = 5;
        $strobe("%h >> %h = %h", op1, op2, result);
        #100;
        operation = 6;
        $strobe("%d < %d = %d", op1, op2, result);
        #100;
        operation = 7;
        $strobe("%h and %h = %h", op1, op2, result);
        #100;
        operation = 8;
        $strobe("%h or %h = %h", op1, op2, result);
        #100;
        operation = 9;
        $strobe("%h xor %h = %h", op1, op2, result);
        #100;
        operation = 10;
        $strobe("%h nor %h = %h", op1, op2, result);
        #100;
        operation = 11;
        $strobe("%b >>> %b = %b", op1, op2, result);
        #100;
        op1 = 2;
        op2 = 1;
        operation = 0;
        $strobe("%d + %d = %d", op1, op2, result);
        #100
        operation = 1;
        $strobe("%d - %d = %h", op1, op2, result);
        #100;
        operation = 2;
        $strobe("%d * %d = %d", op1, op2, result);
        #100;
        operation = 3;
        $strobe("%d / %d = %d", op1, op2, result);
        #100;
        operation = 4;
        $strobe("%h << %h = %h", op1, op2, result);
        #100;
        operation = 5;
        $strobe("%h >> %h = %h", op1, op2, result);
        #100;
        operation = 6;
        $strobe("%d < %d = %d", op1, op2, result);
        #100;
        operation = 7;
        $strobe("%h and %h = %h", op1, op2, result);
        #100;
        operation = 8;
        $strobe("%h or %h = %h", op1, op2, result);
        #100;
        operation = 9;
        $strobe("%h xor %h = %h", op1, op2, result);
        #100;
        operation = 10;
        $strobe("%h nor %h = %h", op1, op2, result);
        #100;
        operation = 11;
        $strobe("%b >>> %b = %b", op1, op2, result);
        #100;
        op1 = 3;
        op2 = 2;
        operation = 0;
        $strobe("%d + %d = %d", op1, op2, result);
        #100
        operation = 1;
        $strobe("%d - %d = %h", op1, op2, result);
        #100;
        operation = 2;
        $strobe("%d * %d = %d", op1, op2, result);
        #100;
        operation = 3;
        $strobe("%d / %d = %d", op1, op2, result);
        #100;
        operation = 4;
        $strobe("%h << %h = %h", op1, op2, result);
        #100;
        operation = 5;
        $strobe("%h >> %h = %h", op1, op2, result);
        #100;
        operation = 6;
        $strobe("%d < %d = %d", op1, op2, result);
        #100;
        operation = 7;
        $strobe("%h and %h = %h", op1, op2, result);
        #100;
        operation = 8;
        $strobe("%h or %h = %h", op1, op2, result);
        #100;
        operation = 9;
        $strobe("%h xor %h = %h", op1, op2, result);
        #100;
        operation = 10;
        $strobe("%h nor %h = %h", op1, op2, result);
        #100;
        operation = 11;
        $strobe("%b >>> %b = %b", op1, op2, result);
        #100;
        op1 = -1000;
        op2 = 4;
        operation = 0;
        $strobe("%d + %d = %d", op1, op2, result);
        #100
        operation = 1;
        $strobe("%d - %d = %h", op1, op2, result);
        #100;
        operation = 2;
        $strobe("%d * %d = %d", op1, op2, result);
        #100;
        operation = 3;
        $strobe("%d / %d = %d", op1, op2, result);
        #100;
        operation = 4;
        $strobe("%h << %h = %h", op1, op2, result);
        #100;
        operation = 5;
        $strobe("%h >> %h = %h", op1, op2, result);
        #100;
        operation = 6;
        $strobe("%d < %d = %d", op1, op2, result);
        #100;
        operation = 7;
        $strobe("%h and %h = %h", op1, op2, result);
        #100;
        operation = 8;
        $strobe("%h or %h = %h", op1, op2, result);
        #100;
        operation = 9;
        $strobe("%h xor %h = %h", op1, op2, result);
        #100;
        operation = 10;
        $strobe("%h nor %h = %h", op1, op2, result);
        #100;
        operation = 11;
        $strobe("%b >>> %b = %b", op1, op2, result);
        #100;
	end
    always begin
        #50 clk = !clk;
    end
	
endmodule
