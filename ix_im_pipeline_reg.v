///////////////////////////////////////////////////////////////////////////////
// Company: University of Waterloo
// Author(s): Jordan Ross, Mustafa Faraj
//
// Created Date: 3/11/2014
// Design Name:
// Module Name: id_ix_pipleline_reg
// Project Name: ECE621_PipelinedProcessor
// Description: This module is the IX/IM pipeline register it will latch the
// the following values.
// 
// Dependencies: None
// 
// Revision:
// 0.01 - File Created.
//
// Additional Comments:
//
///////////////////////////////////////////////////////////////////////////////
module ix_im_pipleline_reg(
    input clk,
    input [31:0]pc_in,
    input [31:0]O_in,
    input [31:0]B_in,
    input [1:0]access_size_in,
    input rw_in,
    input memory_sign_extend_in,
    input res_data_sel_in,
    input [4:0]rt_in,
    input [4:0]rd_in,
    input dest_reg_sel_in,
    input write_to_reg_in,
    output reg [31:0]pc_out,
    output reg [31:0]O_out,
    output reg [31:0]B_out,
    output reg [1:0]access_size_out,
    output reg rw_out,
    output reg memory_sign_extend_out,
    output reg res_data_sel_out,
    output reg [4:0]rt_out,
    output reg [4:0]rd_out,
    output reg dest_reg_sel_out,
    output reg write_to_reg_out
);

    always @(negedge clk) begin
        // write on the negative edge of the clock cycle
        pc_out = pc_in;
        O_out = O_in;
        B_out = B_in;
        access_size_out = access_size_in;
        rw_out = rw_in;
        memory_sign_extend_out = memory_sign_extend_in;
        res_data_sel_out = res_data_sel_in;
        rd_out = rd_in;
        rt_out = rd_in;
        res_data_sel_out = res_data_sel_in;
        write_to_reg_out = write_to_reg_in;
    end
endmodule