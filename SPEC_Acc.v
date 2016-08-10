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
	input wire [4:0] RangeBin_Counter,
	
    output reg [13:0] wraddr_out,
    output reg [13:0] rdaddr_out,
    // output reg [31:0] data_out,
	output reg SPEC_Acc_Ctrl,
	output reg DPRAM_wea,
	output reg SPEC_Acc_Done
	
    );

// 是否累加DPRAM原有数据，选择控制信号
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        SPEC_Acc_Ctrl <= 0;
    else
        SPEC_Acc_Ctrl <= RangeBin_Counter > 1;		//待验证，>1还是>0
end

// 累加过程的使能控制信号
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        DPRAM_wea <= 0;
    else
        DPRAM_wea <= data_valid_in;
end

// 累加结束的标志信号
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        SPEC_Acc_Done <= 0;
    else if(DPRAM_wea==1 && data_valid_in==0)
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

endmodule
