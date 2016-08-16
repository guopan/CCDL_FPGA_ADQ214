`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    15:31:05 07/14/2016
// Design Name:
// Module Name:    FIFO_TC
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
module FIFO_TC
       #(parameter
         DELAY_NUM = 69+4)		// +4 是为了匹配 FIFO_in 的读出延迟
       (
           input wire clk,
           input wire rst,
           input wire [15:0]	x0_i,
           input wire [15:0]	x0z_i,
           output wire [31:0]	fifo_tc_dataout,
           output reg         trigger_tc_ready
       );

// Inter wire or reg
reg   rd_en;
wire  wr_en;
wire  [31:0] data_in;
reg   [12:0] din_counter;
wire full;
wire empty;

// 赋值
assign wr_en = ~rst;
assign data_in = {x0_i,x0z_i};

// 计数器
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        din_counter <= 0;
    else if(din_counter < DELAY_NUM)
        din_counter <= din_counter + 1;
    else
        din_counter <= din_counter;
end

// 读信号延迟控制
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        rd_en <= 0;
    else if(din_counter < DELAY_NUM)
        rd_en <= 0;
    else
        rd_en <= 1;
end

//FIFO缓存结束，发出触发允许信号
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        trigger_tc_ready <= 0;
    else
        trigger_tc_ready <= rd_en;
end

//FIFO IP 写入深度1024，输入位宽32bit，输出位宽32bit，读写时钟同步
Fifo_Buffer_Tc Fifo_Buffer_Tc_m (
                   .clk(clk), // input clk
                   .rst(rst), // input rst
                   .din(data_in), // input [31 : 0] din
                   .wr_en(wr_en), // input wr_en
                   .rd_en(rd_en), // input rd_en
                   .dout(fifo_tc_dataout), // output [31 : 0] dout
                   .full(full), // output full
                   .empty(empty) // output empty
                   // .valid(valid) // output valid
               );

endmodule
