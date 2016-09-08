`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:24:14 08/26/2016 
// Design Name: 
// Module Name:    Peak_Detection 
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
module Peak_Detection(
    input wire clk,
	 input wire rst,
	 input wire Peak_Detection_Ctrl,
	 input wire data_valid_in,
	 input wire [4:0] RangBin_counts,
	 input wire [31:0] D_out,
	 input wire [9:0] D_addr,
	 
	 output wire [31:0] Peak_Value,
	 output wire [9:0] Peak_Addr,
	 output reg [9:0] RangeIn_counts
    );

reg PD_working;
reg data_valid;
reg [31:0] P_MAX;
reg [9:0] P_addr;
reg [9:0] P_addr_reg;
reg [31:0] P_value_valid;

//��ֵ
assign Peak_Value = data_valid?P_MAX:32'b0;
assign Peak_Addr = data_valid?P_addr:10'b0;

//��ֵ̽������еı�־�ź�
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
	     PD_working <= 0;
	 else if(Peak_Detection_Ctrl == 0 && RangBin_counts < 2)	
        PD_working <= 0;	 
    else 
        PD_working <= data_valid_in;//��������������
end		  

//���ɾ������ڼ���
always @(posedge clk or posedge rst)
begin
    if(rst == 1)begin
	     RangeIn_counts <= 0;
		  end
	 else if(PD_working == 0)begin
	     RangeIn_counts <= 0;
		  end
	 else if(RangeIn_counts == 1024)begin
        RangeIn_counts <= 0;
		  end
    else
	 RangeIn_counts <= RangeIn_counts + 1;
end
	 
// �Ա任���ǰ�����������
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
	     P_value_valid <= 0;
	 else if(D_addr < 512)
        P_value_valid <= 0;
    else 
        P_value_valid <= D_out;
end		  

// ��ֵ�Ƚ���
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
	     P_MAX <= 0;
	 else if(PD_working == 0) 
	     P_MAX <= 0;
	 else if (RangeIn_counts == 1023)
        P_MAX <= 0;
    else if(P_MAX < P_value_valid)
        P_MAX <= P_value_valid;
    else
        P_MAX <= P_MAX;
end		  

// ��ֵ��ַ���
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
	     P_addr <= 0;
	 else if(PD_working == 0)
	     P_addr <= 0;
    else if(RangeIn_counts == 1023)
        P_addr <= 0;
    else if(P_MAX < P_value_valid)
        P_addr <= P_addr_reg;
    else 
        P_addr <= P_addr;
end		  

// ��ַ��Ϣ�ӳ�1clk,��������ƥ��
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
	     P_addr_reg <= 0;
	 else
        P_addr_reg <= D_addr;
end		  

// �����Ч
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
	     data_valid <= 0;
	 else if(RangeIn_counts > 1000)
        data_valid <= 1;
	 else
        data_valid <= 0;
end		  
     		  

    
endmodule
