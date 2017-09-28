`timescale 1ns / 1ps
//==============================================================================
// Copyright (C) 2017 By GUO Pan
// guopan@bit.edu.cn, All Rights Reserved
//==============================================================================
// Module : 	FIFO_In_Wr_StateMachine
// Author : 	GUO Pan
// Contact : 	guopan@bit.edu.cn
// Date : 		Sep.10.2017
//==============================================================================
// Description :	用FSM，生成 FIFO_In 的写使能信号wr_en
//==============================================================================

module FIFO_In_Overlap_Wr_StateMachine
       (
           // Colocking inputs
           input wire rst,
           input wire clk,

           // Trigger inputs
           input wire start,

           // Parameter inputs
           input wire [15:0] nPointsPerBin,			// 噪声结束位置
           input wire [15:0] Mirror_Position,		// 镜面计算起点位置
           input wire [15:0] End_Position,			// 探测总点数结束位置，从预触发开始

           // Signal outputs
           output reg wr_en

       );
// Inter reg or wire
reg [14:0] Points_counter;		// 采样点计数器,FIFO写入点数控制，3km Max
reg [3:0]  state, next_state;

reg  Points_counter_en;	// 计数器的使能信号

// 镜面控制（FIFO写入）状态机，状态定义	   
parameter  IDLE 		= 4'b0001,
		   NOISE 		= 4'b0010,
           GAP  		= 4'b0100,
           RANGEBINS  	= 4'b1000;

////////////////////////////////////////////////
// 状态机，控制FIFO的写入
////////////////////////////////////////////////
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        state <= IDLE;
    else
        state <= next_state;
end

// 状态转换条件描述
always@(state,start,Points_counter,nPointsPerBin,Mirror_Position,End_Position)
begin
    case(state)
        IDLE:
        begin
            if(start == 1)
                next_state = NOISE;
            else
                next_state = IDLE;
        end

        NOISE:
        begin
            if(Points_counter == nPointsPerBin[15:1]-2)		// 除2了
                next_state = GAP;
            else
                next_state = NOISE;
        end

        GAP:
        begin
            begin
            if(Points_counter == Mirror_Position[15:1]-2)		// 除2了
                    next_state = RANGEBINS;
                else
                    next_state = GAP;
            end
        end

        RANGEBINS:
        begin
            if(Points_counter == End_Position[15:1]-2)		// 除2了
                next_state = IDLE;
            else
                next_state = RANGEBINS;
        end

        default:
            next_state = IDLE;
    endcase
end

// 状态输出描述
always@(posedge clk)
begin
    case(state)
        IDLE:
        begin
			Points_counter_en = 0;
            wr_en <= 0;
        end

        NOISE:
        begin
			Points_counter_en = 1;
            wr_en <= 1;
        end

        GAP:
        begin
			Points_counter_en = 1;
            wr_en <= 0;
        end

        RANGEBINS:
        begin
			Points_counter_en = 1;
            wr_en <= 1;
        end

        default:
        begin
			Points_counter_en = 0;
            wr_en <= 0;
        end

    endcase
end

// 采样点计数器
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
    begin
        Points_counter <= 0;
    end
    else if(Points_counter_en == 0)
		Points_counter <= 0;
    else
        Points_counter <= Points_counter + 1;
end

endmodule
