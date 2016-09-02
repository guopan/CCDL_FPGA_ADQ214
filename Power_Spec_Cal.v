`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    11:57:34 06/01/2016
// Design Name:
// Module Name:    Power_Spec_Cal
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
module Power_Spec_Cal(

           // Clock input
           input wire clk,
           input wire rst,
           input wire fft_start,

           //Signal input
           input wire [15:0] fifo_data,

           //Signal output
           output reg [31:0] Power_Spec,		//功率谱计算结果
           output wire [9:0] xn_index,			//输入数据的索引值，为啥要输出？
           output reg [9:0] xk_index_reg1,		//输出用于DPRAM的读地址
			  output reg [9:0] xk_index_reg3,   //输出用于峰值比较地址
           output reg [9:0] data_index,
           output reg data_valid,
		   output wire FFT_done				//输出，用于RangeBin计数

       );

//Inter wire or reg
//FFT
wire fft_rst;
wire [9:0] scl_ch;
wire scl_ch_we;
wire rfd,busy,edone,dv;

wire [15:0] fft_data_out_re;
wire [15:0] fft_data_out_im;
//Square
wire [31:0] re_square;
wire [31:0] im_square;
//Other
reg dv_reg1, dv_reg2, dv_reg3;
wire [9:0] xk_index;
reg [9:0] xk_index_reg2;
// 赋值
assign fft_rst = rst;
assign scl_ch = 10'b01_1010_1011;
assign scl_ch_we = 1'b1;

//FFT核，流水线结构，变换长度1024点，连续输出处理结果。
//输入位宽16bit,输出位宽16bit。
//数据形式为定点压缩，压缩比例sch_cl=[0110101011]。
xfft_v7_1 fft_1024_ip (
              .clk(clk), // input clk
              .start(fft_start), // input start
              .xn_re(fifo_data), // input [15 : 0] xn_re
              .xn_im(16'b0), // input [15 : 0] xn_im
              .fwd_inv(1'b1), // input fwd_inv
              .fwd_inv_we(1'b1), // input fwd_inv_we
              .scale_sch(scl_ch), // input [9 : 0] scale_sch
              .scale_sch_we(scl_ch_we), // input scale_sch_we
              .rfd(rfd), // output rfd
              .xn_index(xn_index), // output [9 : 0] xn_index
              .busy(busy), // output busy
              .edone(edone), // output edone
              .done(FFT_done), // output done
              .dv(dv), // output dv
              .xk_index(xk_index), // output [9 : 0] xk_index
              .xk_re(fft_data_out_re), // output [15 : 0] xk_re
              .xk_im(fft_data_out_im) // output [15 : 0] xk_im
          );

//实部的平方，3级流水
Multiplier_16 Multiplier_RE (
                  .clk(clk), // input clk
                  .a(fft_data_out_re), // input [15 : 0] a
                  .b(fft_data_out_re), // input [15 : 0] b
                  .p(re_square) // output [31 : 0] p
              );

//虚部的平方，3级流水
Multiplier_16 Multiplier_IM (
                  .clk(clk), // input clk
                  .a(fft_data_out_im), // input [15 : 0] a
                  .b(fft_data_out_im), // input [15 : 0] b
                  .p(im_square) // output [31 : 0] p
              );

// 实部与虚部功率谱累加
// 输出位宽32位，也许会溢出
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        Power_Spec <= 0;
    else
        Power_Spec <= re_square + im_square;
end

//延迟dv信号4个clk，得到data_valid
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
    begin
        dv_reg1 <= 0;
        dv_reg2 <= 0;
        dv_reg3 <= 0;
        data_valid <= 0;
    end
    else
    begin
        dv_reg1 <= dv;
        dv_reg2 <= dv_reg1;
        dv_reg3 <= dv_reg2;
        data_valid <= dv_reg3;
    end
end

//延迟xk_index信号4个clk，得到data_index
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
    begin
        xk_index_reg1 <= 0;
        xk_index_reg2 <= 0;
        xk_index_reg3 <= 0;
        data_index <= 0;
    end
    else
    begin
        xk_index_reg1 <= xk_index;
        xk_index_reg2 <= xk_index_reg1;
        xk_index_reg3 <= xk_index_reg2;
        data_index <= xk_index_reg3;
    end
end

endmodule
