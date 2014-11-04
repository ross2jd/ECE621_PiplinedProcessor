///////////////////////////////////////////////////////////////////////////////
// Company: University of Waterloo
// Author(s): Jordan Ross, Mustafa Faraj
//
// Created Date: 3/11/2014
// Design Name:
// Module Name: id_ix_pipleline_reg
// Project Name: ECE621_PipelinedProcessor
// Description: This module is the IM/IW pipeline register it will latch the
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
module im_iw_pipleline_reg(
    input clk,
    input [31:0]pc_in,
    input [31:0]O_in,
    input [31:0]D_in,
    input res_data_sel_in,
    input write_to_reg_in,
    input dest_reg_sel_in,
    input [4:0]rt_in,
    input [4:0]rd_in,
    output reg [31:0]pc_out,
    output reg [31:0]O_out,
    output reg [31:0]D_out,
    output reg res_data_sel_out,
    output reg write_to_reg_out,
    output reg dest_reg_sel_out,
    output reg [4:0]rt_out,
    output reg [4:0]rd_out
);

    always @(negedge clk) begin
        // write on the negative edge of the clock cycle
        pc_out = pc_in;
        O_out = O_in;
        D_out = D_in;
        res_data_sel_out = res_data_sel_in;
        write_to_reg_out = write_to_reg_in;
        dest_reg_sel_out = dest_reg_sel_in;
        rd_out = rd_in;
        rt_out = rd_in;
    end
endmodule