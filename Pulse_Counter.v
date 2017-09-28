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
	
	// wire dv_posedge;	// data_valid_i 的上升沿标志
	wire dv_negedge;		// data_valid_i 的下降沿标志
	
	reg dvn_reg[5:0];
	
// 将输入信号 data_valid_i 转换为单脉冲(即下降沿检测)
Negedge_detector neg_edge_dvi
 (
    .clk(clk), 
    .rst(rst), 
    .signal_in(data_valid_i), 
    .pulse_out(dv_negedge)
    );

//延迟dv_FFT信号5个clk，补偿FIFO的读写延迟，再用于计数
always @(posedge clk or posedge rst)
    if(rst == 1)
    begin
        dvn_reg[0] <= 0;
        dvn_reg[1] <= 0;
        dvn_reg[2] <= 0;
        dvn_reg[3] <= 0;
        dvn_reg[4] <= 0;
        dvn_reg[5] <= 0;
    end
    else
    begin
        dvn_reg[0] <= dv_negedge;
        dvn_reg[1] <= dvn_reg[0];
        dvn_reg[2] <= dvn_reg[1];
        dvn_reg[3] <= dvn_reg[2];
        dvn_reg[4] <= dvn_reg[3];
        dvn_reg[5] <= dvn_reg[4];
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
    else if(dvn_reg[5] == 1)
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
        is_first_pls <= (Pulse_counts == 16'd0);
end


endmodule
