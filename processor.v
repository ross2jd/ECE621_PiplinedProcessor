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
    // Decoder signals 
    wire [4:0]rs;
    wire [4:0]rt;
    wire [4:0]rd;
    wire [4:0]sha;
    wire [5:0]func;
    wire [15:0]immed;
    wire [25:0]target;
    wire [5:0]opcode;
    wire [31:0]pc_out;
    wire [31:0]insn_out;

    // Control signals
    reg stall;
    wire [1:0]insn_access_size;
    wire [1:0]fetch_access_size;
    wire fetch_rw;
    wire insn_rw;
    reg reg_file_write_enable;
    
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

    // Decode wires
    wire [31:0]decode_pc; // We define this as the PC for next instruction to be executed
    wire [31:0]decode_ir; // We define this as the current instruction being decoded
    wire [31:0]dec_A;
    wire [31:0]dec_B;

    // Execute wires
    wire [31:0]exe_pc; // We define this as the PC for next instruction to be executed
    wire [31:0]exe_ir; // We define this as the current instruction being executied    
    wire [31:0]exe_A;
    wire [31:0]exe_B;
    wire [31:0]exe_O;
    
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

    // Instatiate the IF/ID pipeline register to kep the PC and IR
    if_id_pipleliner_reg if_id_pipleliner_reg(
        .clk(clk),
        .pc_in(pc),
        .ir_in(insn_data_out),
        .pc_out(decode_pc),
        .ir_out(decode_ir)
    );

    // Instantiate the register file
    reg_file reg_file(
        .clk(clk),
        .write_enable(reg_file_write_enable),
        .source1(rs),
        .source2(rt), // TODO: Change this to select the appropriate value with cntrl sig
        .dest(rd),    // TODO: Ditto above todo
        .destVal(exe_O), // TODO: Change this to be the output from WB stage
        .s1val(dec_A),
        .s2val(dec_B)
    );
    
    // Instantiate the decode module
    decode decoder(
        .clk(clk),
        .stall(stall),
        .insn_in(decode_ir),
        .pc_in(pc), // TODO: I don't see what this is needed
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .sha(sha),
        .func(func),
        .immed(immed),
        .target(target),
        .opcode(opcode),
        .pc_out(pc_out), // TODO: I don't see why this is needed
        .insn_out(insn_out)
    );

    // Instatiate the ID/IX pipeline register to kep the PC and IR
    id_ix_pipleline_reg id_ix_pipleline_reg(
        .clk(clk),
        .pc_in(decode_pc),
        .ir_in(decode_ir),
        .A_in(dec_A),
        .B_in(dec_B),
        .pc_out(exe_pc),
        .ir_out(exe_ir),
        .A_out(exe_A),
        .B_out(exe_B)
    );

    // Control
    always @(posedge clk) begin
        reg_file_write_enable = 0; // TODO: Change this later
    end

endmodule