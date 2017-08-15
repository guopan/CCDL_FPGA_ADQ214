`timescale 1ns / 1ps
//==============================================================================
// Copyright (C) 2016 By GUO Pan
// guopan@bit.edu.cn, All Rights Reserved
//==============================================================================
// Module : 	Negedge_detector
// Author : 	GUO Pan
// Contact : 	guopan@bit.edu.cn
// Date : 		Jan.10.2016
//==============================================================================
// Description :	对输入信号进行下降沿检测
//==============================================================================

module Negedge_detector(
           input clk,
           input rst,
           input signal_in,
           output reg pulse_out
       );
reg signal_in_d;

//延迟signal_in信号1个clk，得到signal_in_d
always @(posedge clk or posedge rst)
    if(rst == 1)
    begin
        signal_in_d <= 0;
        pulse_out <= 0;
    end
    else
    begin
        signal_in_d <= signal_in;
        pulse_out <= ~signal_in & signal_in_d;
    end

endmodule
