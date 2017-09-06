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
// Description :	对脉冲进行计数，Pulse_counts
// 					PSC模块的datavalid结束时，计数加一。
// 					首个脉冲时，Pulse_counts为0，输出is_first_pls信号
//==============================================================================
module Pulse_Counter(
    input wire clk,
    input wire rst,
    input wire data_valid_i,
    input wire Capture_En,	
    output reg [15:0] Pulse_counts,
    output reg is_first_pls
	
    );
	
	wire dv_posedge;	// data_valid_i 的上升沿标志
	reg dv_negedge;	// data_valid_i 的下降沿100标志
	
	reg dvi_reg[1:0];
	
// 将输入信号 data_valid_i 转换为单脉冲(即上升沿检测)
Posedge_detector pos_edge_dvi
 (
    .clk(clk), 
    .rst(rst), 
    .signal_in(data_valid_i), 
    .pulse_out(dv_posedge)
    );

//延迟signal_in信号1个clk，得到signal_in_d
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
	
// 脉冲计数器
// 输出的Pulse_counts，在输入信号data_valid_i有效2个clk之后，更新计数值
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

// 输出是否为第1个脉冲的标志信号：is_first_pls
// 比 Pulse_counts 晚了1个时钟
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
