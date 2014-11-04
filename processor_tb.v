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

    integer pipe_stage_counter = 6;
    
    // Registers, writes, and variables for parser
    integer fh = 0; // file handler for output
    integer i = 0; // loop variable
    integer data_byte = 0; // variable to keep track of what byte we are on.
    integer data_offset = 0; // keep track of the offset from the data address to write the next byte.
    reg [1:0]nibble_count = 0; // keep track of which nibble is being written (upper/lower).
    reg [7:0]rec_type; // record type number
    reg [7:0] byte_count; // the number of bytes for the address, data, and checksum
    integer record_code; // A record_code is equivalent to 1 ASCII digit/letter in the .srec file
    reg [31:0] rec_address = 'b0; // the address given by the record.
    integer highest_address = 0;
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
        //fh = $fopen("D:/GitHub/ECE621_PiplinedProcessor/BubbleSort.srec", "r");
        //fh = $fopen("D:/Dropbox/Grad/01 Fall14/ECE621/Labs/L1/code/ECE621_PiplinedProcessor/BubbleSort.srec", "r");
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
                highest_address = (rec_address > highest_address)? rec_address: highest_address;
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
        #100;
        // Close up the file
        $fclose(fh);
        $monitor("Done parsing the SREC file!");
        #100;
        $monitor("Initializing the register file with values the same as index");
        #100;
        for (i=0; i <32; i=i+1) begin
            processor_uut.reg_file.register[i] = i;
            #100;
        end
        $monitor("Done initializing the register file");
        #100;
        
        // ------------------------------------------------------------
        // Memory is ready to be used after this point!
        // ------------------------------------------------------------
        $monitor("Beginning the fetch-decode-execute loop!");
        #100;
        // Set the stall in to be 0 just read out the pc, rw, and access size.
        srec_parse = 0;
        processor_uut.stall = 0;
        pipe_stage_counter = 6;
        #50;
        processor_uut.stall = 1;

        //$monitor("%h:    %h   ", processor_uut.pc_out, processor_uut.insn_out);
        while (processor_uut.pc <= highest_address) begin
            //@(posedge clk);
            if (pipe_stage_counter < 5) begin
                processor_uut.stall = 1;
                pipe_stage_counter = pipe_stage_counter + 1;
            end
            else begin
                pipe_stage_counter = 0;
                processor_uut.stall = 0;
                //#100;
                case(processor_uut.opcode)
                    6'd0:  begin //JR, ADD, ADDU, SUB SUBU, DIV, SLT, SLTU, SLL, SRL, SRA, AND, OR, XOR, NOR, NOP
                        case(processor_uut.func)
                        6'd0: begin //SLL, NOP
                            if (processor_uut.sha == 5'b0) $strobe("%h:    %h    NOP", processor_uut.pc_out - 4, processor_uut.insn_out);
                            else $strobe("%h:    %h    sll  %h, %h, %h",
                                processor_uut.pc_out - 4, processor_uut.insn_out, processor_uut.rd, processor_uut.rt, processor_uut.sha);
                        end
                        6'd2: begin //SRL
                            $strobe("%h:    %h    srl  %h, %h, %h",
                                processor_uut.pc_out - 4, processor_uut.insn_out, processor_uut.rd, processor_uut.rt, processor_uut.sha);
                        end
                        6'd3: begin //SRA
                            $strobe("%h:    %h    sra  %h, %h, %h",
                                processor_uut.pc_out - 4, processor_uut.insn_out, processor_uut.rd, processor_uut.rt, processor_uut.sha);
                        end
                        6'd8: begin //JR
                            $strobe("%h:    %h    jr  %h",
                                processor_uut.pc_out - 4, processor_uut.insn_out, processor_uut.rs);
                        end
                        6'd26: begin //DIV
                            $strobe("%h:    %h    div  %h, %h",
                                processor_uut.pc_out - 4, processor_uut.insn_out, processor_uut.rs, processor_uut.rt);
                        end
                        6'd32: begin //ADD
                            $strobe("%h:    %h    add  %h, %h, %h",
                                processor_uut.pc_out - 4, processor_uut.insn_out, processor_uut.rd, processor_uut.rs, processor_uut.rt);
                        end
                        6'd33: begin //ADDU
                            $strobe("%h:    %h    addu  %h, %h, %h",
                                processor_uut.pc_out - 4, processor_uut.insn_out, processor_uut.rd, processor_uut.rs, processor_uut.rt);
                        end
                        6'd34: begin //SUB
                            $strobe("%h:    %h    sub  %h, %h, %h",
                                processor_uut.pc_out - 4, processor_uut.insn_out, processor_uut.rd, processor_uut.rs, processor_uut.rt);
                        end
                        6'd35: begin //SUBU
                            $strobe("%h:    %h    subu  %h, %h, %h",
                                processor_uut.pc_out - 4, processor_uut.insn_out, processor_uut.rd, processor_uut.rs, processor_uut.rt);
                        end
                        6'd36: begin //AND
                            $strobe("%h:    %h    and  %h, %h, %h",
                                processor_uut.pc_out - 4, processor_uut.insn_out, processor_uut.rd, processor_uut.rs, processor_uut.rt);
                        end
                        6'd37: begin //OR
                            $strobe("%h:    %h    or  %h, %h, %h",
                                processor_uut.pc_out - 4, processor_uut.insn_out, processor_uut.rd, processor_uut.rs, processor_uut.rt);
                        end
                        6'd38: begin //XOR
                            $strobe("%h:    %h    xor  %h, %h, %h",
                                processor_uut.pc_out - 4, processor_uut.insn_out, processor_uut.rd, processor_uut.rs, processor_uut.rt);
                        end
                        6'd39: begin //NOR
                            $strobe("%h:    %h    nor  %h, %h, %h",
                                processor_uut.pc_out - 4, processor_uut.insn_out, processor_uut.rd, processor_uut.rs, processor_uut.rt);
                        end
                        6'd42: begin //SLT
                            $strobe("%h:    %h    slt  %h, %h, %h",
                                processor_uut.pc_out - 4, processor_uut.insn_out, processor_uut.rd, processor_uut.rs, processor_uut.rt);
                        end
                        6'd43: begin //SLTU
                            $strobe("%h:    %h    sltu  %h, %h, %h",
                                processor_uut.pc_out - 4, processor_uut.insn_out, processor_uut.rd, processor_uut.rs, processor_uut.rt);
                        end
                        default: begin 
                            $strobe("ERROR! %h:    %h", processor_uut.pc_out - 4, processor_uut.insn_out);
                            $stop;
                        end
                        endcase
                    end
                    6'd1: begin //BLTZ, BGEZ
                        case(processor_uut.rt)
                        5'd0: begin //BLTZ
                            $strobe("%h:    %h    bltz  %h, %h",
                                processor_uut.pc_out - 4, processor_uut.insn_out, processor_uut.rs, processor_uut.immed);
                        end
                        5'd1: begin //BGEZ
                            $strobe("%h:    %h    bgez  %h, %h",
                                processor_uut.pc_out - 4, processor_uut.insn_out, processor_uut.rs, processor_uut.immed);
                        end
                        default: begin
                            $strobe("ERROR! %h:    %h", processor_uut.pc_out - 4, processor_uut.insn_out);
                            $stop;
                        end
                        endcase
                    end
                    6'd2: begin //J
                        //display the destination address of the jump, not the offset.
                        $strobe("%h:    %h    j  %h",
                                processor_uut.pc_out - 4, processor_uut.insn_out, {processor_uut.pc_out[31-:4], 28'b0}+{processor_uut.target,2'b0});
                    end
                    6'd3: begin //JAL
                        //display the destination address of the jump, not the offset.
                        $strobe("%h:    %h    jal  %h",
                                processor_uut.pc_out - 4, processor_uut.insn_out, {processor_uut.pc_out[31-:4], 28'b0}+{processor_uut.target,2'b0});
                    end
                    6'd4: begin //BEQ
                        $strobe("%h:    %h    beq  %h, %h, %h",
                                processor_uut.pc_out - 4, processor_uut.insn_out, processor_uut.rs, processor_uut.rt, processor_uut.immed);
                    end
                    6'd5: begin //BNE
                        $strobe("%h:    %h    bne  %h, %h, %h",
                                processor_uut.pc_out - 4, processor_uut.insn_out, processor_uut.rs, processor_uut.rt, processor_uut.immed);
                    end
                    6'd6: begin //BLEZ
                        $strobe("%h:    %h    beq  %h, %h",
                                processor_uut.pc_out - 4, processor_uut.insn_out, processor_uut.rs, processor_uut.immed);
                    end
                    6'd7: begin //BGTZ
                        $strobe("%h:    %h    bgtz  %h, %h",
                                processor_uut.pc_out - 4, processor_uut.insn_out, processor_uut.rs, processor_uut.immed);
                    end
                    6'd9: begin //ADDIU
                        $strobe("%h:    %h    addiu  %h, %h, %d",
                                processor_uut.pc_out - 4, processor_uut.insn_out, processor_uut.rt, processor_uut.rs, processor_uut.immed);
                    end
                    6'd10: begin //SLTI
                        $strobe("%h:    %h    slti  %h, %h, %h",
                                processor_uut.pc_out - 4, processor_uut.insn_out, processor_uut.rt, processor_uut.rs, processor_uut.immed);
                    end
                    6'd13: begin //ORI
                        $strobe("%h:    %h    ori  %h, %h, %h",
                                processor_uut.pc_out - 4, processor_uut.insn_out, processor_uut.rt, processor_uut.rs, processor_uut.immed);
                    end
                    6'd15: begin //LUI
                        $strobe("%h:    %h    lui  %h, %h",
                                processor_uut.pc_out - 4, processor_uut.insn_out, processor_uut.rt, processor_uut.immed);
                    end
                    6'd28: begin //MUL
                        $strobe("%h:    %h    mul  %h, %h, %h",
                                processor_uut.pc_out - 4, processor_uut.insn_out, processor_uut.rd, processor_uut.rs, processor_uut.rt);
                    end
                    6'd32: begin //LB
                        $strobe("%h:    %h    lb  %h, %d(%h)",
                                processor_uut.pc_out - 4, processor_uut.insn_out, processor_uut.rt, processor_uut.immed, processor_uut.rs);
                    end
                    6'd35: begin //LW
                        $strobe("%h:    %h    lw  %h, %d(%h)",
                                processor_uut.pc_out - 4, processor_uut.insn_out, processor_uut.rt, processor_uut.immed, processor_uut.rs);
                    end
                    6'd36: begin //LBU
                        $strobe("%h:    %h    lbu  %h, %d(%h)",
                                processor_uut.pc_out - 4, processor_uut.insn_out, processor_uut.rt, processor_uut.immed, processor_uut.rs);
                    end
                    6'd40: begin //SB
                        $strobe("%h:    %h    sb  %h, %d(%h)",
                                processor_uut.pc_out - 4, processor_uut.insn_out, processor_uut.rt, processor_uut.immed, processor_uut.rs);
                    end
                    6'd43: begin //SW
                        $strobe("%h:    %h    sw  %h, %d(%h)",
                                processor_uut.pc_out - 4, processor_uut.insn_out, processor_uut.rt, processor_uut.immed, processor_uut.rs);
                    end
                    default: begin
                        $strobe("ERROR! %h:    %h", processor_uut.pc_out - 4, processor_uut.insn_out);
                        $stop;
                    end
                endcase
            end
            #100;
        end

        //write logic to grab instruction and its operands
        //$monitor("Instruction = %h", processor_uut.decoder.insn_in);
        #100;
        $stop;
        
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
	
	