`timescale 1ns / 1ps
//==============================================================================
// Copyright (C) 2017 By GUO Pan
// guopan@bit.edu.cn, All Rights Reserved
//==============================================================================
// Module : 	FIFO_Buffer
// Author : 	GUO Pan
// Contact : 	guopan@bit.edu.cn
// Date : 		Jan.10.2017
//==============================================================================
// Description :	利用FIFO进行功率谱累加
//==============================================================================

module FIFO_Buffer(
           input clk,
           input rst,
           input [49:0] data_in,
           input is_first_pls,
           input valid_in,
           input Buffer_En,			// 为高时累加缓冲，为低时输出结果

           output reg [63:0] data_out,
           output reg valid_out
       );


reg rd_en, wr_en, rd_en_reg;

reg  [63 : 0] fifo_din;
wire [63 : 0] fifo_dout;
wire empty, full, almost_empty;

reg  [0:2] valid_in_reg;

////////////////////////////////////////////////////////////////////////////////
// 生成FIFO写入控制信号wr_en
// Buffer_En为高，使能写入功能
////////////////////////////////////////////////////////////////////////////////
always @(posedge clk or posedge rst)
begin
    if(rst == 1 || Buffer_En == 0)
        wr_en <= 0;
    else
        wr_en <= valid_in_reg[2];
end

// 延迟valid_in
always @(posedge clk or posedge rst)
begin : delay_validin
    if (rst == 1'b1)
    begin
        valid_in_reg[0] <= 1'b0;
        valid_in_reg[1] <= 1'b0;
        valid_in_reg[2] <= 1'b0;
    end
    else
    begin
        valid_in_reg[0] <= valid_in;
        valid_in_reg[1] <= valid_in_reg[0];
        valid_in_reg[2] <= valid_in_reg[1];
    end
end

////////////////////////////////////////////////////////////////////////////////
// 生成FIFO读出控制信号rd_en
// Buffer_En为高，使能
// Buffer_En为高，选择FIFO的读出，用于累加，否则用于输出结果
// is_first_pls为高，表示第一个脉冲，不读取（只写入）
// 内部读取时：为valid_in，需要比wr_en早一个时钟
////////////////////////////////////////////////////////////////////////////////
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        rd_en <= 0;
    else if(Buffer_En == 0)
        rd_en <= ~almost_empty;
    else if(is_first_pls)
        rd_en <= 0;
    else
        rd_en <= valid_in;
end

// 累加过程_DPRAM
always @(posedge clk or posedge rst)
begin
    if(rst == 1 || Buffer_En == 0)
        fifo_din <= 0;
    else if(is_first_pls)
        fifo_din <= {14'd0, data_in};
    else
        fifo_din <= data_in + data_out;
end

// 缓冲功率谱数据用的 Buffer
// 数据位宽64，深度512*距离门数16 = 8192
FIFO_Depth_512 FIFO_Depth_512_m
               (
                   .clk(clk), // input clk
                   .srst(rst), // input srst
                   .din(fifo_din), // input [63 : 0] din
                   .wr_en(wr_en), // input wr_en
                   .rd_en(rd_en), // input rd_en
                   .dout(fifo_dout), // output [63 : 0] dout
                   .full(full), // output full
                   .empty(empty), // output empty
                   .almost_empty(almost_empty) // output almost_empty
               );

// 对 FIFO 的输出进行缓冲
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        data_out <= 0;
    else
        data_out <= fifo_dout;
end

// 生成 valid_out 信号
always @(posedge clk or posedge rst)
begin
    if(rst == 1 || Buffer_En == 1)
    begin
        rd_en_reg <= 0;
        valid_out <= 0;
    end
    else
    begin
        rd_en_reg <= rd_en;
        valid_out <= rd_en_reg;
    end
end
endmodule
