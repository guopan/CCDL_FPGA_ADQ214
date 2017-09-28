`timescale 1ns / 1ps
//==============================================================================
// Copyright (C) 2017 By GUO Pan
// guopan@bit.edu.cn, All Rights Reserved
//==============================================================================
// Module : 	FIFO_in_Overlap
// Author : 	GUO Pan
// Contact : 	guopan@bit.edu.cn
// Date : 		Sep.20.2017
//==============================================================================
// Description :	用于缓冲输入Overlap的数据，对FFT运算进行补零
//==============================================================================

module FIFO_in_Overlap
       #( parameter BIT_WIDTH = 14 )
       (
           // Colocking inputs
           input wire rst,
           input wire clk,

           // Signal inputs
           input wire [BIT_WIDTH-1:0] data_in,
           input wire fifo_valid_in,

           // Trigger inputs
           input wire start,

           // Parameter inputs
           input wire [15:0] nPointsPerBin,			// 噪声结束位置
           input wire [15:0] nPoints_Overlap,		// Overlap结束位置计数

           // Signal outputs
           output wire [BIT_WIDTH-1:0] data_out,
           output reg  data_valid
       );
parameter  NFFT = 1024;				// 补零后的FFT点数

// Inter reg or wire
wire rd_clk;
wire wr_clk;
wire full,empty;

reg wr_en;
wire rd_en;
wire start_rd;

wire [BIT_WIDTH-1:0] dout;
wire fifo_valid;

reg [BIT_WIDTH-1:0] data_in_d;

reg [14:0] Points_counter;		// 采样点计数器,FIFO写入点数控制，3km Max
reg [7:0] dvi_counter;			// 距离门计数器

// 赋值
// assign din = wr_counter_en? data_in : 0;
assign data_out = fifo_valid? dout : 0;
assign rd_clk = clk;
assign wr_clk = clk;
assign start_rd = (Points_counter > nPointsPerBin)&~empty;

// 生成数据输出有效信号data_valid
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        data_valid <= 0;
    else
        data_valid <= rd_en;
end

// Rd_En 信号的生成状态机
FIFO_In_Overlap_Rd_StateMachine RdEn_FSM 
(
    .rst(rst), 
    .clk(clk), 
    .start(start_rd), 
    .empty(empty), 
    .RANGEBIN_LENGTH(nPointsPerBin), 
    .rd_en(rd_en)
    );
	
// FIFO 位宽：14，深度：8192
FIFO_Overlap FIFO_Overlap_m (
  .clk(clk), // input clk
  .srst(rst), // input srst
  .din(data_in_d), // input [13 : 0] din
  .wr_en(wr_en), // input wr_en
  .rd_en(rd_en), // input rd_en
  .dout(dout), // output [13 : 0] dout
  .full(full), // output full
  .empty(empty), // output empty
  .valid(fifo_valid)
);	

// 将输入信号 fifo_valid_in 转换为单脉冲(即下降沿检测)
Negedge_detector neg_edge_dvi
 (
    .clk(clk), 
    .rst(rst), 
    .signal_in(fifo_valid_in), 
    .pulse_out(dv_negedge)
    );		   

// 生成写入控制信号 wr_en
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        wr_en <= 0;
    else if( Points_counter > (nPointsPerBin[15:1]-1) && Points_counter < nPoints_Overlap)		// -1为了补偿FIFO的写入使能的延迟
        wr_en <= fifo_valid_in;
	else
        wr_en <= 0;
end		

// 采样点计数器
// fifo_valid_in 两次下降沿之后，即第3个距离门，开始计数
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        Points_counter <= 0;
    else if(start == 1)
        Points_counter <= 0;
    else if(fifo_valid_in == 1 && dvi_counter >= 2)
        Points_counter <= Points_counter + 1;
    else
		Points_counter <= Points_counter;
end

// dvi计数器，即距离门计数
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        dvi_counter <= 0;
    else if(start == 1)
        dvi_counter <= 0;
    else if(dv_negedge == 1)
		dvi_counter <= dvi_counter + 1;
    else
		dvi_counter <= dvi_counter;
end

// 缓冲 data_in，补偿 wr_en 的控制延迟
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        data_in_d <= 0;
    else
        data_in_d <= data_in;
end

endmodule
