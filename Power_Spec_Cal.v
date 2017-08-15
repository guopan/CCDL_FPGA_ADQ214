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
// Description :	���ڼ��㹦����
//					FFT����1024
//					����Գƹ����׵ĺ�벿��
//==============================================================================

module Power_Spec_Cal(

           // Clock input
           input wire clk,
           input wire rst,
           input wire fft_start,

           //Signal input
           input wire [13:0] fifo_data,			// 14λ����

           //Signal output
           output reg [49:0] Power_Spec,		// �����׼�����
           output reg data_valid				// ��������datavalid��3��ʱ�ӣ���������FIFO�Ķ���+д��
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

//FFT�ˣ���ˮ�߽ṹ���任����1024�㣬���������������
//����λ��  14bit  ,���λ��  25bit  ��
//������ʽΪ����ѹ����ѹ������sch_cl=[0110101011]��
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

//��FFT������л���
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

//ʵ����ƽ����4����ˮ������sfix25�����sfix50����ʵ��ufix49
Multiplier_25 Multiplier_RE (
                  .clk(clk), // input clk
                  .a(fftout_re_d), // input [24: 0] a
                  .b(fftout_re_d), // input [24: 0] b
                  .p(re_square) // output [49 : 0] p
              );

//�鲿��ƽ����4����ˮ������sfix25�����sfix50����ʵ��ufix49
Multiplier_25 Multiplier_IM (
                  .clk(clk), // input clk
                  .a(fftout_im_d), // input [24 : 0] a
                  .b(fftout_im_d), // input [24 : 0] b
                  .p(im_square) // output [49 : 0] p
              );

// ʵ�����鲿�������ۼ�
// ���λ��50λ
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        Power_Spec <= 0;
    else
        Power_Spec <= re_square + im_square;
end

//�õ�data_valid
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        data_valid <= 0;
    else
        data_valid <= dv_reg[1];
end

//�ӳ�dv�ź�5��clk
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
        dv_reg[0] <= (dv & xk_index[9]);	// ��xk_index > 511;
        dv_reg[1] <= dv_reg[0];
        dv_reg[2] <= dv_reg[1];
    end
end

endmodule
