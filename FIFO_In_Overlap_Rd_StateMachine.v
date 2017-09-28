`timescale 1ns / 1ps
//==============================================================================
// Copyright (C) 2017 By GUO Pan
// guopan@bit.edu.cn, All Rights Reserved
//==============================================================================
// Module : 	FIFO_In_Overlap_Rd_StateMachine
// Author : 	GUO Pan
// Contact : 	guopan@bit.edu.cn
// Date : 		Sep.10.2017
//==============================================================================
// Description :	用FSM，生成 FIFO_In_Overlap 的读使能信号rd_en
//==============================================================================

module FIFO_In_Overlap_Rd_StateMachine
       (
           // Colocking inputs
           input wire rst,
           input wire clk,

           // Signal inputs
           input wire start,
           input wire empty,
		   
           // Parameter inputs
           input wire [15:0] RANGEBIN_LENGTH,			// 距离门长度
		   
           // Signal outputs
           output reg rd_en
       );
parameter  NFFT = 15'd1024;				// 补零后的FFT点数

// Inter reg or wire
reg [14:0]  BinPoint_counter;	// 距离门内采样点计数器，FIFO读出补零控制;	
reg [3:0]  state, next_state;

// 补零控制（FIFO读出）状态机，状态定义
parameter  IDLE 		= 4'b0001,
           READOUT_FIFO = 4'b0010,
           OUTPUT_ZERO  = 4'b0100,
           READ_FINISH  = 4'b1000;

////////////////////////////////////////////////
// 状态机，控制FIFO的读出
////////////////////////////////////////////////
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        state <= IDLE;
    else
        state <= next_state;
end

// 状态转换条件描述
always@(state,start,empty,BinPoint_counter,RANGEBIN_LENGTH)
begin
    case(state)
        IDLE:
        begin
            if(start == 1)
                next_state = READOUT_FIFO;
            else
                next_state = IDLE;
        end

        READOUT_FIFO:
        begin
            if(BinPoint_counter == RANGEBIN_LENGTH[14:0])
                next_state = OUTPUT_ZERO;
            else
                next_state = READOUT_FIFO;
        end

        OUTPUT_ZERO:
        begin
            if(BinPoint_counter == NFFT)
            begin
                if(empty == 1)
                    next_state = READ_FINISH;
                else
                    next_state = READOUT_FIFO;
            end
            else
                next_state = OUTPUT_ZERO;
        end

        READ_FINISH:
        begin
            if(BinPoint_counter == 1)
                next_state = IDLE;
            else
                next_state = READ_FINISH;
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
            rd_en <= 0;
        end

        READOUT_FIFO:
        begin
            rd_en <= 1;
        end

        OUTPUT_ZERO:
        begin
            rd_en <= 0;
        end

        READ_FINISH:
        begin
            rd_en <= 0;
        end

        default:
        begin
            rd_en <= 0;
        end

    endcase
end

// 读控制计数循环
// 在IDLE状态时，empty的下降沿开始计数
// 再次回到IDLE状态时，停止计数
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        BinPoint_counter <= 0;
    else if(start == 0 && state == IDLE)
        BinPoint_counter <= 0;
    else if(BinPoint_counter == NFFT)
        BinPoint_counter <= 1;
    else
        BinPoint_counter <= BinPoint_counter + 1;
end

endmodule
