`timescale 1ns / 1ps
//==============================================================================
// Copyright (C) 2016 By GUO Pan
// guopan@bit.edu.cn, All Rights Reserved
//==============================================================================
// Module : 	Upload_Switcher
// Author : 	GUO Pan
// Contact : 	guopan@bit.edu.cn
// Date : 		Sep.16.2017
//==============================================================================
// Description :	���ڿ����ص�FFT֮��˫ͨ�����ϴ�
//					ÿ�� COUNTER_MAX ��ʱ�ӣ��ϴ� 512 �����ݡ�
//					upload_start�ǵ�ʱ������
//==============================================================================
module Upload_Switcher(
    input clk,
    input rst,
    input Upload_En,
    input [63:0] data_in_1,
    input [63:0] data_in_2,
	input data_valid_i1,
	input data_valid_i2,
	
    output reg upload_start_1,
    output reg upload_start_2,
    output reg [63:0] data_out,
	output reg data_valid_o
    );
	
reg switch_start;
reg upload_start;

parameter COUNTER_MAX = 16'd4096;

reg Switch_ahd;	// ��Switch��ǰ1��clk����������Switch
reg Switch;
reg [15:0] UpLoad_Counter;		// �ϴ������У�ʱ�Ӽ�����
reg [15:0] RB_Counter;			// �����ż�����


// Switch Ϊ 1 ʱ��ѡͨ Channel 1 ���
// Switch Ϊ 0 ʱ��ѡͨ Channel 0 ���
// ǰ����������Ϊ 1������ľ����ţ���ʼ����Ϊ 1
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
		Switch_ahd <= 0;
    else if(Upload_En == 0)
		Switch_ahd <= 0;
	else if(RB_Counter < 3)
		Switch_ahd <= 1;
	else if(switch_start == 1)
		Switch_ahd <= ~Switch_ahd;
	else
		Switch_ahd <= Switch_ahd;
end

always @(posedge clk or posedge rst)
begin
    if(rst == 1)
		Switch <= 0;
	else
		Switch <= Switch_ahd;
end

// ���� �ϴ������ź� upload_start_1 �� _2 
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
	begin
        upload_start_1 <= 0;
		upload_start_2 <= 0;
	end
    else if(Upload_En == 0)
	begin
        upload_start_1 <= 0;
		upload_start_2 <= 0;
	end
	else if(upload_start == 1)
	begin
        upload_start_1 <= Switch;
		upload_start_2 <= ~Switch;
	end
	else
	begin
        upload_start_1 <= 0;
		upload_start_2 <= 0;
	end
end

// �л�����ģ��� data_out ���
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        data_out <= 64'd0;
    else if(Switch == 1)
        data_out <= data_in_1;
	else
        data_out <= data_in_2;
end

// �л�����ģ��� data_valid ���
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        data_valid_o <= 0;
    else if(Switch == 1)
        data_valid_o <= data_valid_i1;
	else
        data_valid_o <= data_valid_i2;
end

// ʱ�Ӽ����� UpLoad_Counter
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        UpLoad_Counter <= COUNTER_MAX;
    else if(Upload_En == 0)
        UpLoad_Counter <= COUNTER_MAX;
	else if(UpLoad_Counter == COUNTER_MAX)
        UpLoad_Counter <= 0;
    else
        UpLoad_Counter <= UpLoad_Counter + 1;
end

// upload_start ��ֵ
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        upload_start <= 0;
    else if(Upload_En == 0)
        upload_start <= 0;
	else
        upload_start <= (UpLoad_Counter == COUNTER_MAX/2);
end

// switch_start ��ֵ
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        switch_start <= 0;
    else if(Upload_En == 0)
        switch_start <= 0;
	else
        switch_start <= (UpLoad_Counter == 1);
end

// �����ż����� RB_Counter
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        RB_Counter <= 0;
    else if(Upload_En == 0)
        RB_Counter <= 0;
	else if(switch_start == 1)
        RB_Counter <= RB_Counter + 1;
    else
        RB_Counter <= RB_Counter;
end

endmodule
