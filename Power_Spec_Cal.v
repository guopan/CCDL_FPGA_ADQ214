`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    11:57:34 06/01/2016
// Design Name:
// Module Name:    FFT_0601
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module Power_Spect_Cal(

           // Clock input
           input wire clk,
           input wire rst,
           input wire fft_start,

           //Signal input
           input wire [15:0] fifo_data,

           //Signal output
           output wire [15:0] fft_data_out_re,
           output wire [15:0] fft_data_out_im,
           output wire [9:0] xn_index,
           output wire [9:0] xk_index,
           output wire rfd,busy,edone,done,dv

       );

//Inter wire or reg
wire fft_rst;
wire [15:0] fft_data_re;
wire [15:0] fft_data_im;
wire [9:0] scl_ch;
wire scl_ch_we;

// 赋值
assign fft_data_re = fifo_data;
assign fft_rst = rst;
assign scl_ch = 10'b01_1010_1011;
assign scl_ch_we = 1'b1;

//FFT核，流水线结构，变换长度1024点，连续输出处理结果。
//输入位宽16bit,输出位宽16bit。
//数据形式为定点压缩，压缩比例sch_cl=[0110101011]。
xfft_v7_1 fft_1024_ip (
              .clk(clk), // input clk
              .start(fft_start), // input start
              .xn_re(fft_data_re), // input [15 : 0] xn_re
              .xn_im(16'b0), // input [15 : 0] xn_im
              .fwd_inv(1'b1), // input fwd_inv
              .fwd_inv_we(1'b1), // input fwd_inv_we
              .scale_sch(scl_ch), // input [9 : 0] scale_sch
              .scale_sch_we(scl_ch_we), // input scale_sch_we
              .rfd(rfd), // output rfd
              .xn_index(xn_index), // output [9 : 0] xn_index
              .busy(busy), // output busy
              .edone(edone), // output edone
              .done(done), // output done
              .dv(dv), // output dv
              .xk_index(xk_index), // output [9 : 0] xk_index
              .xk_re(fft_data_out_re), // output [15 : 0] xk_re
              .xk_im(fft_data_out_im) // output [15 : 0] xk_im
          );

endmodule
