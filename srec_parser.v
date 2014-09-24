///////////////////////////////////////////////////////////////////////////////
// Company: University of Waterloo
// Author(s): Jordan Ross, Mustafa Faraj
//
// Created Date: 22/09/2014
// Design Name:
// Module Name: srec_parser
// Project Name: ECE621_PipelinedProcessor
// Description: This module is the parser for the srec file. It will read the
// contents of the file and then write the appropriate data into memory at the
// specified addresses.
// 
// Dependencies: memory.v
// 
// Revision:
// 0.01 - File Created.
//
// Additional Comments:
//
///////////////////////////////////////////////////////////////////////////////
module srec_parser;    
    // Output ports for memory module
    wire [31:0] data_out;
    
    // Input ports for memory module
    reg [31:0] address;
    reg [31:0] data_in;
    reg write;
    reg clk;
	reg [1:0] access_size;
	
	integer fh = 0; // file handler for output
    
    reg [7:0]rec_type; // record type number
    reg [15:0] byte_count; // the number of bytes for the address, data, and checksum
    integer record_byte;
    reg [31:0] rec_address; // the address given by the record.
    reg [131:0] rec_data;
    reg [7:0] temp;
    
    reg done = 0;
    
    reg [7:0] file_char = 8'h0A;
	
    // Instantiate the memory module
    memory memory(.data_out(data_out),
        .address(address),
        .data_in(data_in), 
        .write(write),
        .clk(clk),
		.access_size(access_size)
    );
    
    // Parameters to define the address spaces
    parameter instruction_offset = 32'h80020000;
	
	initial begin
    
        $monitor("Starting the SREC parser...");
        
        // Open the SREC file to read
        fh = $fopen("D:/GitHub/ECE621_PiplinedProcessor/BubbleSort.srec", "r");
        
        // Start the clock high
		clk = 1;
        
        // new line character is 0x0A
        while (done == 0) begin // TODO: change to check until file_char is null
            // Read the first/next character from the file.
            #100;
            file_char = $fgetc(fh);
            if (file_char == 8'hff) begin
                done = 1;
                file_char = 8'h0A;
            end
            record_byte = 0;
            while (file_char != 8'h0A) begin 
                #50;
                if (record_byte == 0) begin
                    // we have the start of a new record. Clear out all the bit fields.
                    rec_type = 8'h4;
                    byte_count = 16'h0;
                    rec_address = 32'h0;
                    rec_data = 132'h0;
                end else if (record_byte == 1) begin
                    // read the record type.
                    rec_type[7:0] = atoh(file_char);
                end else if (record_byte == 2) begin
                    // read the upper byte of the byte count.
                    byte_count[15:8] = atoh(file_char);
                end else if (record_byte == 3) begin
                    // read the lower byte of the byte count.
                    byte_count[7:0] = atoh(file_char);
                    #100;
                    byte_count = byte_count[15:8]*10 + byte_count[7:0];
                end else if (record_byte > 3) begin
                    if (rec_type == 3) begin // If the record type is for a 32 bit address.
                        // Possible issue if there is not a leading zero in the address. Don't think this will be an issue though.
                        if (record_byte == 4) begin
                            // read the upper most byte of the address.
                            temp = atoh(file_char);
                            rec_address[27:24] = temp[3:0];
                        end else if (record_byte == 5) begin
                            // read the second upper most byte of the address.
                            temp = atoh(file_char);
                            rec_address[23:20] = temp[3:0];
                        end else if (record_byte == 6) begin
                            // read the second upper most byte of the address.
                            temp = atoh(file_char);
                            rec_address[19:16] = temp[3:0];
                        end else if (record_byte == 7) begin
                            // read the second lower most byte of the address.
                            temp = atoh(file_char);
                            rec_address[15:12] = temp[3:0];
                        end else if (record_byte == 8) begin
                            // read the second lower most byte of the address.
                            temp = atoh(file_char);
                            rec_address[11:8] = temp[3:0];
                        end else if (record_byte == 9) begin
                            // read the second lower most byte of the address.
                            temp = atoh(file_char);
                            rec_address[7:4] = temp[3:0];
                        end else if (record_byte == 10) begin
                            // read the second lower most byte of the address.
                            temp = atoh(file_char);
                            rec_address[3:0] = temp[3:0];
                        end else begin
                            temp = atoh(file_char);
                            rec_data = rec_data << 4;
                            #50;
                            rec_data[3:0] = temp[3:0];
                            #50;
                        end
                    end
                end
                // increment record_byte
                #50;
                record_byte = record_byte + 1;
                // read the next character from the file.
                file_char = $fgetc(fh);
            end
        end
        
        $fclose(fh);
        $monitor("Done parsing the SREC file!");
    end
    
	always begin
		#50 clk = !clk;
	end
    
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
