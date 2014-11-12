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
    
    reg [2:0]cur_pipe_state;
    reg [2:0]next_pipe_state;

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
    reg flush;
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
    
    // SREC registers (only used for helping the parser write to instruction/data memory)
    reg [31:0]srec_address;
    reg [31:0]srec_data_in;
    reg srec_rw;
    reg [1:0]srec_access_size;

    // Fetch wires
    wire [31:0]fetch_next_pc;
    wire [31:0]fetch_ir;

    // Decode wires
    wire [31:0]decode_pc; // We define this as the PC for next instruction to be executed
    reg [31:0]decode_ir; // We define this as the current instruction being decoded
    wire [31:0]dec_A;
    wire [31:0]dec_B;
    wire [4:0]dest_reg;

    // Decode control signals
    reg dec_dest_reg_sel;
    reg dec_illegal_insn;
    reg [5:0] dec_alu_op;
    reg dec_is_branch;
    reg dec_op2_sel;
    reg [5:0] dec_shift_amount;
    reg [1:0]dec_branch_type; // 0-BEQ, 1-BNE, 2-BLEZ, 3-BGTZ
    reg dec_is_jump;
    reg [1:0]dec_access_size;
    reg dec_rw;
    reg dec_memory_sign_extend;
    reg dec_res_data_sel;
    reg dec_write_to_reg;
    reg [4:0]dec_rt;
    reg [4:0]dec_rd;
    reg dec_is_jal;
    reg dec_is_jr;
    reg [4:0]exe_dest_reg_stall;
    reg [4:0]mem_dest_reg_stall;
    reg [4:0]dec_reg_source0_stall;
    reg [4:0]dec_reg_source1_stall;
    reg dec_stall_pipeline;
    reg dec_flush_pipeline;
    reg [2:0]dec_jump_counter;

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
    wire [31:0] exe_shift_immed;
    wire [31:0] exe_shift_target;
    wire [31:0] exe_jump_effective_address;
    wire [31:0] exe_branch_effective_address;
    wire exe_neg;
    wire [1:0]exe_branch_type;
    wire exe_branch_taken;
    wire [31:0]exe_next_pc;
    wire [31:0]exe_branch_next_pc;
    wire exe_is_jump;
    wire [1:0]exe_access_size;
    wire exe_rw;
    wire exe_memory_sign_extend;
    wire exe_res_data_sel;
    wire exe_write_to_reg;
    wire exe_dest_reg_sel;
    wire [4:0]exe_rt;
    wire [4:0]exe_rd;
    wire exe_update_pc;
    wire exe_is_jal;
    wire [31:0]exe_alu_result;
    wire [31:0]exe_jump_next_pc;
    wire exe_is_jr;
    wire exe_stall_pipeline;
    wire exe_flush_pipeline;

    // Memory wires
    wire [31:0]mem_next_pc;
    wire [31:0]mem_alu_result;
    wire [31:0]mem_reg_data;
    wire [1:0]mem_data_access_size;
    wire mem_data_rw;
    wire [31:0]mem_data_out;
    wire [31:0]mem_data_in;
    wire [31:0]mem_addr_in;
    wire [1:0]mem_access_size;
    wire mem_rw;
    wire mem_memory_sign_extend;
    wire [31:0]mem_sign_extend_out;
    wire [4:0]mem_rt;
    wire [4:0]mem_rd;
    wire mem_res_data_sel;
    wire mem_write_to_reg;
    wire mem_dest_reg_sel;
    wire mem_update_pc;
    wire mem_is_jal;
    wire mem_stall_pipeline;
    wire mem_flush_pipeline;

    // Write back wires
    wire [31:0]wb_O;
    wire [31:0]wb_D;
    wire wb_res_data_sel;
    wire wb_write_to_reg;
    wire wb_dest_reg_sel;
    wire [31:0]wb_data;
    wire [4:0]wb_rt;
    wire [4:0]wb_rd;
    wire [31:0]wb_next_pc;
    wire wb_update_pc;
    wire [4:0]wb_dest_reg;
    wire wb_is_jal;
    wire wb_stall_pipeline;
    wire wb_flush_pipeline;
    

    //--------------------------- FETCH STAGE -----------------------------------------//
    
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
        .pc_in(wb_next_pc),
        .update_pc(wb_update_pc),
        .pc_out(pc),
        .next_pc(fetch_next_pc),
        .rw_out(fetch_rw),
        .access_size_out(fetch_access_size)
    );
    
    // Instantiate the instruction memory module
    memory insn_memory(
        .data_out(fetch_ir),
        .address(insn_address),
        .data_in(srec_data_in), // We can tie the srec_data_in wire to this port since we should never be writing to instruction memory unless we are srec parsing
        .write(insn_rw),
        .clk(clk),
		.access_size(insn_access_size)
    );

// ------------------------------ DECODE STAGE --------------------------------------//

    // Instatiate the IF/ID pipeline register to kep the PC and IR
    if_id_pipleline_reg if_id_pipleline_reg(
        .clk(clk),
        .pc_in(fetch_next_pc),
        //.ir_in(insn_data_out), // We don't need to latch the ir because it won't be available until next clock cycle
        .pc_out(decode_pc)
        //.ir_out(decode_ir)
    );

    // Instantiate the register file
    reg_file reg_file(
        .clk(clk),
        .write_enable(reg_file_write_enable),//reg_file_write_enable),
        .source1(rs),
        .source2(rt),
        .dest(dest_reg),
        .destVal(wb_data),
        .s1val(dec_A),
        .s2val(dec_B)
    );
    
    // Instantiate the decode module
    decode decoder(
        .clk(clk),
        .stall(stall),
        .insn_in(fetch_ir),
        //.pc_in(pc), // TODO: I don't see what this is needed
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .sha(sha),
        .func(func),
        .immed(immed),
        .target(target),
        .opcode(opcode),
        //.pc_out(pc_out), // TODO: I don't see why this is needed
        .insn_out(insn_out)
    );

// ------------------------------ EXECUTE STAGE --------------------------------------//

    // Instatiate the ID/IX pipeline register
    id_ix_pipleline_reg id_ix_pipleline_reg(
        .clk(clk),
        .stall_in(stall),
        .pc_in(decode_pc),
        .ir_in(decode_ir),
        .A_in(dec_A),
        .B_in(dec_B),
        .alu_op_in(dec_alu_op),
        .is_branch_in(dec_is_branch),
        .is_jump_in(dec_is_jump),
        .op2_sel_in(dec_op2_sel),
        .shift_amount_in(dec_shift_amount),
        .branch_type_in(dec_branch_type),
        .access_size_in(dec_access_size),
        .rw_in(dec_rw),
        .memory_sign_extend_in(dec_memory_sign_extend),
        .res_data_sel_in(dec_res_data_sel),
        .rt_in(dec_rt),
        .rd_in(dec_rd),
        .dest_reg_sel_in(dec_dest_reg_sel),
        .write_to_reg_in(dec_write_to_reg),
        .is_jal_in(dec_is_jal),
        .is_jr_in(dec_is_jr),
        .stall_out(exe_stall_pipeline),
        .pc_out(exe_pc),
        .ir_out(exe_ir),
        .A_out(exe_A),
        .B_out(exe_B),
        .alu_op_out(exe_alu_op),
        .is_branch_out(exe_is_branch),
        .is_jump_out(exe_is_jump),
        .op2_sel_out(exe_op2_sel),
        .shift_amount_out(exe_shift_amount),
        .branch_type_out(exe_branch_type),
        .access_size_out(exe_access_size),
        .rw_out(exe_rw),
        .memory_sign_extend_out(exe_memory_sign_extend),
        .res_data_sel_out(exe_res_data_sel),
        .rt_out(exe_rt),
        .rd_out(exe_rd),
        .dest_reg_sel_out(exe_dest_reg_sel),
        .write_to_reg_out(exe_write_to_reg),
        .is_jal_out(exe_is_jal),
        .is_jr_out(exe_is_jr)
    );

    sign_extender sign_extender(
        .in_data(exe_ir[15:0]),
        .out_data(exe_extended)
    );

    assign exe_shift_target = exe_ir[25:0];
    assign exe_jump_effective_address = (exe_pc & 32'hf0000000) | ((exe_shift_target << 2) & 32'h0fffffff);
    assign exe_shift_immed = exe_extended << 2;
    assign exe_branch_effective_address = exe_shift_immed + exe_pc;

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
        .result(exe_alu_result), // The arithmatic result based on the operation
        .zero(exe_zero), // Indicates if the result of the operation is zero.
        .neg(exe_neg)
    );

    // Instantiate a mux to pass the execution operation result as pc+4 for the JAL instruction
    mux_2_1_32_bit store_pc_mux(
        .line0(exe_alu_result),
        .line1(exe_pc),
        .select(exe_is_jal),
        .output_line(exe_O)
    );

    branch_resolve branch_resolve(
    	.zero(exe_zero),
		.neg(exe_neg),
		.branch_type(exe_branch_type),
		.is_branch(exe_is_branch),
		.branch_taken(exe_branch_taken) // Indicates if the branch is taken or not
    );

    mux_2_1_32_bit branch_next_pc_mux(
        .line0(exe_pc),
        .line1(exe_branch_effective_address),
        .select(exe_branch_taken),
        .output_line(exe_branch_next_pc)
    );

    mux_2_1_32_bit jump_next_pc_mux(
        .line0(exe_branch_next_pc),
        .line1(exe_jump_effective_address),
        .select(exe_is_jump),
        .output_line(exe_jump_next_pc)
    );

    mux_2_1_32_bit jump_ret_next_pc_mux(
        .line0(exe_jump_next_pc),
        .line1(exe_O),
        .select(exe_is_jr),
        .output_line(exe_next_pc)
    );

    assign exe_update_pc = exe_is_jump | exe_branch_taken | exe_is_jr;

// ------------------------------ MEMORY STAGE --------------------------------------//
    
    // Instatiate the IX/IM pipeline register
    ix_im_pipleline_reg ix_im_pipleline_reg(
        .clk(clk),
        .stall_in(exe_stall_pipeline),
        .pc_in(exe_next_pc),
        .O_in(exe_O),
        .B_in(exe_B),
        .access_size_in(exe_access_size),
        .rw_in(exe_rw),
        .memory_sign_extend_in(exe_memory_sign_extend),
        .res_data_sel_in(exe_res_data_sel),
        .rt_in(exe_rt),
        .rd_in(exe_rd),
        .dest_reg_sel_in(exe_dest_reg_sel),
        .write_to_reg_in(exe_write_to_reg),
        .update_pc_in(exe_update_pc),
        .is_jal_in(exe_is_jal),
        .stall_out(mem_stall_pipeline),
        .pc_out(mem_next_pc),
        .O_out(mem_alu_result), // This will be the R-type data to write or EA for mem
        .B_out(mem_reg_data),
        .access_size_out(mem_data_access_size),
        .rw_out(mem_data_rw),
        .memory_sign_extend_out(mem_memory_sign_extend),
        .res_data_sel_out(mem_res_data_sel),
        .rt_out(mem_rt),
        .rd_out(mem_rd),
        .dest_reg_sel_out(mem_dest_reg_sel),
        .write_to_reg_out(mem_write_to_reg),
        .update_pc_out(mem_update_pc),
        .is_jal_out(mem_is_jal)
    );

    // We have some muxes here to write the data memory during SREC parsing
    mux_2_1_32_bit srec_address_mux(
        .line0(mem_alu_result),
        .line1(srec_address),
        .select(srec_parse),
        .output_line(mem_addr_in)
    );
    mux_2_1_32_bit srec_data_data_mux(
        .line0(mem_reg_data),
        .line1(srec_data_in),
        .select(srec_parse),
        .output_line(mem_data_in)
    );
    mux_2_1_1_bit srec_data_rw_mux(
        .line0(mem_data_rw),
        .line1(srec_rw),
        .select(srec_parse),
        .output_line(mem_rw)
    );
    mux_2_1_2_bit srec_data_access_size_mux(
        .line0(mem_data_access_size),
        .line1(srec_access_size),
        .select(srec_parse),
        .output_line(mem_access_size)
    );

    // Instantiate the data memory module
    memory data_memory(
        .data_out(mem_data_out),
        .address(mem_addr_in),
        .data_in(mem_data_in),
        .write(mem_rw),
        .clk(clk),
        .access_size(mem_access_size)
    );

    // Instantiate the sign extender for loading half words and bytes
    memory_sign_extender memory_sign_extender(
        .in_data(mem_data_out),
        .data_size(mem_access_size),
        .sign_extend(mem_memory_sign_extend),
        .out_data(wb_D) //.out_data(mem_sign_extend_out) TODO: This may throw some issues 
                        //when we pipleine... It will be the same for handling the fetch 
                        //and decode memory handoff
    );
    
// ------------------------------ WRITE BACK STAGE --------------------------------------//
    
    // Instatiate the IM/IW pipeline register
    im_iw_pipleline_reg im_iw_pipleline_reg(
        .clk(clk),
        .stall_in(mem_stall_pipeline),
        .pc_in(mem_next_pc),
        .O_in(mem_alu_result),
        //.D_in(mem_sign_extend_out),
        .res_data_sel_in(mem_res_data_sel),
        .write_to_reg_in(mem_write_to_reg),
        .dest_reg_sel_in(mem_dest_reg_sel),
        .rt_in(mem_rt),
        .rd_in(mem_rd),
        .update_pc_in(mem_update_pc),
        .is_jal_in(mem_is_jal),
        .stall_out(wb_stall_pipeline),
        .pc_out(wb_next_pc),
        .O_out(wb_O),
        //.D_out(wb_D),
        .res_data_sel_out(wb_res_data_sel),
        .write_to_reg_out(wb_write_to_reg),
        .dest_reg_sel_out(wb_dest_reg_sel),
        .rt_out(wb_rt),
        .rd_out(wb_rd),
        .update_pc_out(wb_update_pc),
        .is_jal_out(wb_is_jal)
    );

    // Mux for selecting between which data we should be writing back to the register
    mux_2_1_32_bit wb_data_mux(
        .line0(wb_O),
        .line1(wb_D),
        .select(wb_res_data_sel),
        .output_line(wb_data)
    );

    // // Instantiate a mux for selecting which destination to choose
    mux_2_1_5_bit dest_reg_mux(
        .line0(wb_rd),
        .line1(wb_rt),
        .select(wb_dest_reg_sel),
        .output_line(wb_dest_reg)
    );

    // Instantiate a mux for selecting between the destination register in the previous
    // mux or selecting the return address register (31) if we have a JAL
    mux_2_1_5_bit sel_ra_reg_mux(
        .line0(wb_dest_reg),
        .line1(5'd31),
        .select(wb_is_jal),
        .output_line(dest_reg)
    );

    //assign dest_reg = (wb_dest_reg_sel) ? (wb_rd) : (wb_rt)


    // Control
    always @(posedge clk) begin
        flush = 0; // TODO: implement when branching
        reg_file_write_enable = 0;
        if (srec_parse == 0 && stall == 0) begin
            next_pipe_state = 3'b010;
            // ----------- Decode Stage Control Signal Logic --------------------------- //
            dec_illegal_insn = 0;
            dec_dest_reg_sel = 0;
            dec_alu_op = 0;
            dec_op2_sel = 0;
            dec_is_branch = 0;
            dec_is_jump = 0;
            dec_branch_type = 0;
            dec_rw = 0;
            dec_access_size = 0;
            dec_memory_sign_extend = 0;
            dec_res_data_sel = 0;
            dec_write_to_reg = 1;
            dec_rt = rt;
            dec_rd = rd;
            dec_is_jal = 0;
            dec_is_jr = 0;
            dec_reg_source0_stall = 0;
            dec_reg_source1_stall = 0;
            if (((opcode & 6'b111000)>> 3) == 3'h0) begin
                if ((opcode & 6'b000111) == 3'h0) begin
                    // We are in the SPECIAL Opcode encoding table
                    // This is an R-type instruction
                    dec_dest_reg_sel = 0;
                    dec_reg_source0_stall = rs;
                    dec_reg_source1_stall = rt;
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
                        dec_reg_source0_stall = 0; // In a shift operation we only use second operand
                    end
                    else if (func == 6'b000010) begin // SLL
                        dec_alu_op = 5;
                        dec_shift_amount = sha;
                        dec_reg_source0_stall = 0; // In a shift operation we only use second operand
                    end
                    else if (func == 6'b000011) begin // SRA
                        dec_alu_op = 11;
                        dec_shift_amount = sha;
                        dec_illegal_insn = 1;
                        dec_reg_source0_stall = 0; // In a shift operation we only use second operand
                    end
                    else if (func == 6'b101010 || func == 6'b101011) begin// SLT, SLTU
                        dec_alu_op = 6;
                    end
                    else if (func == 6'b001000) begin // JR
                        dec_rt = 0;
                        dec_alu_op = 0; // Essentially just get the return register as the execution output by ading it with the zero reg
                        dec_is_jr = 1;
                        dec_is_jump = 1; // TODO: Check back here if this causes problems
                        dec_write_to_reg = 0;
                        dec_reg_source0_stall = 0;
                        dec_reg_source1_stall = 0;
                    end
                    else begin
                        dec_illegal_insn = 1;
                    end
                end else if (((opcode & 6'b000111)  == 3'd2) || ((opcode & 6'b000111) == 3'd3)) begin
                    // J and JAL instructions
                    // This is J-type instruction
                    dec_dest_reg_sel = 0;
                    dec_is_jump = 1;
                    if (opcode == 6'b000011) begin
                        // JAL instruction
                        dec_res_data_sel = 0;
                        dec_is_jal = 1;
                        dec_write_to_reg = 1;
                    end
                    else begin
                        dec_write_to_reg = 0;
                    end
                end else begin
                    // BEQ, BNE, BLEZ, BGTZ
                    // This is an I-type instruction
                    dec_is_branch = 1;
                    dec_write_to_reg = 0;
                    if (opcode == 6'b000100) begin 
                        // BEQ
                        dec_alu_op = 1; // We want to do a test if the result is zero from a subtract
                        dec_branch_type = 0;
                        dec_reg_source0_stall = rs;
                        dec_reg_source1_stall = rt;
                    end else if (opcode == 6'b000101) begin
                        // BNE
                        dec_alu_op = 1; // We want to do a test if the result is zero from a subtract
                        dec_branch_type = 1;
                        dec_reg_source0_stall = rs;
                        dec_reg_source1_stall = rt;
                    end else if (opcode == 6'b000110) begin
                        // BLEZ
                        // TODO: Test that rt has zero in it
                        dec_illegal_insn = 1;
                        dec_alu_op = 0;
                        dec_branch_type = 2;
                        dec_reg_source0_stall = rs;
                    end else begin
                        // BGTZ
                        // TODO: Test that rt has zero in it
                        dec_illegal_insn = 1;
                        dec_alu_op = 0;
                        dec_branch_type = 3;
                        dec_reg_source0_stall = rs;
                    end
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
                dec_reg_source0_stall = rs;
                dec_write_to_reg = 1;
                dec_dest_reg_sel = 1;
                dec_op2_sel = 1; // We want op2 to be the immediate in the ALU
            end else if (((opcode & 6'b111000)>> 3) == 3'd3) begin
                // No idea?
                dec_dest_reg_sel = 0;
                dec_illegal_insn = 1;
            end else if (((opcode & 6'b111000)>> 3) == 3'd4) begin
                // LB, LH, LWL, LW, LBU, LHU, LWR
                // This is an I-type instruction
                dec_reg_source0_stall = rs;
                dec_dest_reg_sel = 1;
                dec_op2_sel = 1;
                dec_alu_op = 0; // We want to add the value of rs to the immediate
                dec_res_data_sel = 1;
                case (opcode)
                    6'b100000 : begin 
                        dec_access_size = 0; //LB
                        dec_memory_sign_extend = 1;
                    end
                    6'b100001 : begin
                        dec_access_size = 1; //LH
                        dec_memory_sign_extend = 1;
                    end
                    6'b100010 : dec_access_size = 2; //LWL
                    6'b100011 : dec_access_size = 2; //LW
                    6'b100100 : dec_access_size = 0; //LBU
                    6'b100101 : dec_access_size = 1; //LHU
                    6'b100110 : dec_access_size = 2; //LWR
                    default : dec_illegal_insn = 1;
                endcase
            end else if (((opcode & 6'b111000)>> 3) == 3'd5) begin
                // SB, SH, SWL, SW, SWR
                // This is an I-type instruction
                dec_reg_source0_stall = rs;
                dec_reg_source1_stall = rt;
                dec_dest_reg_sel = 1;
                dec_op2_sel = 1;
                dec_alu_op = 0; // We want to add the value of rs to the immediate
                dec_rw = 1; // We want to write to memory when we store
                dec_write_to_reg = 0;
                case (opcode)
                    6'b101000 : dec_access_size = 0; //SB
                    6'b101001 : dec_access_size = 1; //SH
                    6'b101010 : dec_illegal_insn = 1; //dec_access_size = 2; //SWL
                    6'b101011 : dec_access_size = 2; //SW
                    6'b101100 : dec_access_size = 0; //SBU
                    6'b101101 : dec_access_size = 1; //SHU
                    6'b101110 : dec_illegal_insn = 1; //dec_access_size = 2; //SWR
                    default : dec_illegal_insn = 1;
                endcase
            end else begin
                dec_illegal_insn = 1;
            end
        end else if (srec_parse == 1) begin
            dec_reg_source0_stall = 0;
            dec_reg_source1_stall = 0;
            dec_jump_counter = 0;
        end
        if (srec_parse == 0) begin
            // ----------------------- RAW STALL LOGIC ------------------------------- //
            // Get the destination register for the instruction in execution
            exe_dest_reg_stall = (exe_dest_reg_sel) ? (exe_rt) : (exe_rd);
            mem_dest_reg_stall = (mem_dest_reg_sel) ? (mem_rt) : (mem_rd);
            if (decode_pc > 32'h80020004) begin // Hack to not mess up first fetch
                if (dec_reg_source0_stall == exe_dest_reg_stall && dec_reg_source0_stall != 0) begin
                    stall = 1;
                    fetch.pc = pc;
                end
                else if (dec_reg_source0_stall == mem_dest_reg_stall && dec_reg_source0_stall != 0) begin
                    stall = 1;
                    fetch.pc = pc;
                end
                else if (dec_reg_source1_stall == exe_dest_reg_stall && dec_reg_source1_stall != 0) begin
                    stall = 1;
                    fetch.pc = pc;
                end
                else if (dec_reg_source1_stall == mem_dest_reg_stall && dec_reg_source1_stall != 0) begin
                    stall = 1;
                    fetch.pc = pc;
                end
                else if (dec_is_jump || dec_jump_counter != 0) begin
                    if (dec_jump_counter == 0) begin
                        stall = 0; // We want to stall the instruction after the jump
                        dec_jump_counter = dec_jump_counter + 1;
                    end
                    else if (dec_jump_counter <= 3) begin
                        dec_jump_counter = dec_jump_counter + 1;
                        stall = 1;
                        fetch.pc = pc;
                    end else begin
                        dec_jump_counter = 0;
                        stall = 0;
                    end
                end
                else begin
                    stall = 0;
                end
            end
        end
    end

    always @(decode_pc) begin
        if (srec_parse == 0 && stall == 0 && dec_is_jump != 1) begin
            // If we don't have a stall we want to update the decode_ir
            decode_ir = fetch_ir;
        end 
        // if (srec_parse == 0) begin
        //     cur_pipe_state = next_pipe_state;
        //     // case (cur_pipe_state)
        //     //     3'b100 : begin
        //     //         // ----------------- WRITE BACK CONTROL LOGIC -------------------------------- //
        //     //         if (wb_write_to_reg == 1) begin
        //     //             // We need to write the the register so we should set the read write enable and
        //     //             // select the destination reigster then feed the data to the input port.
        //     //             reg_file_write_enable = 1;
        //     //         end
        //     //     end
        //     // endcase
        // end
    end

    always @(wb_write_to_reg or dest_reg or wb_data) begin
        if (wb_write_to_reg == 1'b1) begin // TODO: Might be a problem here?
            reg_file_write_enable = 1;
        end
        else begin
            reg_file_write_enable = 0;
        end
    end

endmodule