`timescale 1ns / 1ps
//==============================================================================
// Copyright (C) 2017 By GUO Pan
// guopan@bit.edu.cn, All Rights Reserved
//==============================================================================
// Module : 	Group_Ctrl
// Author : 	GUO Pan
// Contact : 	guopan@bit.edu.cn
// Date : 		Jun.10.2017
//==============================================================================
// Description :	���� Capture_En �źţ����Ʋɼ����̵Ŀ�ʼ�ͽ���
// 					��λ�� UR_CMD[0] ����������أ���ʼ�ɼ�
// 					�����㹻��������֮��ֹͣ�ɼ�����ʼ�ϴ����
//==============================================================================

module Group_Ctrl
       (
           input wire clk,
           input wire rst,
           input wire [15:0] Pulse_counts,
           input wire [15:0] UR_CMD,
           input wire [15:0] TOTAL_PULSE,

           output reg Capture_En
       );

wire capture_start;
reg  capture_done;

// ��� UR_CMD[0] ��������
Posedge_detector Start_detector
                 (
                     .clk(clk),
                     .rst(rst),
                     .signal_in(UR_CMD[0]),
                     .pulse_out(capture_start)
                 );

// �ж��������ֵ�Ƿ�ﵽ TOTAL_PULSE
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        capture_done <= 0;
    else
        capture_done <= (Pulse_counts > TOTAL_PULSE - 1);
end

// �ɼ����̵�ʹ���źţ�������λ��ָ���øߣ��ɼ�����õ�
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        Capture_En <= 0;
    else if(capture_start)
        Capture_En <= 1;
    else if(capture_done)
        Capture_En <= 0;
    else
        Capture_En <= Capture_En;
end

endmodule
