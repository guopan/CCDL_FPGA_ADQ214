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
module Power_Spec_Cal(

           // Clock input
           input wire clk,
           input wire rst,
           input wire fft_start,

           //Signal input
           input wire [15:0] fifo_data,

           //Signal output
           output reg [31:0] Power_Spec,
           output wire [9:0] xn_index,
           output reg [9:0] data_index,
           output reg data_valid

       );

//Inter wire or reg
//FFT
wire fft_rst;
wire [9:0] scl_ch;
wire scl_ch_we;
wire rfd,busy,edone,done,dv;
wire [9:0] xk_index;
wire [15:0] fft_data_out_re;
wire [15:0] fft_data_out_im;
//Square
wire [31:0] re_square;
wire [31:0] im_square;
//Other
reg dv_reg1, dv_reg2, dv_reg3;
reg [9:0] xk_index_reg1, xk_index_reg2, xk_index_reg3;
// ��ֵ
assign fft_rst = rst;
assign scl_ch = 10'b01_1010_1011;
assign scl_ch_we = 1'b1;

//FFT�ˣ���ˮ�߽ṹ���任����1024�㣬���������������
//����λ��16bit,���λ��16bit��
//������ʽΪ����ѹ����ѹ������sch_cl=[0110101011]��
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
              .done(done), // output done
              .dv(dv), // output dv
              .xk_index(xk_index), // output [9 : 0] xk_index
              .xk_re(fft_data_out_re), // output [15 : 0] xk_re
              .xk_im(fft_data_out_im) // output [15 : 0] xk_im
          );

//ʵ����ƽ����3����ˮ
Multiplier_16 Multiplier_RE (
                  .clk(clk), // input clk
                  .a(fft_data_out_re), // input [15 : 0] a
                  .b(fft_data_out_re), // input [15 : 0] b
                  .p(re_square) // output [31 : 0] p
              );

//�鲿��ƽ����3����ˮ
Multiplier_16 Multiplier_IM (
                  .clk(clk), // input clk
                  .a(fft_data_out_im), // input [15 : 0] a
                  .b(fft_data_out_im), // input [15 : 0] b
                  .p(im_square) // output [31 : 0] p
              );

// ʵ�����鲿�������ۼ�
// ���λ��32λ��Ҳ������
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        Power_Spec <= 0;
    else
        Power_Spec <= re_square + im_square;
end

//�ӳ�dv�ź�4��clk���õ�data_valid
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

//�ӳ�xk_index�ź�4��clk���õ�data_index
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
