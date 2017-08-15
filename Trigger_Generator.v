`timescale 1ns / 1ps
//==============================================================================
// Copyright (C) 2016 By GUO Pan
// guopan@bit.edu.cn, All Rights Reserved
//==============================================================================
// Module : 	Trigger_Generator
// Author : 	GUO Pan
// Contact : 	guopan@bit.edu.cn
// Date : 		Jul.10.2016
//==============================================================================
// Description :	用于生成触发信号
//					触发屏蔽，依靠触发前不满足条件的周期数控制
//					trigger_start是单时钟脉冲
//==============================================================================


module Trigger_Generator
       #(parameter
         BEFORE_TRIGGER = 10)		// 触发前需要不满足条件的周期数，最小为2
       (
           input wire clk,
           input wire rst,
           input wire Capture_En,
           input wire Trigger_Ready,			// Fifo_TC已缓存了足够的预触发点数
           input wire signed [15:0]	 Trigger_Level,
           input wire signed [15:0] x0_i,
           input wire signed [15:0] x0z_i,

           output reg 			trigger_start = 0,
           output reg [1:0]		trigger_vector
       );

reg trigger_en = 1;

reg [BEFORE_TRIGGER-1:0] trigger_signal;


// 根据输入信号，判断是否高于阈值
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        trigger_vector[0] <= 1;
    else if(Trigger_Ready == 1 && Capture_En == 1)
        trigger_vector[0] <= x0_i>Trigger_Level;
    else
        trigger_vector[0] <= 0;
end

always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        trigger_vector[1] <= 1;
    else if(Trigger_Ready == 1 && Capture_En == 1)
        trigger_vector[1] <= x0z_i>Trigger_Level;
    else
        trigger_vector[1] <= 0;
end

// 根据判断结果向量，生成触发信号trigger_signal[0]
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        trigger_signal[0] <= 1;
    else
        trigger_signal[0] <= |trigger_vector;
end

// 将触发信号trigger_signal[0]
// 送入触发信号序列trigger_signal[BEFORE_TRIGGER-1:1]
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        trigger_signal[BEFORE_TRIGGER-1:1] <= 0;
    else
        trigger_signal[BEFORE_TRIGGER-1:1] <= trigger_signal[BEFORE_TRIGGER-2:0];
end

// 根据触发信号序列，生成输出的触发信号trigger_start
// trigger_signal全为0，且trigger_vector中有1时，生成trigger_start
// 副作用，可以使得trigger_start仅有效1个clk周期
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        trigger_start <= 0;
    else
        trigger_start <= (~|trigger_signal)&(|trigger_vector);
end

endmodule
