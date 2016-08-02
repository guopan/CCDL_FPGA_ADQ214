//////////////////////////////////////////////////////////////////////////////////
//
// Copyright © 2009 Signal Processing Devices Sweden AB. All rights reserved.
//
// Module Name:    adq_alg_fpga
// Project Name:   ADQ
// Revision:       $Revision: 11838 $
// Description:    Pads and interfaces for algorithm FPGA
//
//////////////////////////////////////////////////////////////////////////////////
`include "config.v"

module adq_alg_fpga
       #(
           parameter NofAdcBits = 14,    // Number of bits in LVDS INPUT interface (AD bits)
           parameter NofLvdsBits = 16,   // Number of bits in LVDS OUTPUT interface
           parameter LvdsOffset = 8192 ) // Should be defined to 2^^(NofAdcBits-1) for Binary Offset data. 0 for 2's complement

       ( // ADC AC interface
           input wire [NofAdcBits-1:0]   lvds_data_a_p_i,
           input wire [NofAdcBits-1:0]   lvds_data_a_n_i,
           input wire [NofAdcBits-1:0]   lvds_data_b_p_i,
           input wire [NofAdcBits-1:0]   lvds_data_b_n_i,
           input wire                    lvds_ovr_a_p_i,
           input wire                    lvds_ovr_a_n_i,
           input wire                    lvds_ovr_b_p_i,
           input wire                    lvds_ovr_b_n_i,
           input wire                    lvds_dclk_a_p_i,
           input wire                    lvds_dclk_a_n_i,
           input wire                    lvds_dclk_b_p_i,
           input wire                    lvds_dclk_b_n_i,

           output wire                   pdwn_a_o,
           output wire                   pdwn_b_o,

           // Interface to communication fpga
           output wire [NofLvdsBits-1:0] lvds_data_a_p_o,
           output wire [NofLvdsBits-1:0] lvds_data_a_n_o,
           output wire                   lvds_dclk_a_p_o,
           output wire                   lvds_dclk_a_n_o,
           output wire [NofLvdsBits-1:0] lvds_data_b_p_o,
           output wire [NofLvdsBits-1:0] lvds_data_b_n_o,
           output wire                   lvds_dclk_b_p_o,
           output wire                   lvds_dclk_b_n_o,
           output wire                   lvds_dry_p_o,
           output wire                   lvds_dry_n_o,

           input wire                    F_TBD1_p, //alg. fpga pll rst
           output wire                   F_TBD1_n, //comm. fpga dcm rst

           // Trigger vector from comm_fpga
           input wire                    lvds_trig_vector_1_p_i,
           input wire                    lvds_trig_vector_1_n_i,
           input wire                    lvds_trig_vector_2_p_i,
           input wire                    lvds_trig_vector_2_n_i,

           // SPI
           input wire                    SCK_i,
           input wire                    SSEL_i,
           input wire                    MOSI_i,
           output wire                   MISO_o,

           // misc
           input wire                    clk50_i,
           input wire [5:0]              dip_i,
           output wire [3:0]             led_o,

           // AFE control signals
           output wire                   afe_relay_ch1_o,
           output wire                   afe_relay_ch2_o,
           output wire                   dcamp_pdwn_ch1_o,
           output wire                   dcamp_pdwn_ch2_o
       );
wire                            ac_clk1x;
wire                            ac_clk2x;
wire                            rst_logic_to_sandbox;
wire                            ac_clk_locked_to_sandbox;

wire signed [NofLvdsBits-1:0]   ac_data_a_to_sandbox;
wire signed [NofLvdsBits-1:0]   ac_data_az_to_sandbox;
wire                            ac_ovr_a_to_sandbox;
wire                            ac_ovr_az_to_sandbox;
wire signed [NofLvdsBits-1:0]   ac_data_b_to_sandbox;
wire signed [NofLvdsBits-1:0]   ac_data_bz_to_sandbox;
wire                            ac_ovr_b_to_sandbox;
wire                            ac_ovr_bz_to_sandbox;
wire signed [NofLvdsBits-1:0]   data_a_from_sandbox;
wire signed [NofLvdsBits-1:0]   data_az_from_sandbox;
wire signed [NofLvdsBits-1:0]   data_b_from_sandbox;
wire signed [NofLvdsBits-1:0]   data_bz_from_sandbox;
wire                            data_dry_from_sandbox;
wire [3:0]                      trigger_vector_to_sandbox;
wire                            spi_clk;
wire                            spi_wr_en;
wire                            spi_rd_en;
wire [14:0]                     spi_address;
wire [15:0]                     spi_data2slave;
wire [15:0]                     spi_data2reg;
wire [1:0]                      gpio_from_sandbox;
wire [1:0]                      gpio_z_from_sandbox;
wire [1:0]                      adc_powerdown;
wire                            idelay_ctrl_ce;
wire                            idelay_ctrl_rst;
wire                            idelay_ctrl_inc;
wire [3:0]                      led_n;

assign led_o = ~led_n;

assign pdwn_a_o = adc_powerdown[0];
assign pdwn_b_o = adc_powerdown[1];

adq2xx_framework
    #(
        .NofAdcBits(NofAdcBits),     // Number of bits in LVDS INPUT interface (AD bits)
        .NofLvdsBits(NofLvdsBits),   // Number of bits in LVDS OUTPUT interface
        .LvdsOffset(LvdsOffset)      // Should be defined to 2^^(NofAdcBits-1) for Binary Offset data. 0 for 2's complement
    )
    adq2xx_framework_inst
    (
        .lvds_data_a_p_i(lvds_data_a_p_i),
        .lvds_data_a_n_i(lvds_data_a_n_i),
        .lvds_data_b_p_i(lvds_data_b_p_i),
        .lvds_data_b_n_i(lvds_data_b_n_i),
        .lvds_ovr_a_p_i(lvds_ovr_a_p_i),
        .lvds_ovr_a_n_i(lvds_ovr_a_n_i),
        .lvds_ovr_b_p_i(lvds_ovr_b_p_i),
        .lvds_ovr_b_n_i(lvds_ovr_b_n_i),
        .lvds_dclk_a_p_i(lvds_dclk_a_p_i),
        .lvds_dclk_a_n_i(lvds_dclk_a_n_i),
        .lvds_dclk_b_p_i(lvds_dclk_b_p_i),
        .lvds_dclk_b_n_i(lvds_dclk_b_n_i),

        // Interface to communication fpga
        .lvds_data_a_p_o(lvds_data_a_p_o),
        .lvds_data_a_n_o(lvds_data_a_n_o),
        .lvds_dclk_a_p_o(lvds_dclk_a_p_o),
        .lvds_dclk_a_n_o(lvds_dclk_a_n_o),
        .lvds_data_b_p_o(lvds_data_b_p_o),
        .lvds_data_b_n_o(lvds_data_b_n_o),
        .lvds_dclk_b_p_o(lvds_dclk_b_p_o),
        .lvds_dclk_b_n_o(lvds_dclk_b_n_o),
        .lvds_dry_p_o(lvds_dry_p_o),
        .lvds_dry_n_o(lvds_dry_n_o),

        .F_TBD1_p(F_TBD1_p), //alg. fpga pll rst
        .F_TBD1_n(F_TBD1_n), //comm. fpga dcm rst

        // Trigger vector from comm_fpga
        .lvds_trig_vector_1_p_i(lvds_trig_vector_1_p_i),
        .lvds_trig_vector_1_n_i(lvds_trig_vector_1_n_i),
        .lvds_trig_vector_2_p_i(lvds_trig_vector_2_p_i),
        .lvds_trig_vector_2_n_i(lvds_trig_vector_2_n_i),

        // SPI
        .SCK_i(SCK_i),
        .SSEL_i(SSEL_i),
        .MOSI_i(MOSI_i),
        .MISO_o(MISO_o),

        // misc
        .clk50_i(clk50_i),
        .led_o(led_n[0]),

        // inputs
        .ac_clk1x(ac_clk1x),
        .ac_clk2x(ac_clk2x),
        .rst_logic_o(rst_logic_to_sandbox),
        .ac_clk_locked_o(ac_clk_locked_to_sandbox),

        .idelay_ctrl_ce(idelay_ctrl_ce),
        .idelay_ctrl_rst(idelay_ctrl_rst),
        .idelay_ctrl_inc(idelay_ctrl_inc),

        .trigger_vector_o(trigger_vector_to_sandbox),

        // AC ADC Interface
        .ac_data_a_o(ac_data_a_to_sandbox),
        .ac_data_az_o(ac_data_az_to_sandbox),
        .ac_ovr_a_o(ac_ovr_a_to_sandbox),
        .ac_ovr_az_o(ac_ovr_az_to_sandbox),
        .ac_data_b_o(ac_data_b_to_sandbox),
        .ac_data_bz_o(ac_data_bz_to_sandbox),
        .ac_ovr_b_o(ac_ovr_b_to_sandbox),
        .ac_ovr_bz_o(ac_ovr_bz_to_sandbox),

        // LVDS output interface
        .data_a_i(data_a_from_sandbox),
        .data_az_i(data_az_from_sandbox),
        .data_b_i(data_b_from_sandbox),
        .data_bz_i(data_bz_from_sandbox),
        .data_dry_i(data_dry_from_sandbox),

        // SPI register file interface
        .spi_clk_o(spi_clk),
        .spi_wr_en(spi_wr_en),
        .spi_rd_en(spi_rd_en),
        .spi_address(spi_address),
        .spi_data2slave(spi_data2slave),
        .spi_data2reg(spi_data2reg),

        // User ports
        .gpio_i(gpio_from_sandbox),
        .gpio_z_i(gpio_z_from_sandbox)
    );

adq2xx_sandbox #(.NofBits(NofLvdsBits)) adq2xx_sandbox_inst
               (// inputs
                   .ac_clk1x(ac_clk1x),
                   .ac_clk2x(ac_clk2x),
                   .rst_i(rst_logic_to_sandbox),
                   .ac_clk_locked_i(ac_clk_locked_to_sandbox),
                   .dip_i({dip_i[5:2],2'b00}),

                   .idelay_ctrl_ce(idelay_ctrl_ce),
                   .idelay_ctrl_rst(idelay_ctrl_rst),
                   .idelay_ctrl_inc(idelay_ctrl_inc),

                   .trigger_vector_i(trigger_vector_to_sandbox),

                   // AC ADC Interface
                   .ac_data_a_i(ac_data_a_to_sandbox),
                   .ac_data_az_i(ac_data_az_to_sandbox),
                   .ac_ovr_a_i(ac_ovr_a_to_sandbox),
                   .ac_ovr_az_i(ac_ovr_az_to_sandbox),
                   .ac_data_b_i(ac_data_b_to_sandbox),
                   .ac_data_bz_i(ac_data_bz_to_sandbox),
                   .ac_ovr_b_i(ac_ovr_b_to_sandbox),
                   .ac_ovr_bz_i(ac_ovr_bz_to_sandbox),

                   // LVDS output interface
                   .data_a_o(data_a_from_sandbox),
                   .data_az_o(data_az_from_sandbox),
                   .data_b_o(data_b_from_sandbox),
                   .data_bz_o(data_bz_from_sandbox),
                   .data_dry_o(data_dry_from_sandbox),

                   // SPI register file interface
                   .spi_clk_i(spi_clk),
                   .spi_wr_en(spi_wr_en),
                   .spi_rd_en(spi_rd_en),
                   .spi_address(spi_address),
                   .spi_data2slave(spi_data2slave),
                   .spi_data2reg(spi_data2reg),

                   // User ports
                   .gpio_o(gpio_from_sandbox),
                   .gpio_z_o(gpio_z_from_sandbox),
                   .led_o(led_n[3:1]),
                   .adc_powerdown_o(adc_powerdown),

                   // AFE control
                   .afe_relay_ch1_o(afe_relay_ch1_o),
                   .afe_relay_ch2_o(afe_relay_ch2_o),
                   .dcamp_pdwn_ch1_o(dcamp_pdwn_ch1_o),
                   .dcamp_pdwn_ch2_o(dcamp_pdwn_ch2_o)
               );

endmodule
