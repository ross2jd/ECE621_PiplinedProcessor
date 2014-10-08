///////////////////////////////////////////////////////////////////////////////
// Company: University of Waterloo
// Author(s): Jordan Ross, Mustafa Faraj
//
// Created Date: 8/10/2014
// Design Name:
// Module Name: fetch_tb
// Project Name: ECE621_PipelinedProcessor
// Description: This module is a test bench for the fetch module.
// 
// Dependencies: fetch.v
// 
// Revision:
// 0.01 - File Created and Initial Tests
// 0.02 - Added test cases.
// Additional Comments:
//
///////////////////////////////////////////////////////////////////////////////
module fetch_tb;        
    // Ports for testing
    reg stall_in;
    wire rw_out;
    wire [31:0] pc_out;
    reg clk;
	wire [1:0] access_size;
    
    // Instantiate the fetch unit under test
    fetch fetch_uut(
        .clk_in(clk),
        .stall_in(stall_in),
        .pc_out(pc_out),
        .rw_out(rw_out),
        .access_size_out(access_size)
    );
	
	initial begin
        // Start the clock high
        clk = 1;
        repeat(5) begin
            // Set the stall in to be 0 just read out the pc, rw, and access size.
            stall_in = 0;
            $monitor("PC = %h", pc_out);
            #100;
        end
        
	end
    
	always begin
        #50 clk = !clk;
	end
	
endmodule
