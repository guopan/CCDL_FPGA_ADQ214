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
// Engineer:       Stefan Ahlquist
// 
// Create Date:    2010-11-16
// Module Name:    gain_control
// Description:    
//
//////////////////////////////////////////////////////////////////////////////////

module gain_control
  #(
    parameter NoiseBit = 0,
    parameter NofBitsCutOff = 0
    )
  ( // Control & Clocking input
    input wire clk,       
	
    // Signal input
    input wire signed [15:0] x0_i,
    input wire signed [15:0] x0z_i,
    input wire signed [15:0] x1_i,
    input wire signed [15:0] x1z_i,

    input wire signed [15:0] gain_control_1_i,
    input wire signed [15:0] gain_control_2_i,
    input wire signed [15:0] offset_control_1_i,
    input wire signed [15:0] offset_control_2_i,

    input wire signed [15:0] max_code_control_1_i,
    input wire signed [15:0] min_code_control_1_i,
    input wire signed [15:0] max_code_control_2_i,
    input wire signed [15:0] min_code_control_2_i,

    (* SHREG_EXTRACT="NO" *) output reg signed [15:0] y0_clk_o,
    (* SHREG_EXTRACT="NO" *) output reg signed [15:0] y0z_clk_o,
    (* SHREG_EXTRACT="NO" *) output reg signed [15:0] y1_clk_o,
    (* SHREG_EXTRACT="NO" *) output reg signed [15:0] y1z_clk_o,
    (* SHREG_EXTRACT="NO" *) output reg [3:0] overflow_o
    
 );
endmodule
