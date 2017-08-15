`timescale 1ns / 1ps
//==============================================================================
// Copyright (C) 2016 By GUO Pan
// guopan@bit.edu.cn, All Rights Reserved
//==============================================================================
// Module : 	FIFO_TC
// Author : 	GUO Pan
// Contact : 	guopan@bit.edu.cn
// Date : 		Jul.10.2016
//==============================================================================
// Description :	����ʵ��Ԥ����
//					rst֮�󣬾�һֱ����
//==============================================================================

module FIFO_TC
       #(
           parameter BIT_WIDTH = 14
       )
       (
           input wire clk,
           input wire rst,
           input wire [15:0]    x0_i,
           input wire [15:0]    x0z_i,

           output wire [BIT_WIDTH*2-1:0]   fifo_tc_dataout,
           output reg           trigger_tc_ready
       );

parameter DELAY_NUM = 250+3;	  // +3 ��Ϊ��ƥ�� FIFO_in ��д��ʹ��wr_en�ӳ٣�
// 250��Ϊ��Ԥ������500��������

// Inter wire or reg
reg   rd_en;
wire  wr_en;
wire  [BIT_WIDTH*2-1 : 0] data_in;
reg   [12:0] din_counter;
wire full;
wire empty;

// ֻҪ��rst����һֱд��
assign wr_en = ~rst;
assign data_in = {x0_i[BIT_WIDTH-1:0], x0z_i[BIT_WIDTH-1:0]};

// ������
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        din_counter <= 0;
    else if(din_counter < DELAY_NUM)
        din_counter <= din_counter + 1;
    else
        din_counter <= din_counter;
end

// ���ź��ӳٿ���
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        rd_en <= 0;
    else if(din_counter < DELAY_NUM)
        rd_en <= 0;
    else
        rd_en <= 1;
end

//FIFO����������������������ź�
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        trigger_tc_ready <= 0;
    else
        trigger_tc_ready <= rd_en;
end

//FIFO IP д�����256������λ��32bit�����λ��32bit����дʱ��ͬ��
Fifo_Buffer_Tc Fifo_Buffer_Tc_m (
                   .clk(clk), // input clk
                   .srst(rst), // input rst
                   .din(data_in), // input [BIT_WIDTH*2-1 : 0] din
                   .wr_en(wr_en), // input wr_en
                   .rd_en(rd_en), // input rd_en
                   .dout(fifo_tc_dataout), // output [31 : 0] dout
                   .full(full), // output full
                   .empty(empty) // output empty
                   // .valid(valid) // output valid
               );

endmodule
