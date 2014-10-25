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
    wire [4:0]dest_reg;

    // Decode control signals
    reg dest_reg_sel;
    reg dec_illegal_insn;
    reg [5:0] dec_alu_op;
    reg dec_is_branch;
    reg dec_op2_sel;
    reg [5:0] dec_shift_amount;


    // Execute wires
    wire [31:0]exe_pc; // We define this as the PC for next instruction to be executed
    wire [31:0]exe_ir; // We define this as the current instruction being executied    
    wire [31:0]exe_A;
    wire [31:0]exe_B;
   	wire [31:0]exe_op2;
    wire [31:0]exe_O;
    wire [31:0]exe_extended; // The wire the comes for the sign extender
    wire exe_zero;
    wire [5:0] exe_alu_op;
    wire exe_is_branch;
    wire exe_op2_sel;
    wire [5:0] exe_shift_amount;

    // Execute control signals
    
    
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
    if_id_pipleline_reg if_id_pipleline_reg(
        .clk(clk),
        .pc_in(pc),
        .ir_in(insn_data_out),
        .pc_out(decode_pc),
        .ir_out(decode_ir)
    );

    // Instantiate a mux for selecting which destination to choose
    mux_2_1_5_bit dest_reg_mux(
        .line0(rt),
        .line1(rd),
        .select(dest_reg_sel), // TODO: Implement this control singal
        .output_line(dest_reg)
    );

    // Instantiate the register file
    reg_file reg_file(
        .clk(clk),
        .write_enable(reg_file_write_enable),
        .source1(rs),
        .source2(rt),
        .dest(dest_reg),
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

    // Instatiate the ID/IX pipeline register
    id_ix_pipleline_reg id_ix_pipleline_reg(
        .clk(clk),
        .pc_in(decode_pc),
        .ir_in(decode_ir),
        .A_in(dec_A),
        .B_in(dec_B),
        .alu_op_in(dec_alu_op),
        .is_branch_in(dec_is_branch),
        .op2_sel_in(dec_op2_sel),
        .shift_amount_in(dec_shift_amount),
        .pc_out(exe_pc),
        .ir_out(exe_ir),
        .A_out(exe_A),
        .B_out(exe_B),
        .alu_op_out(exe_alu_op),
        .is_branch_out(exe_is_branch),
        .op2_sel_out(exe_op2_sel),
        .shift_amount_out(exe_shift_amount)
    );

    sign_extender sign_extender(
        .in_data(exe_ir[15:0]),
        .out_data(exe_extended)
    );

    // Instantiate a 32-bit mux for selecting which operand to provide to op2 of the ALU
    mux_2_1_32_bit alu_op2_sel_mux(
        .line0(exe_B),
        .line1(exe_extended),
        .select(exe_op2_sel),
        .output_line(exe_op2)
    );

    alu alu(
        .op1(exe_A), // operand 1 (always from rs)
        .op2(exe_op2), // operand 2
        .operation(exe_alu_op), // The arithmatic operation to perform
        .shift_amount(exe_shift_amount), // The number of bits to shift
        .result(exe_O), // The arithmatic result based on the operation
        .zero(exe_zero) // Indicates if the result of the operation is zero.
    );
    
    // Control
    always @(posedge clk) begin
        reg_file_write_enable = 0; // TODO: Change this later
        
        
        // ----------- Decode Stage Control Signal Logic --------------------------- //
        dec_illegal_insn = 0;
        dest_reg_sel = 0;
        dec_alu_op = 0;
        dec_op2_sel = 0;
        if (((opcode & 6'b111000)>> 3) == 3'h0) begin
            if ((opcode & 6'b000111) == 3'h0) begin
            	// We are in the SPECIAL Opcode encoding table
            	// This is an R-type instruction
            	dest_reg_sel = 0;
            	if (func == 6'b100000 || func == 6'b100001) // ADD, ADDU
            		dec_alu_op = 0; // Do an add operation
            	else if (func == 6'b100010 || func == 6'b100011) // SUB, SUBU
            		dec_alu_op = 1;
            	else if (func == 6'b011000 || func == 6'b011001) // MULT, MULTU
            		dec_alu_op = 2;
            	else if (func == 6'b011010 || func == 6'b011011) // DIV, DIVU
            		dec_alu_op = 3;
            	else if (func == 6'b000000) begin // SLL
            		dec_alu_op = 4;
            		dec_shift_amount = sha;
            	end
            	else if (func == 6'b000010) begin // SLL
            		dec_alu_op = 5;
            		dec_shift_amount = sha;
            	end
            	else if (func == 6'b101010 || func == 6'b101011) // SLT, SLTU
            		dec_alu_op = 6;
                else begin
                	dec_illegal_insn = 1;
                end
            end else if (((opcode & 6'b000111)  == 3'd2) || ((opcode & 6'b000111) == 3'd3)) begin
            	// J and JAL instructions
            	// This is J-type instruction
            	dest_reg_sel = 0;
            	dec_illegal_insn = 1;
            end else begin
            	// BEQ, BNE, BLEZ, BGTZ
            	// This is an I-type instruction
            	dec_alu_op = 1; // We want to do a subtraction and see if it is zero or not.
            	dest_reg_sel = 1;
            	dec_is_branch = 1;
            	dec_illegal_insn = 1;
            end
        end else if (((opcode & 6'b111000)>> 3) == 3'd1) begin
        	// ADDI, ADDIU, SLTI, SLTIU, ANDI, ORI, XORI, LUI
        	// This is an I-type instruction
        	case (opcode)
        		6'b001000: dec_alu_op = 0;  // ADDI
        		6'b001001: dec_alu_op = 0;  // ADDIU
        		6'b001010: dec_alu_op = 6;  // SLTI
        		6'b001011: dec_alu_op = 6;  // SLTUI
        		6'b001100: dec_alu_op = 7;  // ANDI
        		6'b001101: dec_alu_op = 8;  // ORI
        		6'b001110: dec_alu_op = 9;  // XORI
        		6'b001111: dec_alu_op = 12; // LUI
        	endcase
        	dest_reg_sel = 1;
        	dec_op2_sel = 1; // We want op2 to be the immediate in the ALU
        end else if (((opcode & 6'b111000)>> 3) == 3'd3) begin
        	// No idea?
        	dest_reg_sel = 0;
        	dec_illegal_insn = 1;
        end else if (((opcode & 6'b111000)>> 3) == 3'd4) begin
        	// LB, LH, LWL, LW, LBU, LHU, LWR
        	// This is an I-type instruction
    		dest_reg_sel = 1;
        	dec_op2_sel = 1;
        	dec_alu_op = 0; // We want to add the value of rs to the immediate
        end else if (((opcode & 6'b111000)>> 3) == 3'd5) begin
        	// SB, SH, SWL, SW, SWR
			// This is an I-type instruction
    		dest_reg_sel = 1;
        	dec_op2_sel = 1;
        	dec_alu_op = 0; // We want to add the value of rs to the immediate
        end else begin
            dec_illegal_insn = 1;
        end

    end

endmodule