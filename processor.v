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
module processor(
    input clk,  // The system clock
    input srec_parse    // If the SREC parser is active or not.
);
    // Control signals
    reg stall;
    wire [1:0]insn_access_size;
    wire [1:0]fetch_access_size;
    wire fetch_rw;
    wire insn_rw;
    
    // Address lines
    wire [31:0]pc;
    
    // Data lines
    wire [31:0]insn_data_out;
    wire [31:0]insn_address;
    
    // SREC registers (only used for helping the parser write to instruction memory)
    reg [31:0]srec_address;
    reg [31:0]srec_data_in;
    reg srec_rw;
    reg [1:0]srec_access_size;
    
    // Instantiate mux's for each of the SREC registers to aid the SREC parser.
    mux_2_1_32_bit srec_insn_address_mux(
        .line0(pc),
        .line1(srec_address),
        .select(srec_parse),
        .output_line(insn_address)
    );
    mux_2_1_1_bit srec_insn_rw_mux(
        .line0(fetch_rw),
        .line1(srec_rw),
        .select(srec_parse),
        .output_line(insn_rw)
    );
    mux_2_1_2_bit srec_insn_access_size_mux(
        .line0(fetch_access_size),
        .line1(srec_access_size),
        .select(srec_parse),
        .output_line(insn_access_size)
    );
    
    
    // Instantiate the fetch module
    fetch fetch(
        .clk_in(clk),
        .stall_in(stall),
        .pc_out(pc),
        .rw_out(fetch_rw),
        .access_size_out(fetch_access_size)
    );
    
    // Instantiate the instruction memory module
    memory insn_memory(
        .data_out(insn_data_out),
        .address(insn_address),
        .data_in(srec_data_in), // We can tie the srec_data_in wire to this port since we should never be writing to instruction memory unless we are srec parsing
        .write(insn_rw),
        .clk(clk),
		.access_size(insn_access_size)
    );
    
    // Instantiate the decode module
    decode decoder(
        .insn_in(insn_data_out),
        .pc_in(pc)
    );
    
    


endmodule