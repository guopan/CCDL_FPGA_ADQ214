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
// Copyright © 2009 Signal Processing Devices Sweden AB. All rights reserved.
//
// Module Name:    adq_alg_top
// Project Name:   ADQ Decimation Extended
// Revision:       $Revision: 1869 $
// Description:    SP Devices Extended Decimation IP top level.
//
//////////////////////////////////////////////////////////////////////////////////
`include "config.v"

module decimation_extended_top
       #( parameter NofBits = 16 ) // Number of bits in data interfaces

       ( // AC ADC Interface
           input  wire                   clk_i,
           input  wire                   rst_i,

           input wire [7:0]              decim_ctrl_i,
           input wire                    test_ctrl_i,

           input  wire signed [NofBits-1:0] x0_i,
           input  wire signed [NofBits-1:0] x0z_i,

           input  wire signed [NofBits-1:0] x1_i,
           input  wire signed [NofBits-1:0] x1z_i,

           // LVDS output interface
           output reg signed [NofBits-1:0]  y0_o,
           output reg signed [NofBits-1:0]  y0z_o,

           output reg signed [NofBits-1:0]  y1_o,
           output reg signed [NofBits-1:0]  y1z_o,

           output reg                       data_valid_o
       );
endmodule
