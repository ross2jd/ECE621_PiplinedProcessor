///////////////////////////////////////////////////////////////////////////////
// Company: University of Waterloo
// Author(s): Jordan Ross, Mustafa Faraj
//
// Created Date: 08/10/2014
// Design Name:
// Module Name: fetch
// Project Name: ECE621_PipelinedProcessor
// Description: This module is the fetch module for the execution loop of the
// pipelined processor. It will read the instruction from main memory given by
// the address in the program counter (PC) register. This instruction will then
// be fed into a decode module.
// 
// Dependencies: memory.v
// 
// Revision:
// 0.01 - File Created.
//
// Additional Comments:
//
///////////////////////////////////////////////////////////////////////////////
module processor_tb;
    
    reg clk;
    reg srec_parse; // control signal for if the srec parser is active or not.
    
    // Registers, writes, and variables for parser
    integer fh = 0; // file handler for output
    integer i = 0; // loop variable
    integer data_byte = 0; // variable to keep track of what byte we are on.
    integer data_offset = 0; // keep track of the offset from the data address to write the next byte.
    reg [1:0]nibble_count = 0; // keep track of which nibble is being written (upper/lower).
    reg [7:0]rec_type; // record type number
    reg [7:0] byte_count; // the number of bytes for the address, data, and checksum
    integer record_code; // A record_code is equivalent to 1 ASCII digit/letter in the .srec file
    reg [31:0] rec_address; // the address given by the record.
    reg [7:0]rec_data; // A single byte of the data from the record.
    reg [7:0]temp; // a temporary byte used for place holding.
    reg done = 0; // this will set high when we are done parsing the file.
    reg [7:0] file_char = 8'h0A; // Set the initial character from the file read to be the new line character
    
    
    // Instantiate the processor as the unit under test.
    processor processor_uut(.clk(clk), .srec_parse(srec_parse));
    
    initial begin
    
        //---------------------------------------------------------
        // Parsing stage of testbench - memory is not valid until
        // after the parser has finished!
        //---------------------------------------------------------
        
    
        // Before we begin parsing we want to make sure the fetch module does nothing until the the memory has been
        // populated with instructions. We will do this by setting the stall_in to 1 so nothing happens.
        processor_uut.stall = 1;
        srec_parse = 1;
        
        $monitor("Starting the SREC parser...");
        
        // Open the SREC file to read
        fh = $fopen("D:/Git_Repositories/ECE621_PiplinedProcessor/BubbleSort.srec", "r");
        
        // Start the clock high
		clk = 1;
        
        // loop until we set the done bit
        while (done == 0) begin
            #100; // Delay 1 clock cycle.
            
            // Read the first/next character from the file.
            file_char = $fgetc(fh);
            if (file_char == 8'hff) begin
                done = 1;
                file_char = 8'h0A;
            end
            
            // Reset the record byte which keeps track of the current byte of the line you are reading in.
            // This is equivalent to 1 ASCII code from the file.
            record_code = 0;
            
            // Loop until we reach a new line character which signifies a new record.
            while (file_char != 8'h0A) begin 
                #50; // Delay 1/2 clock cycle.
                if (record_code == 0) begin
                    // Clear out all the bit fields.
                    rec_type = 8'h4;
                    byte_count = 16'h0;
                    rec_address = 32'h0;
                    rec_data = 132'h0;
                    data_offset = 0;
                    data_byte = 0;
                end else if (record_code == 1) begin
                    // read the record type.
                    rec_type[7:0] = atoh(file_char);
                end else if (record_code == 2) begin
                    // read the upper byte of the byte count.
                    temp = atoh(file_char);
                    byte_count[7:4] = temp[3:0];
                end else if (record_code == 3) begin
                    // read the lower byte of the byte count.
                    temp = atoh(file_char);
                    byte_count[3:0] = temp[3:0];
                end else if (record_code > 3) begin
                   
                   if (rec_type == 1) begin // If the record type is for a 16 bit address.
                        rec_address[31:16] = 16'h0000;
                        if (record_code == 4) begin
                            // read the middle byte of the address.
                            temp = atoh(file_char);
                            // remove the upper most nibble since we only have single digits to represent memory addresses
                            rec_address[15:12] = temp[3:0];
                        end else if (record_code == 5) begin
                            temp = atoh(file_char);
                            rec_address[11:8] = temp[3:0];
                        end else if (record_code == 6) begin
                            temp = atoh(file_char);
                            rec_address[7:4] = temp[3:0];
                        end else if (record_code == 7) begin
                            temp = atoh(file_char);
                            rec_address[3:0] = temp[3:0];
                        end else begin
                            // Check to see if we have reached the end of the data
                            if (data_byte < byte_count - 2 - 1) begin // Make sure we are less than the byte count minus the address size in bytes and checksum
                                // We are reading data so we want to create a lower and an upper nibble of a byte then write it to memory when we have both.
                                temp = atoh(file_char);
                                rec_data = rec_data << 4;
                                rec_data[3:0] = temp[3:0];
                                nibble_count = nibble_count + 1;
                                #50;
                                if (nibble_count > 1) begin
                                    // We have both nibbles so we should write the byte to memory
                                    // set all the lines on the falling edge of the clock.
                                    processor_uut.srec_address = rec_address+data_offset;
                                    processor_uut.srec_data_in = rec_data;
                                    processor_uut.srec_access_size = 2'b01;
                                    processor_uut.srec_rw = 1;
                                    #100; // Delay one clock cycle
                                    processor_uut.srec_rw = 0;
                                    // update the data_offest.
                                    data_offset = data_offset + 1;
                                    // reset the nibble count
                                    nibble_count = 0;
                                    data_byte = data_byte + 1;
                                end
                            end
                        end
                    end    
                    
                    if (rec_type == 2) begin // If the record type is for a 24 bit address.
                        rec_address[31:24] = 8'h00;
                        if (record_code == 4) begin
                            temp = atoh(file_char);
                            rec_address[23:20] = temp[3:0];
                        end else if (record_code == 5) begin
                            temp = atoh(file_char);
                            rec_address[19:16] = temp[3:0];
                        end else if (record_code == 6) begin
                            temp = atoh(file_char);
                            rec_address[15:12] = temp[3:0];
                        end else if (record_code == 7) begin
                            temp = atoh(file_char);
                            rec_address[11:8] = temp[3:0];
                        end else if (record_code == 8) begin
                            temp = atoh(file_char);
                            rec_address[7:4] = temp[3:0];
                        end else if (record_code == 9) begin
                            temp = atoh(file_char);
                            rec_address[3:0] = temp[3:0];
                        end else begin
                            // Check to see if we have reached the end of the data
                            if (data_byte < byte_count - 3 - 1) begin // Make sure we are less than the byte count minus the address size in bytes and checksum
                                // We are reading data so we want to create a lower and an upper nibble of a byte then write it to memory when we have both.
                                temp = atoh(file_char);
                                rec_data = rec_data << 4;
                                rec_data[3:0] = temp[3:0];
                                nibble_count = nibble_count + 1;
                                #50;
                                if (nibble_count > 1) begin
                                    // We have both nibbles so we should write the byte to memory
                                    // set all the lines on the falling edge of the clock.
                                    processor_uut.srec_address = rec_address+data_offset;
                                    processor_uut.srec_data_in = rec_data;
                                    processor_uut.srec_access_size = 2'b00;
                                    processor_uut.srec_rw = 1;
                                    #100; // Delay one clock cycle
                                    processor_uut.srec_rw = 0;
                                    // update the data_offest.
                                    data_offset = data_offset + 1;
                                    // reset the nibble count
                                    nibble_count = 0;
                                    data_byte = data_byte + 1;
                                end
                            end
                        end
                    end
                    
                    if (rec_type == 3) begin // If the record type is for a 32 bit address.
                        if (record_code == 4) begin
                            // read the upper most byte of the address.
                            temp = atoh(file_char);
                            // remove the upper most nibble since we only have single digits to represent memory addresses
                            rec_address[31:28] = temp[3:0];
                        end else if (record_code == 5) begin
                            temp = atoh(file_char);
                            rec_address[27:24] = temp[3:0];
                        end else if (record_code == 6) begin
                            temp = atoh(file_char);
                            rec_address[23:20] = temp[3:0];
                        end else if (record_code == 7) begin
                            temp = atoh(file_char);
                            rec_address[19:16] = temp[3:0];
                        end else if (record_code == 8) begin
                            temp = atoh(file_char);
                            rec_address[15:12] = temp[3:0];
                        end else if (record_code == 9) begin
                            temp = atoh(file_char);
                            rec_address[11:8] = temp[3:0];
                        end else if (record_code == 10) begin
                            temp = atoh(file_char);
                            rec_address[7:4] = temp[3:0];
                        end else if (record_code == 11) begin
                            temp = atoh(file_char);
                            rec_address[3:0] = temp[3:0];
                        end else begin
                            // Check to see if we have reached the end of the data
                            if (data_byte < byte_count - 4 - 1) begin // Make sure we are less than the byte count minus the address size in bytes and checksum
                                // We are reading data so we want to create a lower and an upper nibble of a byte then write it to memory when we have both.
                                temp = atoh(file_char);
                                rec_data = rec_data << 4;
                                rec_data[3:0] = temp[3:0];
                                nibble_count = nibble_count + 1;
                                #50;
                                if (nibble_count > 1) begin
                                    // We have both nibbles so we should write the byte to memory
                                    // set all the lines on the falling edge of the clock.
                                    processor_uut.srec_address = rec_address+data_offset;
                                    processor_uut.srec_data_in = rec_data;
                                    processor_uut.srec_access_size = 2'b00;
                                    processor_uut.srec_rw = 1;
                                    #100; // Delay one clock cycle
                                    processor_uut.srec_rw = 0;
                                    // update the data_offest.
                                    data_offset = data_offset + 1;
                                    // reset the nibble count
                                    nibble_count = 0;
                                    data_byte = data_byte + 1;
                                end
                            end
                        end
                    end
                end
                
                #50; // delay 1/2 clock cycle
                // increment record_code
                record_code = record_code + 1;
                // read the next character from the file.
                file_char = $fgetc(fh);
            end
        end
        srec_parse = 0;
        #100;
        // Close up the file
        $fclose(fh);
        $monitor("Done parsing the SREC file!");
        #100;
        
        // ------------------------------------------------------------
        // Memory is ready to be used after this point!
        // ------------------------------------------------------------
        $monitor("Beginning the fetch-decode-execute loop!");
        #100;
        
        // Set the stall in to be 0 just read out the pc, rw, and access size.
        processor_uut.stall = 0;
        $monitor("PC = %h", processor_uut.pc);
        #100;
        
    end
    
	always begin
		#50 clk = !clk;
	end
    
    // A function to convert ASCII upper case letters and digits to their hexadecimal value.
    function [7:0]atoh;
        input [7:0]aCode;
        begin
            if (aCode >= 8'h30 && aCode <= 8'h39) begin
                atoh = aCode - 8'h30;
            end else if (aCode >= 8'h41 && aCode <= 8'h5A) begin
                atoh = aCode - 8'h37;
            end
        end
    endfunction
    
    


endmodule
	
	