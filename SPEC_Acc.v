`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:24:46 08/08/2016 
// Design Name: 
// Module Name:    SPEC_Acc 
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
module SPEC_Acc(
    input wire clk,
    input wire rst,
    // input [31:0] data_in,
	 input wire data_valid_in,
    input wire [9:0] xk_index_reg1,			//比data_index早3个或4个时钟，用于生成读地址
    input wire [9:0] data_index,
	 input wire [4:0] RangeBin_Counter,			// 从1开始计数
	 input wire [9:0] RangeIn_counts,
	 input wire Post_Process_Ctrl,
	 input wire Peak_Detection_Ctrl,
	 
    output reg [13:0] wraddr_out,
    output reg [13:0] rdaddr_out,
	 output reg DPRAM_wea,
	 output reg DPRAM_BG_wea,
	 output reg SPEC_Acc_Done					// 累加结束的标志信号
	);

reg working;

// 累加过程的进行中的标志信号
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        working <= 0;
    else
        working <= data_valid_in;
end

// 累加结束的标志信号
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        SPEC_Acc_Done <= 0;
    else if(working==1 && data_valid_in==0)
        SPEC_Acc_Done <= 1;
	else
        SPEC_Acc_Done <= 0;
end

// 生成DPRAM读地址
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        rdaddr_out <= 0; 
    else
        rdaddr_out <= {RangeBin_Counter, xk_index_reg1};
end

// 生成DPRAM写地址
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        wraddr_out <= 0;
    else
        wraddr_out <= {RangeBin_Counter-1, data_index};
end

// 背景噪声DPRAM_BG的使能信号，仅在第一个距离门使能
// 背景噪声扣除控制信号为1时，DPRAM_BG使能一直有效
// 代码未完成
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        DPRAM_BG_wea <= 0;
	 else if(Post_Process_Ctrl == 1)
        DPRAM_BG_wea <= 1;	 
    else
        DPRAM_BG_wea <= data_valid_in && (RangeBin_Counter < 2);
end

// 累加过程的使能控制信号
// 背景扣除的使能控制信号
// 代码未完成
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        DPRAM_wea <= 0;
    else
        DPRAM_wea <= data_valid_in && (RangeBin_Counter > 1);
end

endmodule
