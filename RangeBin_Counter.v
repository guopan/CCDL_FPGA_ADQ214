`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:15:19 08/09/2016 
// Design Name: 
// Module Name:    RangeBin_Counter 
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
module RangeBin_Counter
	(
    input wire clk,
    input wire rst,
    input wire cal_done,
    input wire SPEC_Acc_Done,
    output reg [4:0] bin_counts
    );

reg cal_done_reg1;
reg cal_done_reg2;
reg cal_done_reg3;

//距离门计数器
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
    begin
        bin_counts <= 0;
    end
    else if(SPEC_Acc_Done)
        bin_counts <= 0;
    else if(cal_done_reg3 == 1)
        bin_counts <= bin_counts + 1;
    else
        bin_counts <= bin_counts;
end

//延迟cal_done信号3个clk，得到cal_done_reg3
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
	begin
        cal_done_reg1 <= 0;
        cal_done_reg2 <= 0;
        cal_done_reg3 <= 0;
	end
    else
	begin
        cal_done_reg1 <= cal_done;
        cal_done_reg2 <= cal_done_reg1;
        cal_done_reg3 <= cal_done_reg2;
	end
end

endmodule
