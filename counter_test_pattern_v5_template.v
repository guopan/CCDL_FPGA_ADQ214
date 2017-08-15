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
// Module Name:    counter test pattern generator for v5 products
// Project Name:   ADQ
// Revision:       $Revision: 19245 $
// Description:    
//
//////////////////////////////////////////////////////////////////////////////////

module counter_test_pattern_v5
  #(
       parameter BITSPERSAMPLE = 16,
       parameter PARALLELSAMPLESPERCHANNEL = 2,
       parameter CHANNELS = 2
    )
    (
      input wire clk_i,
      input wire rst_i,                             //Reset counter to startin point e.i ZERO, ONLY AFFECT COUNTER! Not the data passed thru.
      input wire en_i,                              //If set to low, will hold current counter value, ONLY AFFECT COUNTER!  Not the data passed thru.
      input wire [2:0] output_mode_i,               //Check the case below, chose channel to output counter value or data.
      input wire [1:0] direction_i,                 //Direction for the counter patter. Up only, down only or up and down.
      input wire [BITSPERSAMPLE-1:0] counter_bitwidth_i,
      
      input wire [(PARALLELSAMPLESPERCHANNEL*CHANNELS)-1:0] trigger_vector_i,                                      //Trigger vector to pass thru.
      input wire [2:0] counter_mode_i,
      input wire signed [15:0] constant_value_i,                                                                   //A constant value used in various mode in combination with counter_mode_i.
      input wire data_valid_i,
      input wire [(PARALLELSAMPLESPERCHANNEL*BITSPERSAMPLE*CHANNELS)-1:0] data_i,                                  //Data should be ordered like this: B-MSS, B-LSS, A-MSS, A-LSS
      
      output wire [(PARALLELSAMPLESPERCHANNEL*BITSPERSAMPLE*CHANNELS)-1:0] data_o,
      output reg [(PARALLELSAMPLESPERCHANNEL*CHANNELS)-1:0] trigger_vector_o,
      output reg data_valid_o
    );
endmodule
