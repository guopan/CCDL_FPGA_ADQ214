`timescale 1ns / 1ps
//==============================================================================
// Copyright (C) 2017 By GUO Pan
// guopan@bit.edu.cn, All Rights Reserved
//==============================================================================
// Module : 	Pulse_Counter
// Author : 	GUO Pan
// Contact : 	guopan@bit.edu.cn
// Date : 		Aug.8.2016
//==============================================================================
// Description :	��������м�����Pulse_counts
// 					PSCģ���datavalid����ʱ��������һ��
// 					�׸�����ʱ��Pulse_countsΪ0�����is_first_pls�ź�
//==============================================================================
module Pulse_Counter(
    input wire clk,
    input wire rst,
    input wire data_valid_i,
    input wire Capture_En,	
    output reg [15:0] Pulse_counts,
    output reg is_first_pls
	
    );
	
	wire dv_posedge;	// data_valid_i �������ر�־
	reg dv_negedge;	// data_valid_i ���½���100��־
	
	reg dvi_reg[1:0];
	
// �������ź� data_valid_i ת��Ϊ������(�������ؼ��)
Posedge_detector pos_edge_dvi
 (
    .clk(clk), 
    .rst(rst), 
    .signal_in(data_valid_i), 
    .pulse_out(dv_posedge)
    );

//�ӳ�signal_in�ź�1��clk���õ�signal_in_d
always @(posedge clk or posedge rst)
    if(rst == 1)
    begin
        dvi_reg[0] <= 0;
        dvi_reg[1] <= 0;
        dv_negedge <= 0;
    end
    else
    begin
        dvi_reg[0] <= data_valid_i;
        dvi_reg[1] <= dvi_reg[0];
		dv_negedge <= dvi_reg[1] & ~dvi_reg[0] & ~data_valid_i;
    end
	
// ���������
// �����Pulse_counts���������ź�data_valid_i��Ч2��clk֮�󣬸��¼���ֵ
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
    begin
        Pulse_counts <= 0;
    end
    else if(Capture_En == 0)
        Pulse_counts <= 0;
    else if(dv_negedge == 1)
        Pulse_counts <= Pulse_counts + 1;
    else
        Pulse_counts <= Pulse_counts;
end

// ����Ƿ�Ϊ��1������ı�־�źţ�is_first_pls
// �� Pulse_counts ����1��ʱ��
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
    begin
        is_first_pls <= 0;
    end
    else if(Capture_En == 0)
        is_first_pls <= 0;
    else
        is_first_pls <= (Pulse_counts==16'd0);
end


endmodule
