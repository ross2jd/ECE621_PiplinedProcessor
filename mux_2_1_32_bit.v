///////////////////////////////////////////////////////////////////////////////
// Company: University of Waterloo
// Author(s): Jordan Ross, Mustafa Faraj
//
// Created Date: 11/10/2014
// Design Name:
// Module Name: mux_2_1_32_bit
// Project Name: ECE621_PipelinedProcessor
// Description: This module is a 2x1 32-bit line mux.
// 
// Dependencies: None
// 
// Revision:
// 0.01 - File Created.
//
// Additional Comments:
//
///////////////////////////////////////////////////////////////////////////////
module mux_2_1_32_bit(
    input [31:0] line0,
    input [31:0] line1,
    input select,
    output reg [31:0] output_line
);

    always @(line0 or line1 or select) begin
        case(select)
            0: output_line = line0;
            1: output_line = line1;
            default: output_line = 32'hx;
        endcase
    end

endmodule