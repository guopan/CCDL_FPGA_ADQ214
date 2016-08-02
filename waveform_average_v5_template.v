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
// Module Name:    average4samples_unit
// Revision:       $Revision: 571 $
// Description:    Averaging unit for ADQ114/ADQ112
//                 (4 samples in parallell)
//////////////////////////////////////////////////////////////////////////////////

`include "config.v"

module waveform_average_v5
       #(
           parameter NofParallellSamples = 4,
           parameter BitsIn = 16,
           parameter BitsOut = 32,
           parameter AddressWidth = 16,
           parameter TriggerWidth = NofParallellSamples
       )
       (
           input wire clk_i,
           input wire rst_i,
           input wire [BitsIn*NofParallellSamples-1:0] x_i,
           input wire data_valid_i,
           input wire [TriggerWidth-1:0] trigger_vector_i,
           output reg [(NofParallellSamples*BitsOut/2)-1:0] y_o,
           output reg [(NofParallellSamples*BitsOut)-1:0] y_for_buffer_o,
           output reg data_valid_o, // Denotes the two 32-bit values valid

           input wire [15:0] NofSampleCycles_i,
           input wire [15:0] NofWaveforms_i,
           input wire [15:0] NofHoldoffCycles_i,
           input wire [15:0] NofPreTrigCycles_i,
           input wire [15:0] NofReadoutWaitCycles_i,
           input wire sw_trig_i,
           input wire arm_average_i,
           input wire schedule_shutdown_i,
           input wire bypass_i,
           input wire readout_average_i,
           input wire auto_armnread_i,
           input wire immediate_readout_i,
           input wire enable_level_trig_data_i,
           input wire readout_a_i,
           input wire readout_b_i,
           input wire triggered_streaming_active_i,
           input wire sample_skip_active_i,

           output reg in_idle_o,
           output reg data_available_o,
           output reg [15:0] records_collected_o

       );
endmodule
