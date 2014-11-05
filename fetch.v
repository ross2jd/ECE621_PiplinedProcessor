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
module fetch(
    input clk_in,           // Clock signal for the fetch module
    input stall_in,         // Indicates a stall
    output reg [31:0]pc_out,    // Supplies the address in the PC register to the address input of the MM and decode stage
    output reg [31:0]next_pc,   // Supply the next PC
    output reg rw_out,          // Indicates whether the fetch stage is performing a read or write to MM
    output reg [1:0]access_size_out  // Supplies the size of the word that is being accessed by the fetch module
);
    
    reg [31:0]pc = 0; // The PC register
    
    always @(posedge clk_in) begin
        pc_out = pc;
        rw_out = 0;
        access_size_out = 2'b10;
    end
    always @(negedge clk_in) begin
        // On the negative edge we will update the pc if we don't have a stall.
        next_pc = pc + 4;
        case(stall_in)
            0:  begin
                    // Increment the pc by 4 so we read the next 
                    // instruction on the next clock cycle.
                    pc = next_pc;
                end
            1:  begin
                    // TODO: Stalls not implemented
                    pc = pc;
                end
            default:    begin
                            $display("Unknown signal!");
                        end
        endcase
    end
endmodule