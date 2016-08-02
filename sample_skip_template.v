//********************************************
//********************************************
//**                                        **
//** This template is created automatically **
//** Do not change this file, it is only to **
//** be used as an instatiation template for**
//** a black box.                           **
//**                                        **
//********************************************
//********************************************
//////////////////////////////////////////////////////////////////////////////////
// Company:        Signal Processing Devices AB
// Engineer:       Anders Forslund
//
// Create Date:    2008-10-27
// Module Name:    input_regs
// Description:
//
//////////////////////////////////////////////////////////////////////////////////
`include "config.v"

module sample_skip
       #( parameter NofBits = 16)   // Number of AD bits: 16 for ADQ

       ( // Control & Clocking input
           input wire 			    clk,

           // Signal input
           input wire signed [NofBits-1:0] x0_i,
           input wire signed [NofBits-1:0] x0z_i,
           input wire signed [NofBits-1:0] x1_i,
           input wire signed [NofBits-1:0] x1z_i,

           input wire [15:0] 		    sample_skip_value_i,

           input wire [3:0] 		    trigger_vector_i,
           output reg [3:0] 		    trigger_vector_o,
           output reg 			    active_o,
           (* SHREG_EXTRACT="NO" *) output reg data_valid_o,
           (* SHREG_EXTRACT="NO" *) output reg signed [NofBits-1:0] y0_clk_o,
           (* SHREG_EXTRACT="NO" *) output reg signed [NofBits-1:0] y0z_clk_o,
           (* SHREG_EXTRACT="NO" *) output reg signed [NofBits-1:0] y1_clk_o,
           (* SHREG_EXTRACT="NO" *) output reg signed [NofBits-1:0] y1z_clk_o

       );
endmodule
