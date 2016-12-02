`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    10:38:23 08/24/2016
// Design Name:
// Module Name:    Post_Process
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
module BG_Deduction(
           input wire clk,
           input wire rst,
           input wire BG_Deduction_EN,
           input wire data_valid_in,

           output reg BG_Deduction_Done,
           output reg PP_working
       );

//背景噪声扣除进行中的标志信号
always@(posedge clk or posedge rst)
begin
    if(rst == 1)
        PP_working <= 0;
    else if(BG_Deduction_EN == 0)
        PP_working <= 0;
    else
        PP_working <= data_valid_in;
end

//背景噪声扣除结束的标志信号
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        BG_Deduction_Done <= 0;
    else if(PP_working == 1 && data_valid_in == 0)
        BG_Deduction_Done <= 1;
    else
        BG_Deduction_Done <= 0;
end

endmodule
