`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    17:47:02 07/26/2016
// Design Name:
// Module Name:    Trigger_m
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
module Trigger_Decoder(
           input wire clk,
           input wire rst,
           input wire Capture_En,
           input wire trigger_ready,
           input wire [3:0] trigger_vector,
           output reg trigger_start
       );

//根据触发向量，输出触发信号
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        trigger_start <= 0;
    else if(trigger_ready == 1 && Capture_En == 1)
        trigger_start <= |trigger_vector;
    else
        trigger_start <= 0;
end
endmodule
