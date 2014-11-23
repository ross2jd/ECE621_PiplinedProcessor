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
    reg flush;
    wire [1:0]insn_access_size;
    wire [1:0]fetch_access_size;
    wire fetch_rw;
    wire insn_rw;
    reg reg_file_write_enable;
    reg next_insn_is_nop;
    
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
    wire [31:0]pre_fetch_ir;
    wire [31:0]fetch_ir;

    // Decode wires
    wire [31:0]decode_pc; // We define this as the PC for next instruction to be executed
    reg [31:0]decode_ir; // We define this as the current instruction being decoded
    wire [31:0]dec_A;
    wire [31:0]dec_B;
    wire [4:0]dest_reg;
    reg [4:0]reg_file_dest_reg;
    reg [31:0]reg_file_dest_val;
    wire update_pc;
    wire [31:0]next_pc;

    // Decode control signals
    reg dec_dest_reg_sel;
    reg dec_illegal_insn;
    reg [5:0] dec_alu_op;
    reg dec_is_branch;
    reg dec_op2_sel;
    reg [5:0] dec_shift_amount;
    reg [2:0]dec_branch_type; // 0-BEQ, 1-BNE, 2-BLEZ, 3-BGTZ
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
    reg dec_mx_op1_bypass;
    reg dec_mx_op2_bypass;
    reg dec_wx_op1_bypass;
    reg dec_wx_op2_bypass;
    reg dec_wm_data_bypass;
    reg dec_is_load;
    reg [3:0]debug_signal_path_taken;

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
    wire [2:0]exe_branch_type;
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
    wire [31:0]alu_mx_op1_bypass;
    wire [31:0]alu_mx_op2_bypass;
    wire [31:0]alu_op2_bypass;
    wire [31:0]alu_op1_bypass;
    wire mx_op1_bypass;
    wire mx_op2_bypass;
    wire wx_op1_bypass;
    wire wx_op2_bypass;
    wire exe_wm_data_bypass;
    wire exe_is_load;
    wire [31:0]exe_cur_pc;

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
    wire [31:0]mem_data_bypass;
    wire wm_data_bypass;

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
    
    // Mux that selects if the pc should be updated based on if the update is happening in the memory or execute stage
    assign update_pc = (exe_is_jal | mem_is_jal) ? (mem_update_pc) : (exe_update_pc);

    // Mux that selects the next pc based on if the new pc is read in the memory or execute stage.
    assign next_pc = (exe_is_jal | mem_is_jal) ? (mem_next_pc) : (exe_next_pc);

    // Instantiate the fetch module to control what instruction we fetch each clock cycle.
    fetch fetch(
        .clk_in(clk),
        .stall_in(stall),
        .pc_in(next_pc),
        .update_pc(update_pc),
        .pc_out(pc),
        .next_pc(fetch_next_pc),
        .rw_out(fetch_rw),
        .access_size_out(fetch_access_size)
    );
    
    // Instantiate the instruction memory module
    //  - We pass the read instruction directly to the decode stage instead of latching it in
    //    the pipeline register since the read from memory wont be done until the end of the
    //    clock cycle.
    memory insn_memory(
        .data_out(pre_fetch_ir),
        .address(insn_address),
        .data_in(srec_data_in), // We can tie the srec_data_in wire to this port since we never write to insn memory during processor execution
        .write(insn_rw),
        .clk(clk),
		.access_size(insn_access_size)
    );

// ------------------------------ DECODE STAGE --------------------------------------//

    // Instatiate the IF/ID pipeline register to kep the PC and IR
    if_id_pipleline_reg if_id_pipleline_reg(
        .clk(clk),
        .pc_in(fetch_next_pc),
        .pc_out(decode_pc)
    );

    // Instantiate the register file
    //    - The source ports will be read from in the decode stage.
    //    - The destination port will be wrote to in the writeback stage if the write_enable is high.
    reg_file reg_file(
        .clk(clk),
        .write_enable(reg_file_write_enable),
        .source1(rs),
        .source2(rt),
        .dest(reg_file_dest_reg),
        .destVal(reg_file_dest_val),
        .s1val(dec_A),
        .s2val(dec_B)
    );

    // Mux to select whether to give the decode IR a NOP or the instruction at the current PC.
    // This is used when we are branching and jumping.
    assign fetch_ir = (next_insn_is_nop) ? (32'h0) : (pre_fetch_ir);
    
    // Instantiate the decode module that will split the instruction in the instruction fields
    // to be used in the later stages and control.
    decode decoder(
        .insn_in(decode_ir),
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .sha(sha),
        .func(func),
        .immed(immed),
        .target(target),
        .opcode(opcode)
    );

// ------------------------------ EXECUTE STAGE --------------------------------------//

    // Simple or gate to set the flush signal high if we have a branch or a jump in the pipeline.
    assign exe_flush_pipeline = exe_branch_taken | exe_is_jump;
    
    // Instatiate the ID/IX pipeline register
    //  - This pipeline register is very large because we are setting pretty much all of our
    //    control signals for the instruction as it goes through the pipeline in the decode
    //    stage so we need to propogate the control through.
    //  - The pipeline register will output a NOP if either the stall or flush signal is high.
    id_ix_pipleline_reg id_ix_pipleline_reg(
        .clk(clk),
        .stall_in(stall),
        .flush(exe_flush_pipeline),
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
        .mx_op1_bypass_in(dec_mx_op1_bypass),
        .mx_op2_bypass_in(dec_mx_op2_bypass),
        .wx_op1_bypass_in(dec_wx_op1_bypass),
        .wx_op2_bypass_in(dec_wx_op2_bypass),
        .wm_data_bypass_in(dec_wm_data_bypass),
        .is_load_in(dec_is_load),
        .cur_pc_in(insn_address),
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
        .is_jr_out(exe_is_jr),
        .mx_op1_bypass_out(mx_op1_bypass),
        .mx_op2_bypass_out(mx_op2_bypass),
        .wx_op1_bypass_out(wx_op1_bypass),
        .wx_op2_bypass_out(wx_op2_bypass),
        .wm_data_bypass_out(exe_wm_data_bypass),
        .is_load_out(exe_is_load),
        .cur_pc_out(exe_cur_pc)
    );

    // Instantiate the sign extender module to extend the immediate portion of the IR to 32 bits.
    sign_extender sign_extender(
        .in_data(exe_ir[15:0]),
        .out_data(exe_extended)
    );

    // Split the bits our for the target field of the IR.
    assign exe_shift_target = exe_ir[25:0];
    // Calculate the effective address for a jump by taking the target value and shifting it by 2 then
    // concatenating it with the upper 4 bits of the PC.
    assign exe_jump_effective_address = (exe_pc & 32'hf0000000) | ((exe_shift_target << 2) & 32'h0fffffff);
    // Shift the extended immediate value by 2 for branching
    assign exe_shift_immed = exe_extended << 2;
    // Calcualte the effective address by taking the shifted sign extended immediate and adding it to PC + 4
    assign exe_branch_effective_address = exe_shift_immed + exe_cur_pc;

    // Instantiate a 32-bit mux for selecting which operand to provide to op2 of the ALU
    //  - This is selecting between the register value or the immediate value for operand 2
    mux_2_1_32_bit alu_op2_sel_mux(
        .line0(alu_op2_bypass),
        .line1(exe_extended),
        .select(exe_op2_sel),
        .output_line(exe_op2)
    );

    // Instantiate the ALU
    alu alu(
        .op1(alu_op1_bypass), // operand 1
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

    // Instantiate the branch resolve unit that will determine if a branch is taken or not based
    // on its branch type and the negative and zero values from the ALU.
    branch_resolve branch_resolve(
    	.zero(exe_zero),
		.neg(exe_neg),
		.branch_type(exe_branch_type),
		.is_branch(exe_is_branch),
		.branch_taken(exe_branch_taken) // Indicates if the branch is taken or not
    );

    // Instantiate a mux to select between PC+4 or the branch effective address based on whether
    // the branch was taken or not.
    mux_2_1_32_bit branch_next_pc_mux(
        .line0(exe_pc),
        .line1(exe_branch_effective_address),
        .select(exe_branch_taken),
        .output_line(exe_branch_next_pc)
    );

    // Instantiate a mux to select between the previous mux (branch EA/PC+4) and the jump
    // effective address based on if the instruction is a jump.
    mux_2_1_32_bit jump_next_pc_mux(
        .line0(exe_branch_next_pc),
        .line1(exe_jump_effective_address),
        .select(exe_is_jump),
        .output_line(exe_jump_next_pc)
    );

    // Instantiate a mux that selects between taking the jump effective address calculated or
    // the address from the alu which is the value store in $ra based on if the instruction is
    // a jump return or not.
    mux_2_1_32_bit jump_ret_next_pc_mux(
        .line0(exe_jump_next_pc),
        .line1(exe_O),
        .select(exe_is_jr),
        .output_line(exe_next_pc)
    );

    // An OR gate to set the execute update pc control signal.
    assign exe_update_pc = exe_is_jump | exe_branch_taken | exe_is_jr;

// ------------------------------ BYPASS HARDWARE -----------------------------------//
    // The following muxes are to chose between taking the value from the register file/alu result
    // or from one of the bypass paths based on the control signal that is set.
    assign alu_mx_op1_bypass = (mx_op1_bypass) ? (mem_alu_result) : (exe_A);
    assign alu_op1_bypass = (wx_op1_bypass) ? (reg_file_dest_val) : (alu_mx_op1_bypass);
    assign alu_mx_op2_bypass = (mx_op2_bypass) ? (mem_alu_result) : (exe_B);
    assign alu_op2_bypass = (wx_op2_bypass) ? (reg_file_dest_val) : (alu_mx_op2_bypass);
    assign mem_data_bypass = (wm_data_bypass) ? (reg_file_dest_val) : (mem_reg_data);

// ------------------------------ MEMORY STAGE --------------------------------------//
    
    // Instatiate the IX/IM pipeline register
    ix_im_pipleline_reg ix_im_pipleline_reg(
        .clk(clk),
        .stall_in(exe_stall_pipeline),
        .pc_in(exe_next_pc),
        .O_in(exe_O),
        .B_in(alu_op2_bypass),
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
        .wm_data_bypass_in(exe_wm_data_bypass),
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
        .is_jal_out(mem_is_jal),
        .wm_data_bypass_out(wm_data_bypass)
    );

    // We have some muxes here to write the data memory during SREC parsing
    mux_2_1_32_bit srec_address_mux(
        .line0(mem_alu_result),
        .line1(srec_address),
        .select(srec_parse),
        .output_line(mem_addr_in)
    );
    mux_2_1_32_bit srec_data_data_mux(
        .line0(mem_data_bypass),
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
    //  - We pass the data that we read from the memory directly to the writeback stage instead
    //    of latching it in the pipeline register since the data wont be read until the end of
    //    the clock cycle.
    memory_sign_extender memory_sign_extender(
        .in_data(mem_data_out),
        .data_size(mem_access_size),
        .sign_extend(mem_memory_sign_extend),
        .out_data(wb_D)
    );
    
// ------------------------------ WRITE BACK STAGE --------------------------------------//
    
    // Instatiate the IM/IW pipeline register
    im_iw_pipleline_reg im_iw_pipleline_reg(
        .clk(clk),
        .stall_in(mem_stall_pipeline),
        .pc_in(mem_next_pc),
        .O_in(mem_alu_result),
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
        .res_data_sel_out(wb_res_data_sel),
        .write_to_reg_out(wb_write_to_reg),
        .dest_reg_sel_out(wb_dest_reg_sel),
        .rt_out(wb_rt),
        .rd_out(wb_rd),
        .update_pc_out(wb_update_pc),
        .is_jal_out(wb_is_jal)
    );

    // A mux to select which source of data it should chose to write back based on control
    assign wb_data = (wb_res_data_sel) ? (wb_D) : (wb_O);
    // A mux to select which destination register to select based on control
    assign wb_dest_reg = (wb_dest_reg_sel) ? (wb_rt) : (wb_rd);
    // A mux to select if to chose the previously set destination register or $ra based on
    // if we have a JAL instruction.
    assign dest_reg = (wb_is_jal) ? (5'd31) : (wb_dest_reg);

// --------------------------- Control -------------------------------------------------//
    // Here is where we do all of our control on the clock cycles. These are the control signals
    // that we are setting based on some inputs.
    always @(posedge clk) begin
        flush = 0;
        reg_file_write_enable = 0;
        dec_mx_op1_bypass = 0;
        dec_mx_op2_bypass = 0;
        dec_wx_op1_bypass = 0;
        dec_wx_op2_bypass = 0;
        dec_wm_data_bypass = 0;
        if (srec_parse == 0 && stall == 0) begin
            // ----------- ----Decode Stage Control Signal Logic --------------------------- //
            // Here is the meat of our control logic. This is where we determine which instruction
            // we have just fetched and then set as much control for this instruction as we can
            // so that it control can be pipelined through the registers.

            // Initial values for the control signals.
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
            dec_mx_op1_bypass = 0;
            dec_mx_op2_bypass = 0;
            dec_wx_op1_bypass = 0;
            dec_wx_op2_bypass = 0;
            dec_wm_data_bypass = 0;
            dec_is_load = 0;
            debug_signal_path_taken = 0;

            // Control logic basedo on instruction fetched.
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
                    else if (func == 6'b000100) begin // SLLV
                        dec_alu_op = 13;
                    end
                    else if (func == 6'b000011) begin // SRA
                        dec_alu_op = 11;
                        dec_shift_amount = sha;
                        dec_reg_source0_stall = 0; // In a shift operation we only use second operand
                    end
                    else if (func == 6'b101010 || func == 6'b101011) begin// SLT, SLTU
                        dec_alu_op = 6;
                    end
                    else if (func == 6'b001000) begin // JR
                        dec_rt = 0;
                        dec_alu_op = 0; // Essentially just get the return register as the execution output by ading it with the zero reg
                        dec_is_jr = 1;
                        dec_is_jump = 1;
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
                        dec_alu_op = 0;
                        dec_branch_type = 2;
                        dec_reg_source0_stall = rs;
                    end else if (opcode == 6'b000001 && rt == 5'b00001) begin
                        // BGEZ
                        dec_alu_op = 0; // We want to do a test if the result is zero from a subtract
                        dec_rt = 0;
                        dec_branch_type = 4;
                        dec_reg_source0_stall = rs;
                        dec_reg_source1_stall = 0;
                        dec_illegal_insn = 1;
                    end else begin
                        // BGTZ
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
                dec_dest_reg_sel = 0;
                dec_reg_source0_stall = rs;
                dec_reg_source1_stall = rt;
                if (func == 6'b000010 && opcode == 6'b011100) begin// MUL
                    dec_alu_op = 2; // Do an multiply operation
                end
                else begin
                    dec_illegal_insn = 1;
                end
            end else if (((opcode & 6'b111000)>> 3) == 3'd4) begin
                // LB, LH, LWL, LW, LBU, LHU, LWR
                // This is an I-type instruction
                dec_reg_source0_stall = rs;
                dec_dest_reg_sel = 1;
                dec_op2_sel = 1;
                dec_alu_op = 0; // We want to add the value of rs to the immediate
                dec_res_data_sel = 1;
                dec_is_load = 1;
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
            // This where we will test the registers that our instruction will need based on the
            // registers that the instructions currently in the pipeline are using. The forwarding
            // signals will be set here as well as signaling for stalls if need be.

            // Get the destination register for the instruction in execution
            exe_dest_reg_stall = (exe_dest_reg_sel) ? (exe_rt) : (exe_rd);
            mem_dest_reg_stall = (mem_dest_reg_sel) ? (mem_rt) : (mem_rd);
            if (decode_pc > 32'h80020004) begin // We don't want any of this logic being set for the first instruction
                stall = 0; // Reset the stall to zero so we don't stall forever
                if (dec_reg_source0_stall == exe_dest_reg_stall && dec_reg_source0_stall != 0 && exe_is_load != 0) begin
                    // We have a load-use stall here
                    stall = 1;
                end
                if (dec_reg_source0_stall == exe_dest_reg_stall && dec_reg_source0_stall != 0 && exe_is_load == 0) begin
                    dec_mx_op1_bypass = 1;
                end
                if (dec_reg_source0_stall == mem_dest_reg_stall && dec_reg_source0_stall != 0 && dec_mx_op1_bypass == 0) begin
                    dec_wx_op1_bypass = 1;
                end
                if (dec_reg_source1_stall == exe_dest_reg_stall && dec_reg_source1_stall != 0 && exe_is_load != 0) begin
                    // We have a load-use stall here
                    stall = 1;
                end
                if (dec_reg_source1_stall == exe_dest_reg_stall && dec_reg_source1_stall != 0 && exe_is_load == 0) begin
                    dec_mx_op2_bypass = 1;
                end
                if (dec_reg_source1_stall == mem_dest_reg_stall && dec_reg_source1_stall != 0 && dec_mx_op2_bypass == 0) begin
                    dec_wx_op2_bypass = 1;
                end
            end

            // ---------------------- BRANCH FLUSH LOGIC --------------------------- //
            if (exe_branch_taken == 1'b1 || exe_is_jump == 1'b1 || mem_is_jal == 1'b1) begin
                // If we have a taken branch we want the fetched instruction to be a NOP.
                next_insn_is_nop = 1;
            end
            else begin
                next_insn_is_nop = 0;
            end
        end
    end

    // Control to not update the decode IR if we have a stall since we have already started
    // reading the instruction from memory by the time we stall.
    always @(fetch.pc) begin // We want be sensitive the the fetch.pc
        if (srec_parse == 0 && stall == 0) begin
            // If we don't have a stall we want to update the decode_ir
            decode_ir = fetch_ir;
        end
        if (exe_branch_taken == 1'b1) begin
            decode_ir = 32'b0;
        end
    end

    // Control to select whether we should be updating the register file or not.
    always @(dest_reg or wb_data or wb_write_to_reg) begin
        if (wb_write_to_reg == 1'b1) begin
            reg_file_write_enable = 1;
            reg_file_dest_reg = dest_reg;
            reg_file_dest_val = wb_data;
        end
        else begin
            reg_file_write_enable = 0;
        end
    end

endmodule