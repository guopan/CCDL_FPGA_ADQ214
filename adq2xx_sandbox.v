//////////////////////////////////////////////////////////////////////////////////
// 
// Copyright 2009 Signal Processing Devices Sweden AB. All rights reserved.
//
// Module Name:    adq_alg_top
// Project Name:   ADQ
// Revision:       $Revision: 19752 $
// Description:    ADQ Algorithm FPGA functional top level.
//
//////////////////////////////////////////////////////////////////////////////////
`include "config.v"

module adq2xx_sandbox
  #( parameter NofBits = 16 ) // Number of bits in data interfaces

   ( // AC ADC Interface
    input wire                      ac_clk1x,
    input wire                      ac_clk2x,
    input wire                      rst_i,
    input wire                      ac_clk_locked_i,

    input wire [6:1]                dip_i,

    input wire signed [NofBits-1:0] ac_data_a_i,
    input wire signed [NofBits-1:0] ac_data_az_i,
    input wire                      ac_ovr_a_i,
    input wire                      ac_ovr_az_i,

    input wire signed [NofBits-1:0] ac_data_b_i,
    input wire signed [NofBits-1:0] ac_data_bz_i,
    input wire                      ac_ovr_b_i,
    input wire                      ac_ovr_bz_i,

     // LVDS output interface
    output reg signed [NofBits-1:0] data_a_o,
    output reg signed [NofBits-1:0] data_az_o,
   
    output reg signed [NofBits-1:0] data_b_o,
    output reg signed [NofBits-1:0] data_bz_o, 

    output reg                      data_dry_o, 
   
    input wire [3:0]                trigger_vector_i,
     
     // SPI register file interface
    input wire                      spi_clk_i,
    input wire                      spi_wr_en,
    input wire                      spi_rd_en,
    input wire [14:0]               spi_address,
    output wire [15:0]              spi_data2slave,
    input wire [15:0]               spi_data2reg,

     // User ports
    output wire [1:0]               gpio_o, 
    output wire [1:0]               gpio_z_o, 
   
    output wire [3:1]               led_o, 
    output wire [1:0]               adc_powerdown_o,
    output wire                     idelay_ctrl_ce,
    output wire                     idelay_ctrl_rst,
    output wire                     idelay_ctrl_inc,
	
	  // AFE control signals
    output wire                     afe_relay_ch1_o,
    output wire                     afe_relay_ch2_o,
    output wire                     dcamp_pdwn_ch1_o,
    output wire                     dcamp_pdwn_ch2_o
     );                  

   wire signed [NofBits-1:0]         data_a_gc;
   wire signed [NofBits-1:0]         data_az_gc;
   wire signed [NofBits-1:0]         data_b_gc;
   wire signed [NofBits-1:0]         data_bz_gc;
   
   wire signed [NofBits-1:0]         data_a_gc_d1;
   wire signed [NofBits-1:0]         data_az_gc_d1;
   wire signed [NofBits-1:0]         data_b_gc_d1;
   wire signed [NofBits-1:0]         data_bz_gc_d1;
      

   wire signed [NofBits-1:0]         data_a_userlogicsp;
   wire signed [NofBits-1:0]         data_az_userlogicsp;
   wire signed [NofBits-1:0]         data_b_userlogicsp;
   wire signed [NofBits-1:0]         data_bz_userlogicsp;
   wire						         data_valid_sp;
   
   wire signed [NofBits-1:0]         data_a_skip;
   wire signed [NofBits-1:0]         data_az_skip;
   wire signed [NofBits-1:0]         data_b_skip;
   wire signed [NofBits-1:0]         data_bz_skip;
   wire                              data_valid_skip;
   
   wire signed [NofBits-1:0]         data_a_userlogicdp;
   wire signed [NofBits-1:0]         data_az_userlogicdp;
   wire signed [NofBits-1:0]         data_b_userlogicdp;
   wire signed [NofBits-1:0]         data_bz_userlogicdp;
   wire                              data_valid_userlogicdp;
   
   wire signed [NofBits-1:0]         data_a_packet_streamer;
   wire signed [NofBits-1:0]         data_az_packet_streamer;
   wire signed [NofBits-1:0]         data_b_packet_streamer;
   wire signed [NofBits-1:0]         data_bz_packet_streamer;
   wire                              data_valid_packet_streamer;
   
//   wire signed [NofBits-1:0]         data_a_packet_streamer_d1;
//   wire signed [NofBits-1:0]         data_az_packet_streamer_d1;
//   wire signed [NofBits-1:0]         data_b_packet_streamer_d1;
//   wire signed [NofBits-1:0]         data_bz_packet_streamer_d1;
//   wire                              data_valid_packet_streamer_d1;

   wire signed [NofBits-1:0]         data_a_from_avg;
   wire signed [NofBits-1:0]         data_az_from_avg;
   wire signed [NofBits-1:0]         data_b_from_avg;
   wire signed [NofBits-1:0]         data_bz_from_avg;
   wire                              data_valid_from_avg;

   wire signed [NofBits-1:0]         data_a_dec;
   wire signed [NofBits-1:0]         data_az_dec;
   wire signed [NofBits-1:0]         data_b_dec;
   wire signed [NofBits-1:0]         data_bz_dec;
   wire                              data_valid_dec;

   // reg signed [NofBits-1:0]          data_a_mux;
   // reg signed [NofBits-1:0]          data_az_mux;
   // reg signed [NofBits-1:0]          data_b_mux;
   // reg signed [NofBits-1:0]          data_bz_mux;
   // reg                               data_valid_mux;
   
   wire [15:0]                       sample_skip_value;
   wire  			                       sample_skip_active;
   wire [3:0] 			                 trigger_vector_skip;
   reg [3:0]                         trigger_vector_skip_piped;
   
   wire [8:0]                        decim_ctrl;
   wire [2:0]                        spi_led;
   wire [1:0]                        data_format;
   wire [3:0]                        afe_ctrl;

   wire [16*8-1:0]                   user_register_from_host;
   wire [16*4-1:0]                   user_register_to_host_sp;
   wire [16*4-1:0]                   user_register_to_host_dp;

   wire signed [15:0]                max_code_control_1;
   wire signed [15:0]                min_code_control_1;
   wire signed [15:0]                max_code_control_2;
   wire signed [15:0]                min_code_control_2;

   wire signed [15:0]                gain_control_1;
   wire signed [15:0]                gain_control_2;
   wire signed [15:0]                offset_control_1;
   wire signed [15:0]                offset_control_2;

   wire [15:0] 			     packet_streamer_control;
   wire [15:0] 			     packet_streamer_holdoff_cycles;
   wire [15:0] 			     packet_streamer_pretrig_cycles;
   wire [15:0] 			     packet_streamer_packet_size;
   wire 			           arm_packet_streamer;
   wire 			           bypass_packet_streamer;
    
   wire [15:0]                       average_NofSampleCycles;
   wire [15:0]                       average_NofWaveforms;
   wire [15:0]                       average_NofHoldoffCycles;
   wire [15:0]                       average_NofPreTrigCycles;
   wire [15:0]                       average_NofReadoutWaitCycles;
   wire [15:0]                       average_control;
   wire [15:0]                       debug_counter_control;
   wire [15:0]                       debug_counter_init_value;
   wire [15:0]                       debug_counter_bitwidth;
   wire [15:0]                       trigger_counter_control;
   wire [15:0]                       average_records_collected;
   
   wire                              enable_level_trig_data_average;
   wire                              arm_average;
   wire 			                       schedule_shutdown;
   wire 			                       wfa_in_idle;
   wire                              bypass_average;
   wire                              readout_average;
   wire                              auto_armnread;
   wire                              swtrig_average;
   wire 			                       readout_a;
   wire 			                       readout_b;
   wire 			                       data_available;
   wire                              immediate_readout;
   wire                              triggered_streaming_active;
   wire [3:0]                        trig_modes_enable;
   
   wire [3:0]                        trigger_vector_from_counter;
   wire [3:0]                        trigger_vector_from_userlogic_sp;
   wire [3:0]                        trigger_vector_from_userlogic_dp;
   wire [3:0]                        trigger_vector_from_packetstreamer;
   wire                              debug_counter_enable;
   wire [1:0]                        debug_counter_direction;
   wire [2:0]                        debug_counter_mode;
   wire [2:0]                        debug_counter_output_mode;   
   wire 			     data_available_from_waveform_average;
   
   wire [15:0]                       ul_partnum_1;
   wire [15:0]                       ul_partnum_2;
   wire [15:0]                       ul_partnum_3;
   wire [15:0]                       ul_partnum_rev;
   
   (* SHREG_EXTRACT="NO" *) reg           rst_capture;
   (* SHREG_EXTRACT="NO" *) reg [5:0]     rst_sync;
   
   assign led_o = spi_led;
   assign gpio_o = 2'd0;
   assign gpio_z_o = 2'd0;

   always@(posedge ac_clk1x)
     begin
        rst_capture <= rst_i;
        rst_sync <= {6{rst_capture}};
     end

	// AFE control signals, ensure startup in AC-mode
	assign afe_relay_ch1_o = afe_ctrl[0];
	assign dcamp_pdwn_ch1_o = ~afe_ctrl[2];
	assign afe_relay_ch2_o = afe_ctrl[1];
	assign dcamp_pdwn_ch2_o = ~afe_ctrl[3];
	
   //****************************   
   //** Gain modification stage
   //****************************
   // NofBitsCutOff = 0 for ADQX14
   // NofBitsCutOff = 2 for ADQX12
   // NoiseBit = 0 for ADQX14 (Noise generating bit = LSB)
   // NoiseBit = 2 for ADQX12 (Noise generating bit = LSB)
   gain_control
     #(
       .NofBitsCutOff(0),
       .NoiseBit(0)
       )
   gain_control_inst
     (
      .clk(ac_clk1x),
      .gain_control_1_i(gain_control_1),
      .gain_control_2_i(gain_control_2),
      .offset_control_1_i(offset_control_1),
      .offset_control_2_i(offset_control_2),
      .max_code_control_1_i(max_code_control_1),
      .min_code_control_1_i(min_code_control_1),
      .max_code_control_2_i(max_code_control_2),
      .min_code_control_2_i(min_code_control_2),
      .x0_i(ac_data_a_i),
      .x0z_i(ac_data_az_i),
      .x1_i(ac_data_b_i),
      .x1z_i(ac_data_bz_i),
      .y0_clk_o(data_a_gc),
      .y0z_clk_o(data_az_gc),
      .y1_clk_o(data_b_gc),
      .y1z_clk_o(data_bz_gc)
      );
      
      
   assign debug_counter_output_mode  = debug_counter_control[2:0];    //What to output on each channel
   assign debug_counter_direction = debug_counter_control[4:3];       //Count up or down or both
   assign debug_counter_mode = debug_counter_control[7:5];            //Relation with trigger, see inside module for details
   assign debug_counter_enable  = debug_counter_control[15];

    
  counter_test_pattern_v5
   #(
      .BITSPERSAMPLE(16),
      .PARALLELSAMPLESPERCHANNEL(2),
      .CHANNELS(2)
    )
   counter_test_pattern_alg
   (
    .clk_i(ac_clk1x), 
    .rst_i(rst_sync[0]),                                       //Reset counter to startin point e.i ZERO, ONLY AFFECT COUNTER! Not the data passed thru
    .en_i(debug_counter_enable),                            //If set to low, will hold current counter value, ONLY AFFECT COUNTER!  Not the data passed thru
    .output_mode_i(debug_counter_output_mode), 
    .direction_i(debug_counter_direction),
    .trigger_vector_i(trigger_vector_i),
    .counter_mode_i(debug_counter_mode),
    .constant_value_i(debug_counter_init_value),
    .counter_bitwidth_i(debug_counter_bitwidth),
    .data_valid_i(),
    .data_i({data_bz_gc,data_b_gc, data_az_gc,data_a_gc}),  //Input data to pass thru or to switch between with counter values
    .trigger_vector_o(trigger_vector_from_counter),
    .data_valid_o(),
    .data_o({data_bz_gc_d1, data_b_gc_d1, data_az_gc_d1, data_a_gc_d1})
    );

   //****************************   
   //** UL for signal processing
   //****************************
   user_logic_signal_processing
     #(
       .NofBits(16),
       .NofUserRegistersOut(4)
       )
   user_logic_sp_inst
     (
      .clk_i(ac_clk1x),
      .rst_i(rst_sync[1]),
      .x0_i(data_a_gc_d1),
      .x0z_i(data_az_gc_d1),
      .x1_i(data_b_gc_d1),
      .x1z_i(data_bz_gc_d1),
      .trigger_vector_i(trigger_vector_from_counter),
      .trigger_vector_o(trigger_vector_from_userlogic_sp),
      .y0_o(data_a_userlogicsp),
      .y0z_o(data_az_userlogicsp),
      .y1_o(data_b_userlogicsp),
      .y1z_o(data_bz_userlogicsp),
      .user_register_i(user_register_from_host),
      .user_register_o(user_register_to_host_sp),
      .ul_partnum_1_o(ul_partnum_1),
      .ul_partnum_2_o(ul_partnum_2),
      .ul_partnum_3_o(ul_partnum_3),
      .ul_partnum_rev_o(ul_partnum_rev),
	  .data_valid_o(data_valid_sp)
      );
   

   //****************************   
   //** Sample skip
   //****************************
	
   sample_skip #(.NofBits(NofBits)) sample_skip_inst
     (
      .clk(ac_clk1x),
      .sample_skip_value_i(sample_skip_value),
      .x0_i(data_a_userlogicsp),
      .x0z_i(data_az_userlogicsp),
      .x1_i(data_b_userlogicsp),
      .x1z_i(data_bz_userlogicsp),
      .y0_clk_o(data_a_skip),
      .y0z_clk_o(data_az_skip),
      .y1_clk_o(data_b_skip),
      .y1z_clk_o(data_bz_skip),
      .data_valid_o(data_valid_skip),
      .trigger_vector_i(trigger_vector_from_userlogic_sp),
      .trigger_vector_o(trigger_vector_skip),
      .active_o(sample_skip_active)
      );

   user_logic_data_packaging
     #(
       .NofBits(16),
       .NofUserRegistersOut(4)
       )
   user_logic_dp_inst
     (
      .clk_i(ac_clk1x),
      .rst_i(rst_sync[2]),
      // .x0_i(data_a_skip),
      // .x0z_i(data_az_skip),
      .x0_i(data_a_userlogicsp),
      .x0z_i(data_az_userlogicsp),
      .x1_i(data_b_userlogicsp),
      .x1z_i(data_bz_userlogicsp),
      .data_valid_i(data_valid_sp),
      .trigger_vector_i(trigger_vector_from_counter),
      .trigger_vector_o(trigger_vector_from_userlogic_dp),
      .y0_o(data_a_userlogicdp),
      .y0z_o(data_az_userlogicdp),
      .y1_o(data_b_userlogicdp),
      .y1z_o(data_bz_userlogicdp),
      .data_valid_o(data_valid_userlogicdp),
      .user_register_i(user_register_from_host),
      .user_register_o(user_register_to_host_dp)
      );


   //****************************   
   //** Packet streamer
   //****************************
   assign arm_packet_streamer = packet_streamer_control[0];
   assign bypass_packet_streamer = ~packet_streamer_control[1];

   packet_streamer
     #(.NofBits(NofBits))
   packet_streamer_inst
     (
      .clk_i(ac_clk1x),
      .rst_i(rst_sync[3]),
      .arm_i(arm_packet_streamer),
      .bypass_i(bypass_packet_streamer),
      .packet_size_i(packet_streamer_packet_size),
      .holdoff_cycles_i(packet_streamer_holdoff_cycles),
      .pretrig_cycles_i(packet_streamer_pretrig_cycles),
      .trigger_vector_i(trigger_vector_from_userlogic_dp),
      .sample_skip_trigger_vector_i(trigger_vector_skip),
      .sample_skip_active_i(sample_skip_active),
      .x0_i(data_a_userlogicdp),
      .x1_i(data_b_userlogicdp),
      .x2_i(data_az_userlogicdp),
      .x3_i(data_bz_userlogicdp),
      .data_valid_i(data_valid_userlogicdp),
      .y0_o(data_a_packet_streamer),
      .y1_o(data_b_packet_streamer),
      .y2_o(data_az_packet_streamer),
      .y3_o(data_bz_packet_streamer),
      .trigger_vector_o(trigger_vector_from_packetstreamer),
      .data_valid_o(data_valid_packet_streamer)
      );
   
   assign arm_average = average_control[0];
   assign bypass_average = ~average_control[1];
   assign auto_armnread = average_control[2];
   assign readout_average = average_control[3];
   assign swtrig_average = average_control[4];
   assign enable_level_trig_data_average = average_control[5];
   assign readout_a = ~average_control[6];
   assign readout_b = ~average_control[7];
   assign immediate_readout = average_control[9];
   assign schedule_shutdown = average_control[10];
   assign triggered_streaming_active  = average_control[11];         //This is the so called triggered streaming mode. It means that NO averaging is performed an that the data output is only 16 bits per sample
   //assign trig_modes_enable = average_control[15:12];
  
`ifndef TARGET_LX30T       	
   //****************************
   //** Waveform Averaging unit
   //****************************
  // waveform_average 
  //   waveform_average_inst
  //     (
  //.clk_i(ac_clk1x), 
  //.rst_i(rst_sync), 
  //.x_i({data_bz_packet_streamer,data_az_packet_streamer,data_b_packet_streamer,data_a_packet_streamer}),
  //.data_valid_i(data_valid_packet_streamer),
  //.triggered_streaming_active_i(triggered_streaming_active),
  //.ext_trigger_vector_i(trigger_vector_from_packetstreamer), 
  //.lvl_trigger_vector_i(trigger_vector_from_packetstreamer),  
  //.y_o({data_bz_from_avg, data_az_from_avg,data_b_from_avg, data_a_from_avg}),
  //.trig_modes_enable_i(trig_modes_enable),
  //.y_for_buffer_o(),
  //.data_valid_o(data_valid_from_avg),
  //.NofSampleCycles_i(average_NofSampleCycles), 
  //.NofWaveforms_i(average_NofWaveforms), 
  //.NofHoldoffCycles_i(average_NofHoldoffCycles), 
  //.NofPreTrigCycles_i(average_NofPreTrigCycles),
  //.NofReadoutWaitCycles_i(average_NofReadoutWaitCycles),
  //.sw_trig_i(swtrig_average),
  //.internal_trig_i(|trigger_vector_from_packetstreamer),
  //.trigger_counter_control_i({16'd0, trigger_counter_control}),
  //.arm_average_i(arm_average),
  //.schedule_shutdown_i(schedule_shutdown),
  //.in_idle_o(wfa_in_idle),
  //.bypass_i(bypass_average), 
  //.readout_average_i(readout_average), 
  //.auto_armnread_i(auto_armnread), 
  //.immediate_readout_i(immediate_readout),
  //.data_available_o(data_available_from_waveform_average),
  //.records_collected_o(average_records_collected),
  //.enable_level_trig_data_i(enable_level_trig_data_average),
  //.readout_a_i(readout_a),
  //.readout_b_i(readout_b)
  //);
  
  
  waveform_average_v5
    waveform_average_inst
    (
     .clk_i(ac_clk1x), 
     .rst_i(rst_sync[4]), 
     .x_i({data_bz_packet_streamer, data_az_packet_streamer, data_b_packet_streamer, data_a_packet_streamer}), 
     .triggered_streaming_active_i(triggered_streaming_active),
     .sample_skip_active_i(sample_skip_active),
     .data_valid_i(data_valid_packet_streamer), 
     .trigger_vector_i(trigger_vector_from_packetstreamer), 
     .y_o({data_bz_from_avg, data_az_from_avg, data_b_from_avg, data_a_from_avg}),
     //.y_for_buffer_o(),
     .data_valid_o(data_valid_from_avg),
     .NofSampleCycles_i(average_NofSampleCycles), 
     .NofWaveforms_i(average_NofWaveforms), 
     .NofHoldoffCycles_i(average_NofHoldoffCycles), 
     .NofPreTrigCycles_i(average_NofPreTrigCycles),
     .NofReadoutWaitCycles_i(average_NofReadoutWaitCycles),
     .sw_trig_i(swtrig_average),
     .arm_average_i(arm_average),
     .schedule_shutdown_i(schedule_shutdown),
     .in_idle_o(wfa_in_idle),
     .bypass_i(bypass_average), 
     .readout_average_i(readout_average), 
     .auto_armnread_i(auto_armnread), 
     .immediate_readout_i(immediate_readout),
     .data_available_o(data_available_from_waveform_average),
     .records_collected_o(average_records_collected),
     .enable_level_trig_data_i(enable_level_trig_data_average),
     .readout_a_i(readout_a),
     .readout_b_i(readout_b)
   );  

   //****************************
   //** Decimation Extended IP
   //****************************
   decimation_extended_top decimation_extended_top_inst
     (
      .clk_i(ac_clk1x), 
      .rst_i(rst_sync[5]), 
      .decim_ctrl_i(decim_ctrl[7:0]), 
      .test_ctrl_i(decim_ctrl[8]), 
      .x0_i(data_a_userlogicsp),
      .x0z_i(data_az_userlogicsp),
      .x1_i(data_b_userlogicsp),
      .x1z_i(data_bz_userlogicsp),
      .y0_o(data_a_dec),
      .y0z_o(data_az_dec),
      .y1_o(data_b_dec),
      .y1z_o(data_bz_dec),
      .data_valid_o(data_valid_dec)
      );
`else 
   assign data_a_dec = 16'd0;   
   assign data_az_dec = 16'd0;
   assign data_b_dec = 16'd0;
   assign data_bz_dec = 16'd0;
   assign data_valid_dec = 1'b1;
   
`endif // !`ifndef TARGET_LX30T

   
   // Mux (select decimated data when decimation is enabled, otherwise default to sample skip)
   
   // always@(posedge ac_clk1x)
     // if (decim_ctrl[5])
       // begin
          // data_a_mux <= data_a_dec;
          // data_az_mux <= data_az_dec;
          // data_b_mux <= data_b_dec;
          // data_bz_mux <= data_bz_dec;
          // data_valid_mux <= data_valid_dec;
       // end
     // else
       // begin
          // data_a_mux <= data_a_from_avg;
          // data_az_mux <= data_az_from_avg;
          // data_b_mux <= data_b_from_avg;
          // data_bz_mux <= data_bz_from_avg;
          // data_valid_mux <= data_valid_from_avg;          
       // end
   
   // always@(posedge ac_clk1x)
     // begin
        // case (data_format)
          // default: //2'b00: Packed data (14bit)
            // begin
               // data_az_o <= {4'd0, data_az_mux[13:2]};
               // data_a_o  <= {data_az_mux[1:0], data_a_mux[13:0]};
               // data_bz_o <= {4'd0, data_bz_mux[13:2]};
               // data_b_o  <= {data_bz_mux[1:0], data_b_mux[13:0]};
            // end
          
          // 2'b01: //Unpacked data (14 bit, LSB aligned)
            // begin
               // data_az_o <= data_az_mux;
               // data_a_o  <= data_a_mux;
               // data_bz_o <= data_bz_mux;
               // data_b_o  <= data_b_mux;
            // end
          
          // 2'b10: //Unpacked data (14 bit, MSB aligned)
            // begin
               // data_az_o <= {data_az_mux[13:0],2'd0};
               // data_a_o  <= {data_a_mux[13:0],2'd0};
               // data_bz_o <= {data_bz_mux[13:0],2'd0};
               // data_b_o  <= {data_b_mux[13:0],2'd0};
            // end
          
          // 2'b11: //Unpacked data (32 bit) - for use when decimation filter outputs 32 bit data
            // begin
               // data_az_o <= data_az_mux;
               // data_a_o  <= data_a_mux;
               // data_bz_o <= data_bz_mux;
               // data_b_o  <= data_b_mux;
            // end
          
        // endcase

        // data_dry_o <= data_valid_mux;
        
     // end   

///////////更改了预设的连接，希望屏蔽不需要的模块
   
   always@(posedge ac_clk1x or posedge rst_sync[1])
   if (rst_sync[1])
     begin
	   data_az_o <= 0;
	   data_a_o  <= 0;
	   data_bz_o <= 0;
	   data_b_o  <= 0;

       data_dry_o <= 0;
     end
	else
	 begin
	   data_az_o <= data_az_userlogicsp;
	   data_a_o  <= data_a_userlogicsp;
	   data_bz_o <= data_bz_userlogicsp;
	   data_b_o  <= data_b_userlogicsp;

       data_dry_o <= data_valid_sp;
     end 
	 
	 
   SPI_registers SPI_registers_inst
     (
      .clk_i(spi_clk_i),      
      .wr_en_i(spi_wr_en),
      .rd_en_i(spi_rd_en),
      .address_i(spi_address),
      .data_i(spi_data2reg),
      .data_o(spi_data2slave),
      // Add control ports here
      // User registers asumes that spi_clk_i = ac_clk1x
      //  and that the user registers do not cross between
      //  unrelated clocks.
      .ur_0_i(user_register_to_host_sp[1*16-1:0*16]),
      .ur_1_i(user_register_to_host_sp[2*16-1:1*16]),
      .ur_2_i(user_register_to_host_sp[3*16-1:2*16]),
      .ur_3_i(user_register_to_host_sp[4*16-1:3*16]),
      .ur_4_i(user_register_to_host_dp[1*16-1:0*16]),
      .ur_5_i(user_register_to_host_dp[2*16-1:1*16]),
      .ur_6_i(user_register_to_host_dp[3*16-1:2*16]),
      .ur_7_i(user_register_to_host_dp[4*16-1:3*16]),
      .ur_0_o(user_register_from_host[1*16-1:0*16]),
      .ur_1_o(user_register_from_host[2*16-1:1*16]),
      .ur_2_o(user_register_from_host[3*16-1:2*16]),
      .ur_3_o(user_register_from_host[4*16-1:3*16]),
      .ur_4_o(user_register_from_host[5*16-1:4*16]),
      .ur_5_o(user_register_from_host[6*16-1:5*16]),
      .ur_6_o(user_register_from_host[7*16-1:6*16]),
      .ur_7_o(user_register_from_host[8*16-1:7*16]),
      .ur_dv_o(),
      .max_code_control_1_o(max_code_control_1),
      .min_code_control_1_o(min_code_control_1),
      .max_code_control_2_o(max_code_control_2),
      .min_code_control_2_o(min_code_control_2),
      .gain_control_1_o(gain_control_1),
      .gain_control_2_o(gain_control_2),
      .offset_control_1_o(offset_control_1),
      .offset_control_2_o(offset_control_2),
      .idelay_control_o({idelay_ctrl_ce, idelay_ctrl_rst, idelay_ctrl_inc}),
      .afe_ctrl_o(afe_ctrl),
      .sample_skip_value_o(sample_skip_value),
      .decim_ctrl_o(decim_ctrl),
      .led_o(spi_led),
      .adc_powerdown_o(adc_powerdown_o),
      .data_format_o(data_format),
      .average_status_i({wfa_in_idle,data_available_from_waveform_average}),
      .average_control_o(average_control),
      .debug_counter_control_o(debug_counter_control),
      .debug_counter_init_value_o(debug_counter_init_value),
      //.debug_counter_bitwidth_o(debug_counter_bitwidth),
      //.trigger_counter_control_o(trigger_counter_control),
      .average_NofSampleCycles_o(average_NofSampleCycles),
      .average_NofPreTrigCycles_o(average_NofPreTrigCycles),
      .average_NofHoldoffCycles_o(average_NofHoldoffCycles),
      .average_NofReadoutWaitCycles_o(average_NofReadoutWaitCycles),
      .average_NofWaveforms_o(average_NofWaveforms),
      .average_records_collected_i(average_records_collected),
      .packet_streamer_PacketSize_o(packet_streamer_packet_size),
      .packet_streamer_HoldoffCycles_o(packet_streamer_holdoff_cycles),
      .packet_streamer_PreTrigCycles_o(packet_streamer_pretrig_cycles),
      .packet_streamer_Control_o(packet_streamer_control),
      .ul_partnum_1_i(ul_partnum_1),
      .ul_partnum_2_i(ul_partnum_2),
      .ul_partnum_3_i(ul_partnum_3),
      .ul_partnum_rev_i(ul_partnum_rev)
      );

endmodule
