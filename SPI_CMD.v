`timescale 1ns / 1ps
//==============================================================================
// Copyright (C) 2017 By GUO Pan
// guopan@bit.edu.cn, All Rights Reserved
//==============================================================================
// Module : 	SPI_CMD
// Author : 	GUO Pan
// Contact : 	guopan@bit.edu.cn
// Date : 		Jan.01.2017
//==============================================================================
// Description :	用于存储SPI命令，转换成易识别的命令标识
//==============================================================================

module SPI_CMD
       (
           input wire clk,
           input wire rst,
           input wire CMD_Update_Disable,
           input wire [16*8-1:0] user_register_i,

           output reg [15:0] UR_EndPosition,
           output reg [15:0] UR_MirrorStart,
           output reg [15:0] UR_nOverlap,
           output reg [15:0] UR_nRangeBins,
           output reg [15:0] UR_nPoints_RB,
           output reg [15:0] UR_nACC_Pulses,
           output reg [15:0] UR_TriggerLevel,
           output reg [15:0] UR_CMD
       );

//
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
    begin
        UR_EndPosition  = 0;
        UR_MirrorStart  = 0;
        UR_nOverlap     = 0;
        UR_nRangeBins   = 0;
        UR_nPoints_RB   = 0;
        UR_nACC_Pulses  = 0;
        UR_TriggerLevel = 0;
        UR_CMD          = 0;
    end
    else if (CMD_Update_Disable == 0)
    begin
        UR_EndPosition   = user_register_i[8*16-1:7*16];
        UR_MirrorStart   = user_register_i[7*16-1:6*16];
        UR_nOverlap      = user_register_i[6*16-1:5*16];
        UR_nRangeBins    = user_register_i[5*16-1:4*16];
        UR_nPoints_RB    = user_register_i[4*16-1:3*16];
        UR_nACC_Pulses   = user_register_i[3*16-1:2*16];
        UR_TriggerLevel  = user_register_i[2*16-1:1*16];
        UR_CMD           = user_register_i[1*16-1:0*16];
    end
end
endmodule
