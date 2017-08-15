//////////////////////////////////////////////////////////////////////////////////
//
// Copyright © 2009 Signal Processing Devices Sweden AB. All rights reserved.
//
// Module Name:    
// Project Name:   ADQ
// Revision:       $Revision: 571 $
// Description:    
//
//////////////////////////////////////////////////////////////////////////////////

// =============================================================================
// Version register settings 
// =============================================================================

// Version Register Settings
`define VER_REG_VLDTR     8'hA5 // Validator for version register field.
`define VER_REG_PRJ      10'h01 // Defined in SPD PCB database
`define VER_REG_FCN      10'h04 // Defined in SPD PCB database
`define VER_REG_MAJORREV  8'd0  // Revision number defined as MAJORREV.MINORREV => 1.0 is first major release. 2.0 second etc
`define VER_REG_MINORREV  3'd0  // see above
`define VER_REG_REL       1'b0  // 0 = code under development, 1 = released code

// =============================================================================
// LVDS interface settings 
// =============================================================================
`define LVDS_AIN_SCRAMBLE  14'b01001001001011
`define LVDS_BIN_SCRAMBLE  14'b10101001000100
`define LVDS_AOUT_SCRAMBLE 16'b1001011100000000
`define LVDS_BOUT_SCRAMBLE 16'b0001000000010011

`define LVDS_OVR_AIN_SCRAMBLE  1'b0
`define LVDS_OVR_BIN_SCRAMBLE  1'b0
`define LVDS_OVR_AOUT_SCRAMBLE 1'b1
`define LVDS_OVR_BOUT_SCRAMBLE 1'b0

// =============================================================================
// DC algorithm settings
// =============================================================================
`define EstimateG 18'h104DD
`define EstimateD 40
