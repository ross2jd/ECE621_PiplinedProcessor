///////////////////////////////////////////////////////////////////////////////
// Company: University of Waterloo
// Author(s): Jordan Ross, Mustafa Faraj
//
// Created Date: 23/10/2014
// Design Name:
// Module Name: id_ix_pipleline_reg
// Project Name: ECE621_PipelinedProcessor
// Description: This module is the ID/IX pipeline register it will latch the
// the following values.
// 1. PC
// 2. IR
// 3. A - source 1 value from reg file
// 4. B - source 2 value from reg file
// 
// Dependencies: None
// 
// Revision:
// 0.01 - File Created.
//
// Additional Comments:
//
///////////////////////////////////////////////////////////////////////////////
module id_ix_pipleline_reg(
    input clk,
    input stall_in,
    input flush,
    input [31:0]pc_in,
    input [31:0]ir_in,
    input [31:0]A_in,
    input [31:0]B_in,
    input [5:0]alu_op_in,
    input is_branch_in,
    input is_jump_in,
    input op2_sel_in,
    input [5:0]shift_amount_in,
    input [1:0]branch_type_in,
    input [1:0]access_size_in,
    input rw_in,
    input memory_sign_extend_in,
    input res_data_sel_in,
    input [4:0]rt_in,
    input [4:0]rd_in,
    input dest_reg_sel_in,
    input write_to_reg_in,
    input is_jal_in,
    input is_jr_in,
    output reg stall_out,
    output reg [31:0]pc_out,
    output reg [31:0]ir_out,
    output reg [31:0]A_out,
    output reg [31:0]B_out,
    output reg [5:0]alu_op_out,
    output reg is_branch_out,
    output reg is_jump_out,
    output reg op2_sel_out,
    output reg [5:0]shift_amount_out,
    output reg [1:0]branch_type_out,
    output reg [1:0]access_size_out,
    output reg rw_out,
    output reg memory_sign_extend_out,
    output reg res_data_sel_out,
    output reg [4:0]rt_out,
    output reg [4:0]rd_out,
    output reg dest_reg_sel_out,
    output reg write_to_reg_out,
    output reg is_jal_out,
    output reg is_jr_out
);

    always @(negedge clk) begin
        // write on the negative edge of the clock cycle
        if (stall_in == 0 && flush == 0) begin
            pc_out = pc_in;
            ir_out = ir_in;
            A_out = A_in;
            B_out = B_in;
            alu_op_out = alu_op_in;
            op2_sel_out = op2_sel_in;
            is_branch_out = is_branch_in;
            is_jump_out = is_jump_in;
            shift_amount_out = shift_amount_in;
            branch_type_out = branch_type_in;
            access_size_out = access_size_in;
            rw_out = rw_in;
            memory_sign_extend_out = memory_sign_extend_in;
            res_data_sel_out = res_data_sel_in;
            rd_out = rd_in;
            rt_out = rt_in;
            dest_reg_sel_out = dest_reg_sel_in;
            write_to_reg_out = write_to_reg_in;
            is_jal_out = is_jal_in;
            is_jr_out = is_jr_in;
        end else begin
            pc_out = 0;
            ir_out = 0;
            A_out = 0;
            B_out = 0;
            alu_op_out = 0;
            op2_sel_out = 0;
            is_branch_out = 0;
            is_jump_out = 0;
            shift_amount_out = 0;
            branch_type_out = 0;
            access_size_out = 0;
            rw_out = 0;
            memory_sign_extend_out = 0;
            res_data_sel_out = 0;
            rd_out = 0;
            rt_out = 0;
            dest_reg_sel_out = 0;
            write_to_reg_out = 0;
            is_jal_out = 0;
            is_jr_out = 0;
        end
        stall_out = stall_in;
    end
endmodule