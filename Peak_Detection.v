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
module Peak_Detection
  #(parameter
    TOTAL_RANGEBIN = 9,
	 RANGE_IN_POINTS = 1024
    )  
	(
    input wire  clk,
	 input wire  rst,
	 input wire  Peak_Detection_EN,
	 //input wire data_valid_in,
	 //input wire data_valid_in_reg,//用于控制生成读数地址，比 data_valid_in 提前三个 clk
	 //input wire [4:0] RangBin_counts,
	 input wire  [31:0] D_in,
	 input wire  [9:0] D_addr,
	 
	 output reg  [13:0] PD_rdaddr,//PD模块读数地址
	 output wire [31:0] Peak_Value,
	 output wire [9:0] Peak_Addr,
	 output reg  [9:0] RangeIn_counts,
	 output reg  [3:0] RangeBin_reg//距离们标志信号
    );

reg data_valid;
reg [9:0]  RangeIn_counts_reg_1,RangeIn_counts_reg_2,RangeIn_counts_reg_3;
reg [13:0] PD_rdaddr_reg_1,PD_rdaddr_reg_2;
reg [31:0] P_MAX;
reg [13:0] P_addr;

//赋值
assign Peak_Value = data_valid?P_MAX:32'b0;
assign Peak_Addr = data_valid?P_addr:10'b0;

//生成读地址距离门编号
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        RangeBin_reg <= 0;
	 else if(RangeBin_reg == TOTAL_RANGEBIN)//距离门个数9+拟
	     RangeBin_reg <= 0;
    else if(Peak_Detection_EN == 1 && RangeIn_counts == RANGE_IN_POINTS-1 )		//add define
        RangeBin_reg <= RangeBin_reg + 1;
    else
        RangeBin_reg <= RangeBin_reg;
end		  

//生成距离门内计数
always @(posedge clk or posedge rst)
begin
    if(rst == 1)begin
	     RangeIn_counts <= 0;
		  end
	 else if(Peak_Detection_EN == 0)begin
	     RangeIn_counts <= 0;
		  end
	 else if(RangeIn_counts == RANGE_IN_POINTS)begin  //add define
        RangeIn_counts <= 0;
		  end
    else
	 RangeIn_counts <= RangeIn_counts + 1;
end

//生成读数地址
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
	     PD_rdaddr <= 0;
	 else if(Peak_Detection_EN == 1)
	     PD_rdaddr <= {RangeBin_reg , RangeIn_counts};
	 else 
        PD_rdaddr <= 0;
end		  
	 	  
//生成与数据匹配的地址
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
	 begin
		  RangeIn_counts_reg_1 <= 0;
		  RangeIn_counts_reg_2 <= 0;
		  RangeIn_counts_reg_3 <= 0;
		  end
	 else 
        RangeIn_counts_reg_1 <= RangeIn_counts;
        RangeIn_counts_reg_2 <= RangeIn_counts_reg_1;
        RangeIn_counts_reg_3 <= RangeIn_counts_reg_2;
end
//或可省略
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
	 begin	 
        PD_rdaddr_reg_1 <= 0;
        PD_rdaddr_reg_2 <= 0;
		  end
    else
        PD_rdaddr_reg_1 <= PD_rdaddr;
        PD_rdaddr_reg_2 <= PD_rdaddr_reg_1;
end

//或可省略的距离门匹配		  
		  
// 峰值比较器
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
	     P_MAX <= 0;
	 else if(Peak_Detection_EN == 0) 
	     P_MAX <= 0;
	 else if (RangeIn_counts_reg_3 == RANGE_IN_POINTS-1 || RangeIn_counts_reg_3 < RANGE_IN_POINTS/2 )
        P_MAX <= 0;
    else if(P_MAX < D_in)
        P_MAX <= D_in;
    else
        P_MAX <= P_MAX;
end		  

// 峰值地址输出
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
	     P_addr <= 0;
	 else if(Peak_Detection_EN == 0)
	     P_addr <= 0;
    else if(RangeIn_counts_reg_3 == RANGE_IN_POINTS-1)
        P_addr <= 0;
    else if(P_MAX < D_in)
        P_addr <= RangeIn_counts_reg_3;
    else 
        P_addr <= P_addr;
end		  

// 输出有效
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
	     data_valid <= 0;
	 else if(RangeIn_counts_reg_3 == RANGE_IN_POINTS-2)
        data_valid <= 1;
	 else
        data_valid <= 0;
end		  
     		  

    
endmodule
