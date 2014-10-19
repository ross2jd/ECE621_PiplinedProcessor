///////////////////////////////////////////////////////////////////////////////
// Company: University of Waterloo
// Author(s): Jordan Ross, Mustafa Faraj
//
// Created Date: 19/10/2014
// Design Name:
// Module Name: reg_file_tb
// Project Name: ECE621_PipelinedProcessor
// Description: This module is a test bench for the reg_file module.
// 
// Dependencies: reg_file.v
// 
// Revision:
// 0.01 - File Created and Initial Tests
// Additional Comments:
//
///////////////////////////////////////////////////////////////////////////////
module reg_file_tb;        
    // Ports for testing
    reg clk;
    reg write_enable;
    reg [4:0]source1;
    reg [4:0]source2;
    reg [4:0]dest;
    reg [31:0]destVal;
    wire [31:0]s1val;
    wire [31:0]s2val;

    integer i;

    // Instantiate the reg_file unit under test
    reg_file reg_file(
        .clk(clk),
        .write_enable(write_enable),
        .source1(source1),
        .source2(source2),
        .dest(dest),
        .destVal(destVal),
        .s1val(s1val),
        .s2val(s2val)
    );

	initial begin
        // Start the clock high
        clk = 0;
        for (i=0; i <32; i=i+1) begin
            write_enable = 1;
            dest = i;
            destVal = i;
            #50;
            write_enable = 0;
            source1 = i;
            source2 = i;
            dest = i;
            destVal = i;
            $display("S1 val = %d", s1val);
            $display("S2 val = %d", s2val);
            #50;
        end
        
	end
    
	always begin
        #50 clk = !clk;
	end
	
endmodule
