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
// Description :	生成 Capture_En 信号，控制采集过程的开始和结束
// 					上位机 UR_CMD[0] 命令的上升沿，开始采集
// 					处理到足够的脉冲数之后，停止采集，开始上传结果
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

// 检测 UR_CMD[0] 的上升沿
Posedge_detector Start_detector
                 (
                     .clk(clk),
                     .rst(rst),
                     .signal_in(UR_CMD[0]),
                     .pulse_out(capture_start)
                 );

// 判断脉冲计数值是否达到 TOTAL_PULSE
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        capture_done <= 0;
    else
        capture_done <= (Pulse_counts > TOTAL_PULSE - 1);
end

// 采集过程的使能信号，接收上位机指令置高，采集完成置低
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
