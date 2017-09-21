`timescale 1ns / 1ps
//==============================================================================
// Copyright (C) 2016 By GUO Pan
// guopan@bit.edu.cn, All Rights Reserved
//==============================================================================
// Module : 	Power_Spec_Cal
// Author : 	GUO Pan
// Contact : 	guopan@bit.edu.cn
// Date : 		Jun.01.2016
//==============================================================================
// Description :	用于计算功率谱
//					FFT点数1024
//					输出对称功率谱的后半部分
// Records ：		fft_start上升沿到dv上升沿延迟10890ns = 2178个clk
//==============================================================================

module Power_Spec_Cal(

           // Clock input
           input wire clk,
           input wire rst,
           input wire fft_start,

           //Signal input
           input wire [13:0] fifo_data,			// 14位输入

           //Signal output
           output reg [49:0] Power_Spec,		// 功率谱计算结果
           output reg data_valid,				// 比真正的datavalid早3个时钟，补偿后续FIFO的读出+写入
           output reg dv_FFT					// 连续的dv输出，其下降沿用于判断脉冲计数
       );

//Inter wire or reg
//FFT
wire rfd,busy,edone,FFT_done,dv;
wire [9:0] xn_index;
wire [9:0] xk_index;
wire [24:0] fft_data_out_re;
wire [24:0] fft_data_out_im;
reg signed [24:0] fftout_re_d;
reg signed [24:0] fftout_im_d;

//Square
wire signed [49:0] re_square;
wire signed [49:0] im_square;

//Other
reg [0:2] dv_reg;

//FFT核，流水线结构，变换长度1024点，连续输出处理结果。
//输入位宽  14bit  ,输出位宽  25bit  。
//数据形式为定点压缩，压缩比例sch_cl=[0110101011]。
xfft_v7_1 fft_1024_ip (
              .clk(clk), // input clk
              .start(fft_start), // input start
              .xn_re(fifo_data), // input [13 : 0] xn_re
              .xn_im(14'b0), // input [13 : 0] xn_im
              .fwd_inv(1'b1), // input fwd_inv
              .fwd_inv_we(1'b1), // input fwd_inv_we
              .rfd(rfd), // output rfd
              .xn_index(xn_index), // output [9 : 0] xn_index
              .busy(busy), // output busy
              .edone(edone), // output edone
              .done(FFT_done), // output done
              .dv(dv), // output dv
              .xk_index(xk_index), // output [9 : 0] xk_index
              .xk_re(fft_data_out_re), // output [24 : 0] xk_re
              .xk_im(fft_data_out_im) // output [24 : 0] xk_im
          );

//对FFT结果进行缓冲
always @(posedge clk or posedge rst)
begin : PipelineRegister_process
    if (rst == 1'b1) begin
        fftout_re_d <= 25'sb0;
        fftout_im_d <= 25'sb0;
    end
    else begin
        fftout_re_d <= fft_data_out_re;
        fftout_im_d <= fft_data_out_im;
    end
end

//实部的平方，4级流水，输入sfix25，输出sfix50，其实是ufix49
Multiplier_25 Multiplier_RE (
                  .clk(clk), // input clk
                  .a(fftout_re_d), // input [24: 0] a
                  .b(fftout_re_d), // input [24: 0] b
                  .p(re_square) // output [49 : 0] p
              );

//虚部的平方，4级流水，输入sfix25，输出sfix50，其实是ufix49
Multiplier_25 Multiplier_IM (
                  .clk(clk), // input clk
                  .a(fftout_im_d), // input [24 : 0] a
                  .b(fftout_im_d), // input [24 : 0] b
                  .p(im_square) // output [49 : 0] p
              );

// 实部与虚部功率谱累加
// 输出位宽50位
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        Power_Spec <= 0;
    else
        Power_Spec <= re_square + im_square;
end

//得到data_valid
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        data_valid <= 0;
    else
        data_valid <= dv_reg[1];
end

//延迟dv信号5个clk
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
    begin
        dv_reg[0] <= 0;
        dv_reg[1] <= 0;
        dv_reg[2] <= 0;

    end
    else
    begin
        dv_reg[0] <= (dv & xk_index[9]);	// 即xk_index > 511;
        dv_reg[1] <= dv_reg[0];
        dv_reg[2] <= dv_reg[1];
    end
end

//缓冲FFT模块的dv信号
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
    begin
        dv_FFT <= 0;
    end
    else
    begin
        dv_FFT <= dv;
    end
end



endmodule
