`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:00:26 08/12/2016 
// Design Name: 
// Module Name:    Group_Ctrl 
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
module Group_Ctrl(
    input wire clk,
    input wire rst,
    input wire [15:0] Pulse_counts,
	 
    output reg Capture_En,
	 output reg SPEC_Acc_Ctrl,
	 output reg Post_Process_Ctrl,
	 output reg Peak_Detection_Ctrl
    );
	
	
// 是否累加DPRAM原有数据，高：累加，低：不累加（第一个脉冲）
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        SPEC_Acc_Ctrl <= 0;
    else
        SPEC_Acc_Ctrl <= Pulse_counts > 1 && Pulse_counts < 3;
end
// 累计足够脉冲后，开始扣除背景噪声
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
	     Post_Process_Ctrl <= 0;
    else 
        Post_Process_Ctrl <= Pulse_counts > 2 && Pulse_counts < 4;
end
// 开始进行峰值探测
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
	     Peak_Detection_Ctrl <= 0; 
	 else
        Peak_Detection_Ctrl <= Pulse_counts > 3;
end		  
       	 
// 采集过程的使能信号，接收上位机指令置高，采集完成置低
// 代码未完成
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        Capture_En <= 0;
    else
        Capture_En <= 1;
end

endmodule
