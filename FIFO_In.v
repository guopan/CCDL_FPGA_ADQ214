`timescale 1ns / 1ps
//==============================================================================
// Copyright (C) 2017 By GUO Pan
// guopan@bit.edu.cn, All Rights Reserved
//==============================================================================
// Module : 	FIFO_in
// Author : 	GUO Pan
// Contact : 	guopan@bit.edu.cn
// Date : 		Jan.10.2017
//==============================================================================
// Description :	���ڻ����������ݣ���FFT������в���

//==============================================================================

module FIFO_in
       #( parameter BIT_WIDTH = 14 )
       (
           //Colocking inputs
           input wire rst,
           input wire clk,

           //Signal inputs
           input wire [BIT_WIDTH*2-1:0] data_in,

           //Trigger inputs
           input wire start,

           //Parameter inputs
           input wire [15:0] RANGEBIN_LENGTH,
           input wire [15:0] TOTAL_POINTS,		//�����崦�������һ�루��Ϊ2������/ʱ�ӣ�
           //���������� = TOTAL_POINTS * 2 / RANGEBIN_LENGTH - 1

           //Signal outputs
           output wire [BIT_WIDTH-1:0] data_out,
           output reg  data_valid
       );
parameter  NFFT = 1024;				//������FFT����

//Inter reg or wire
wire rd_clk;
wire wr_clk;
wire full,empty;

reg wr_en;
reg rd_en;
reg [12:0] wr_counter;		//�����������,FIFOд���������
// reg [12:0] debug_counter;
reg [10:0] BinPoint_counter;	//�������ڲ������������FIFO�����������
reg [3:0]  state, next_state;

wire [BIT_WIDTH*2-1:0] din;
wire [BIT_WIDTH-1:0] dout;
wire fifo_valid;
reg  wr_counter_en;	//��д��������ʹ���źţ�������start�øߣ���wr_en���½����õ�

//������ƣ�FIFO������״̬����״̬����
parameter  IDLE = 4'b0001,
           READOUT_FIFO = 4'b0010,
           OUTPUT_ZERO  = 4'b0100,
           READ_FINISH  = 4'b1000;

//��ֵ
assign din = wr_counter_en? data_in : 0;
assign data_out = fifo_valid? dout : 0;
assign rd_clk = clk;
assign wr_clk = clk;

//����д���������ʹ���ź�
//��start�������ø�
//��wr_en���½������㣨д�����㹻��������
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        wr_counter_en <= 0;
    else if(wr_counter >= TOTAL_POINTS)
        wr_counter_en <= 0;
    else if(start == 1)
        wr_counter_en <= 1;
    else
        wr_counter_en <= wr_counter_en;
end

//�������������Ч�ź�data_valid
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        data_valid <= 0;
    else if(rd_en == 1 && fifo_valid == 0)	// rd_en���������ø�
        data_valid <= 1;
    else if(state == IDLE)
        data_valid <= 0;
    else
        data_valid <= data_valid;
end

//�����������
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
    begin
        wr_counter <= 0;
    end
    else if(wr_counter_en == 0)
        wr_counter <= 0;
    else
        wr_counter <= wr_counter + 1;
end

//debug�������,��data_out��һ��ʱ��
// always @(posedge clk or posedge rst)
// begin
// if(rst == 1)
// begin
// debug_counter <= 0;
// end
// else if(data_valid == 0)
// debug_counter <= 0;
// else
// debug_counter <= debug_counter + 1;
// end

//����FIFOд������ź�wr_en
//һ��д�������㣬����RANGEBIN_LENGTH��Ҫ��2
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        wr_en <= 0;
    else if(wr_counter_en == 0)
        wr_en <= 0;
    else if(wr_counter >= TOTAL_POINTS)
        wr_en <= 0;
    else if(wr_counter >= RANGEBIN_LENGTH/2 && wr_counter < RANGEBIN_LENGTH)
        wr_en <= 0;		// 1��2������֮�䣬�������뾵�淴��Ŀ�϶������Ҫ����
    else
        wr_en <= 1;
end

//�����Ƽ���ѭ��
//��IDLE״̬ʱ��empty���½��ؿ�ʼ����
//�ٴλص�IDLE״̬ʱ��ֹͣ����
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        BinPoint_counter <= 0;
    else if(empty == 1 && state == IDLE)
        BinPoint_counter <= 0;
    else if(BinPoint_counter == NFFT)
        BinPoint_counter <= 1;
    else
        BinPoint_counter <= BinPoint_counter + 1;
end

////////////////////////////////////////////////
// ״̬��������FIFO�Ķ���
////////////////////////////////////////////////
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        state <= IDLE;
    else
        state <= next_state;
end

//״̬ת����������
always@(state,empty,BinPoint_counter)
begin
    case(state)
        IDLE:
        begin
            if(empty == 0)
                next_state = READOUT_FIFO;
            else
                next_state = IDLE;
        end

        READOUT_FIFO:
        begin
            if(BinPoint_counter == RANGEBIN_LENGTH)
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

//״̬�������
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

//FIFO IN IP
//����λ��28bit�����λ��14bit��д�����2048����дʱ��ͬ����
//������4096�㣬����16����������˵�������Ҫ250*16=4000����
fifo_Buffer_in Fifo_Buffer_in_m (
                   .rst(rst), // input rst
                   .wr_clk(wr_clk), // input wr_clk
                   .rd_clk(rd_clk), // input rd_clk
                   .din(din), // input [BIT_WIDTH*2-1 : 0] din
                   .wr_en(wr_en), // input wr_en
                   .rd_en(rd_en), // input rd_en
                   .dout(dout), // output [BIT_WIDTH-1 : 0] dout
                   .full(full), // output full
                   // .almost_full(almost_full), // output almost_full
                   // .wr_ack(wr_ack), // output wr_ack
                   // .overflow(overflow), // output overflow
                   .empty(empty), // output empty
                   // .almost_empty(almost_empty), // output almost_empty
                   .valid(fifo_valid) // output valid
                   // .underflow(underflow), // output underflow
                   // .rd_data_count(rd_data_count) // output [9 : 0] rd_data_count
               );

endmodule
