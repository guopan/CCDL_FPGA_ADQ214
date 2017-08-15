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
// Description :	�������ɴ����ź�
//					�������Σ���������ǰ����������������������
//					trigger_start�ǵ�ʱ������
//==============================================================================


module Trigger_Generator
       #(parameter
         BEFORE_TRIGGER = 10)		// ����ǰ��Ҫ����������������������СΪ2
       (
           input wire clk,
           input wire rst,
           input wire Capture_En,
           input wire Trigger_Ready,			// Fifo_TC�ѻ������㹻��Ԥ��������
           input wire signed [15:0]	 Trigger_Level,
           input wire signed [15:0] x0_i,
           input wire signed [15:0] x0z_i,

           output reg 			trigger_start = 0,
           output reg [1:0]		trigger_vector
       );

reg trigger_en = 1;

reg [BEFORE_TRIGGER-1:0] trigger_signal;


// ���������źţ��ж��Ƿ������ֵ
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

// �����жϽ�����������ɴ����ź�trigger_signal[0]
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        trigger_signal[0] <= 1;
    else
        trigger_signal[0] <= |trigger_vector;
end

// �������ź�trigger_signal[0]
// ���봥���ź�����trigger_signal[BEFORE_TRIGGER-1:1]
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        trigger_signal[BEFORE_TRIGGER-1:1] <= 0;
    else
        trigger_signal[BEFORE_TRIGGER-1:1] <= trigger_signal[BEFORE_TRIGGER-2:0];
end

// ���ݴ����ź����У���������Ĵ����ź�trigger_start
// trigger_signalȫΪ0����trigger_vector����1ʱ������trigger_start
// �����ã�����ʹ��trigger_start����Ч1��clk����
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        trigger_start <= 0;
    else
        trigger_start <= (~|trigger_signal)&(|trigger_vector);
end

endmodule
