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
//
// Copyright © 2011 Signal Processing Devices Sweden AB. All rights reserved.
//
// Module Name:    packet streamer
// Revision:       $Revision: 571 $
// Description:    Packet streamer for ADQ V5
//                 (4 samples in parallell)
//////////////////////////////////////////////////////////////////////////////////

`include "config.v"

module packet_streamer
  #(
    parameter NofBits = 16
    )
   (
    input wire 		     clk_i,
    input wire 		     rst_i,
    input wire [NofBits-1:0] x0_i,
    input wire [NofBits-1:0] x1_i,
    input wire [NofBits-1:0] x2_i,
    input wire [NofBits-1:0] x3_i,
    input wire 		     data_valid_i, 
    input wire [3:0] 	     trigger_vector_i,
    input wire [3:0] 	     sample_skip_trigger_vector_i,
    input wire 		     sample_skip_active_i,
    output reg [NofBits-1:0] y0_o,
    output reg [NofBits-1:0] y1_o,
    output reg [NofBits-1:0] y2_o,
    output reg [NofBits-1:0] y3_o,
    output reg 		     data_valid_o,
    output reg [3:0]     trigger_vector_o,

    input wire [15:0] 	     packet_size_i,
    input wire [15:0] 	     holdoff_cycles_i,
    input wire [15:0]        pretrig_cycles_i,
    input wire 		     bypass_i,
    input wire 		     arm_i
    );
endmodule
