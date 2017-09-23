`timescale 1ns / 1ps
//==============================================================================
// Copyright (C) 2017 By GUO Pan
// guopan@bit.edu.cn, All Rights Reserved
//==============================================================================
// Module : 	FIFO_in
// Author : 	GUO Pan
// Contact : 	guopan@bit.edu.cn
// Date : 		Jan.10.2017
//==============================================================================
// Description :	用于缓冲输入数据，对FFT运算进行补零
//==============================================================================

module FIFO_in
       #( parameter BIT_WIDTH = 14 )
       (
           // Colocking inputs
           input wire rst,
           input wire clk,

           // Signal inputs
           input wire [BIT_WIDTH*2-1:0] data_in,

           // Trigger inputs
           input wire start,

           // Parameter inputs
           input wire [15:0] nPointsPerBin,			// 噪声结束位置
           input wire [15:0] Mirror_Position,		// 镜面计算起点位置
           input wire [15:0] End_Position,			// 距离总点数结束位置，从预触发开始

           // Signal outputs
           output wire [BIT_WIDTH-1:0] data_out,
           output reg  data_valid
       );
parameter  NFFT = 1024;				// 补零后的FFT点数

// Inter reg or wire
wire rd_clk;
wire wr_clk;
wire full,empty;

wire wr_en;
wire rd_en;

wire [BIT_WIDTH-1:0] dout;
wire fifo_valid;

// 赋值
// assign din = wr_counter_en? data_in : 0;
assign data_out = fifo_valid? dout : 0;
assign rd_clk = clk;
assign wr_clk = clk;

// 生成数据输出有效信号data_valid
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        data_valid <= 0;
    else
        data_valid <= rd_en;
end

// Wr_En 信号的生成状态机
FIFO_In_Wr_StateMachine WrEn_FSM 
(
    .rst(rst), 
    .clk(clk), 
    .start(start), 
    .nPointsPerBin(nPointsPerBin), 
    .Mirror_Position(Mirror_Position), 
    .End_Position(End_Position), 
    .wr_en(wr_en)
    );

// Rd_En 信号的生成状态机
FIFO_In_Rd_StateMachine RdEn_FSM 
(
    .rst(rst), 
    .clk(clk), 
    .empty(empty), 
    .RANGEBIN_LENGTH(nPointsPerBin), 
    .rd_en(rd_en)
    );

// FIFO IN IP
// 输入位宽28bit，输出位宽14bit，写入深度2048。读写时钟同步。
// 可容纳4096点，对于16个距离门来说，最大需要250*16=4000个点
fifo_Buffer_in Fifo_Buffer_in_m (
                   .rst(rst), // input rst
                   .wr_clk(wr_clk), // input wr_clk
                   .rd_clk(rd_clk), // input rd_clk
                   .din(data_in), // input [BIT_WIDTH*2-1 : 0] din
                   .wr_en(wr_en), // input wr_en
                   .rd_en(rd_en), // input rd_en
                   .dout(dout), // output [BIT_WIDTH-1 : 0] dout
                   .full(full), // output full
                   // .almost_full(almost_full), // output almost_full
                   // .wr_ack(wr_ack), // output wr_ack
                   // .overflow(overflow), // output overflow
                   .empty(empty), // output empty
                   // .almost_empty(almost_empty), // output almost_empty
                   .valid(fifo_valid) // output valid
                   // .underflow(underflow), // output underflow
                   // .rd_data_count(rd_data_count) // output [9 : 0] rd_data_count
               );

endmodule
