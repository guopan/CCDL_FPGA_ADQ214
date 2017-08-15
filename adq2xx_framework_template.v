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
// Module Name:    adq_alg_fpga 
// Project Name:   ADQ
// Revision:       $Revision: 4990 $
// Description:    Pads and interfaces for algorithm FPGA
//
//////////////////////////////////////////////////////////////////////////////////
`include "config.v"

module adq2xx_framework
  #( parameter NofAdcBits = 14,    // Number of bits in LVDS INPUT interface (AD bits)
     parameter NofLvdsBits = 16,   // Number of bits in LVDS OUTPUT interface
     parameter LvdsOffset = 8192 ) // Should be defined to 2^^(NofAdcBits-1) for Binary Offset data. 0 for 2's complement

   ( // ADC AC interface
     input wire [NofAdcBits-1:0]          lvds_data_a_p_i,
     input wire [NofAdcBits-1:0]          lvds_data_a_n_i,
     input wire [NofAdcBits-1:0]          lvds_data_b_p_i,
     input wire [NofAdcBits-1:0]          lvds_data_b_n_i,
     input wire                           lvds_ovr_a_p_i,
     input wire                           lvds_ovr_a_n_i,
     input wire                           lvds_ovr_b_p_i,
     input wire                           lvds_ovr_b_n_i,
     input wire                           lvds_dclk_a_p_i,
     input wire                           lvds_dclk_a_n_i,
     input wire                           lvds_dclk_b_p_i,
     input wire                           lvds_dclk_b_n_i,

     // Interface to communication fpga
     output wire [NofLvdsBits-1:0]        lvds_data_a_p_o,
     output wire [NofLvdsBits-1:0]        lvds_data_a_n_o,
     output wire                          lvds_dclk_a_p_o,
     output wire                          lvds_dclk_a_n_o,
     output wire [NofLvdsBits-1:0]        lvds_data_b_p_o,
     output wire [NofLvdsBits-1:0]        lvds_data_b_n_o,
     output wire                          lvds_dclk_b_p_o,
     output wire                          lvds_dclk_b_n_o,
     output wire                          lvds_dry_p_o,
     output wire                          lvds_dry_n_o,
   
     input wire                           F_TBD1_p, //alg. fpga pll rst
     output wire                          F_TBD1_n, //comm. fpga dcm rst

     // Trigger vector from comm_fpga
     input wire                           lvds_trig_vector_1_p_i,
     input wire                           lvds_trig_vector_1_n_i,
     input wire                           lvds_trig_vector_2_p_i,
     input wire                           lvds_trig_vector_2_n_i,
     
     // SPI
     input wire                           SCK_i,
     input wire                           SSEL_i,
     input wire                           MOSI_i,
     output wire                          MISO_o,
   
     // misc
     input wire                           clk50_i,
     output wire                          led_o,
    
// ************* Interface to Sandbox *******************************
     input wire signed [NofLvdsBits-1:0]  data_a_i,
     input wire signed [NofLvdsBits-1:0]  data_az_i,
     input wire signed [NofLvdsBits-1:0]  data_b_i,
     input wire signed [NofLvdsBits-1:0]  data_bz_i, 
     input wire                           data_dry_i, 
   
     // SPI register file interface
     output wire                          spi_clk_o,
     output wire                          spi_wr_en,
     output wire                          spi_rd_en,
     output wire [14:0]                   spi_address,
     output wire [15:0]                   spi_data2reg,
     input wire [15:0]                    spi_data2slave,

     // User ports
     input wire [1:0]                     gpio_i, 
     input wire [1:0]                     gpio_z_i, 
   
     input wire                           idelay_ctrl_ce,
     input wire                           idelay_ctrl_rst,
     input wire                           idelay_ctrl_inc,
	
// ************* Interface from Sandbox *****************************
     output wire                          ac_clk1x,
     output wire                          ac_clk2x,
     output wire                          ac_clk_locked_o,

     output wire signed [NofLvdsBits-1:0] ac_data_a_o,
     output wire signed [NofLvdsBits-1:0] ac_data_az_o,
     output wire                          ac_ovr_a_o,
     output wire                          ac_ovr_az_o,

     output wire signed [NofLvdsBits-1:0] ac_data_b_o,
     output wire signed [NofLvdsBits-1:0] ac_data_bz_o,
     output wire                          ac_ovr_b_o,
     output wire                          ac_ovr_bz_o,
    
     output wire [3:0]                    trigger_vector_o,
     output wire                          rst_logic_o                   
    
     );
endmodule
