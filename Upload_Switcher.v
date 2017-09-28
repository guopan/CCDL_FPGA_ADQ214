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
//					触发屏蔽，依靠触发前不满足条件的周期数控制
//					trigger_start是单时钟脉冲
//==============================================================================
module Upload_Switcher(
    input clk,
    input rst,
    input trigger_start,
    input Upload_En,
    input [63:0] data_in_1,
    input [63:0] data_in_2,
	input data_valid_i1,
	input data_valid_i2,
	
    output reg trigger_start_1,
    output reg trigger_start_2,
    output reg [63:0] data_out,
	output reg data_valid_o
    );

reg Switcher;
	
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
	begin
        trigger_start_1 <= 0;
		trigger_start_2 <= 0;
		Switcher <= 0;
	end
    else if(Upload_En == 1 && trigger_start == 1)
	begin
        trigger_start_1 <= ~Switcher;
		trigger_start_2 <= Switcher;
		Switcher <= ~Switcher;
	end
	else
	begin
        trigger_start_1 <= 0;
		trigger_start_2 <= 0;
		Switcher <= Switcher;
	end
end

// 切换 data_out 输出
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        data_out <= 64'd0;
    else if(Switcher == 1)
        data_out <= data_in_1;
	else
        data_out <= data_in_2;
end

// 切换 data_valid 输出
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        data_valid_o <= 0;
    else if(Switcher == 1)
        data_valid_o <= data_valid_i1;
	else
        data_valid_o <= data_valid_i2;
end

endmodule
