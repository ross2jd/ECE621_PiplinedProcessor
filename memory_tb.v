///////////////////////////////////////////////////////////////////////////////
// Company: University of Waterloo
// Author(s): Jordan Ross, Mustafa Faraj
//
// Created Date: 18/09/2014
// Design Name:
// Module Name: memory_tb
// Project Name: ECE621_PipelinedProcessor
// Description: This module is a test bench for the memory module.
// 
// Dependencies: memory.v
// 
// Revision:
// 0.01 - File Created and Initial Tests
// 0.02 - Added test cases.
// Additional Comments:
//
///////////////////////////////////////////////////////////////////////////////
module memory_tb;    
    // Output ports for testing
    wire [31:0] data_out;
    
    // Input ports for testing
    reg [31:0] address;
    reg [31:0] data_in;
    reg write;
    reg clk;
	reg [1:0] access_size;
	
	integer fh = 0; // file handler for output
	
    // Instantiate the memory module
    memory memory_uut(.data_out(data_out),
        .address(address),
        .data_in(data_in), 
        .write(write),
        .clk(clk),
		.access_size(access_size)
    );
    
    // Parameters to define the address spaces
    parameter instruction_offset = 32'h80020000;
	
	initial begin
        // Start the clock high
		clk = 1;
		
		#100; // delay 1 clock cycle
		
		// Start giving inputs here
		
        // We want to test writing an value to address 0x80020000 for a program instruction
        $monitor("Testing writing a 32 bit value to the first memory location in the instruction address space...\n");
        $monitor("Writing the value 0x98765432 to first address in instruction address space...\n");
        // Set the address line on the rising edge;
        address = instruction_offset+0;
        write = 1;
        #50; // delay until falling edge
        // Set the data line on the falling edge;
        data_in = 32'h98765432;
        access_size = 2'b10;
        #50;
        
        #100; // wait 1 clock cycle.
         
        $monitor("Testing reading the 32 bit value from the first memory location in the instruction address space...\n");
        address = instruction_offset+0;
        write = 0;
        access_size = 2'b10;
        #50; // delay until falling edge
        // read the data line on the falling edge;
        $monitor("The 32 bit value in the first instruction address space is 0x%h\n", data_out);
        #50;
        
        $monitor("Testing reading the 16 bit value from the first memory location in the instruction address space...\n");
        address = instruction_offset+0;
        write = 0;
        access_size = 2'b01;
        #50; // delay until falling edge
        // read the data line on the falling edge;
        $monitor("The 16 bit value in the first instruction address space is 0x%h\n", data_out[15:0]);
        #50;
        
        $monitor("Testing reading the 8 bit value from the first memory location in the instruction address space...\n");
        address = instruction_offset+0;
        write = 0;
        access_size = 2'b00;
        #50; // delay until falling edge
        // read the data line on the falling edge;
        $monitor("The 8 bit value in the first instruction address space is 0x%h\n", data_out[7:0]);
        #50;
        
        // Now we are going to test writing a 16-bit value and then reading it back.
        // We want to test writing an value to address 0x80020008 for a program instruction
        $monitor("Testing writing a 16 bit value into memory...\n");
        $monitor("Writing the value 0xAAAA to address 0x80020008...\n");
        // Set the address line on the rising edge;
        address = instruction_offset+8;
        write = 1;
        #50; // delay until falling edge
        // Set the data line on the falling edge;
        data_in = 16'hAAAA;
        access_size = 2'b01;
        #50;
        
        #100; // wait 1 clock cycle.
         
        $monitor("Testing reading the 16 bit value from 0x80020008...\n");
        address = instruction_offset+8;
        write = 0;
        access_size = 2'b01;
        #50; // delay until falling edge
        // read the data line on the falling edge;
        $monitor("The 16 bit value is 0x%h\n", data_out);
        #50;
        
        // Now we are going to test writing a 8-bit value and then reading it back.
        // We want to test writing an value to address 0x8002000D for a program instruction
        $monitor("Testing writing a 8 bit value into memory...\n");
        $monitor("Writing the value 0xBB to address 0x8002000D...\n");
        // Set the address line on the rising edge;
        address = instruction_offset+12;
        write = 1;
        #50; // delay until falling edge
        // Set the data line on the falling edge;
        data_in = 8'hBB;
        access_size = 2'b00;
        #50;
        
        #100; // wait 1 clock cycle.
         
        $monitor("Testing reading the 8 bit value from 0x8002000D...\n");
        address = instruction_offset+12;
        write = 0;
        access_size = 2'b00;
        #50; // delay until falling edge
        // read the data line on the falling edge;
        $monitor("The 8 bit value is 0x%h\n", data_out);
        #50;
        
	end
    
	always begin
		#50 clk = !clk;
	end
	
endmodule
