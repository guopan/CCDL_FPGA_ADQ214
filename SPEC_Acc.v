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
    input clk,
    input rst,
    // input [31:0] data_in,
	input data_valid_in,
    input [9:0] xk_index_reg1,			//��data_index��3����4��ʱ�ӣ��������ɶ���ַ
    input [9:0] data_index,
	input [4:0] RangeBin_Counter,
	
    output reg [13:0] wraddr_out,
    output reg [13:0] rdaddr_out,
    // output reg [31:0] data_out,
	output reg SPEC_Acc_Ctrl,
	output reg DPRAM_wea,
	output reg SPEC_Acc_Done
	
    );

// �Ƿ��ۼ�DPRAMԭ�����ݣ�ѡ������ź�
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        SPEC_Acc_Ctrl <= 0;
    else
        SPEC_Acc_Ctrl <= RangeBin_Counter > 1;		//����֤��>1����>0
end

// �ۼӹ��̵�ʹ�ܿ����ź�
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        DPRAM_wea <= 0;
    else
        DPRAM_wea <= data_valid_in;
end

// �ۼӽ����ı�־�ź�
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        SPEC_Acc_Done <= 0;
    else if(DPRAM_wea==1 && data_valid_in==0)
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

endmodule
