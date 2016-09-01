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
    input wire [9:0] xk_index_reg1,			//��data_index��3����4��ʱ�ӣ��������ɶ���ַ
    input wire [9:0] data_index,
	 input wire [4:0] RangeBin_Counter,			// ��1��ʼ����
	 input wire Post_Process_Ctrl,
	 
    output reg [13:0] wraddr_out,
    output reg [13:0] rdaddr_out,
	 output reg DPRAM_wea,
	 output reg DPRAM_BG_wea,
	 output reg SPEC_Acc_Done					// �ۼӽ����ı�־�ź�
	);

reg working;

// �ۼӹ��̵Ľ����еı�־�ź�
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        working <= 0;
    else
        working <= data_valid_in;
end

// �ۼӽ����ı�־�ź�
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        SPEC_Acc_Done <= 0;
    else if(working==1 && data_valid_in==0)
        SPEC_Acc_Done <= 1;
	else
        SPEC_Acc_Done <= 0;
end

// ����DPRAM����ַ
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        rdaddr_out <= 0;
    else
        rdaddr_out <= {RangeBin_Counter, xk_index_reg1};
end

// ����DPRAMд��ַ
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        wraddr_out <= 0;
    else
        wraddr_out <= {RangeBin_Counter-1, data_index};
end

// ��������DPRAM_BG��ʹ���źţ����ڵ�һ��������ʹ��
// ���������۳������ź�Ϊ1ʱ��DPRAM_BGʹ��һֱ��Ч
// ����δ���
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        DPRAM_BG_wea <= 0;
	 else if(Post_Process_Ctrl == 1)
        DPRAM_BG_wea <= 1;	 
    else
        DPRAM_BG_wea <= data_valid_in && (RangeBin_Counter < 2);
end

// �ۼӹ��̵�ʹ�ܿ����ź�
// �����۳���ʹ�ܿ����ź�
// ����δ���
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        DPRAM_wea <= 0;
    else
        DPRAM_wea <= data_valid_in && (RangeBin_Counter > 1);
end

endmodule
