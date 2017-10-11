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
// Description :	用于控制重叠FFT之后，双通道的上传
//					每隔 COUNTER_MAX 个时钟，上传 512 个数据。
//					upload_start是单时钟脉冲
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

reg Switch_ahd;	// 比Switch提前1个clk，用于生成Switch
reg Switch;
reg [15:0] UpLoad_Counter;		// 上传过程中，时钟计数器
reg [15:0] RB_Counter;			// 距离门计数器


// Switch 为 1 时，选通 Channel 1 输出
// Switch 为 0 时，选通 Channel 0 输出
// 前三个距离门为 1；后面的距离门，开始交替为 1
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

// 生成 上传触发信号 upload_start_1 和 _2 
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

// 切换顶层模块的 data_out 输出
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        data_out <= 64'd0;
    else if(Switch == 1)
        data_out <= data_in_1;
	else
        data_out <= data_in_2;
end

// 切换顶层模块的 data_valid 输出
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        data_valid_o <= 0;
    else if(Switch == 1)
        data_valid_o <= data_valid_i1;
	else
        data_valid_o <= data_valid_i2;
end

// 时钟计数器 UpLoad_Counter
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

// upload_start 赋值
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        upload_start <= 0;
    else if(Upload_En == 0)
        upload_start <= 0;
	else
        upload_start <= (UpLoad_Counter == COUNTER_MAX/2);
end

// switch_start 赋值
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        switch_start <= 0;
    else if(Upload_En == 0)
        switch_start <= 0;
	else
        switch_start <= (UpLoad_Counter == 1);
end

// 距离门计数器 RB_Counter
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
