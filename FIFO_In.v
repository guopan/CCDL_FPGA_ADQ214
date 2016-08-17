`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    10:00:19 07/11/2016
// Design Name:
// Module Name:    FIFO_ctrl
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
module FIFO_in
       #( parameter
          TOTAL_POINT = 1000,	//�����崦�������һ�루��Ϊ2������/ʱ�ӣ�
          RANGEBIN_LENGTH = 250,	//ÿ�����Ŵ������
          NFFT = 1024				//������FFT����
        )
       (
           //Colocking inputs
           input wire rst,
           input wire clk,

           //Signal inputs
           input wire [31:0] data_in,

           //Trigger inputs
           input wire start,

           //Signal outputs
           output wire [15:0] data_out,
           output reg  data_valid
       );

//Inter reg or wire
wire rd_clk;
wire wr_clk;
wire full,empty;

reg wr_en;
reg rd_en;
reg [12:0] wr_counter;		//�����������,FIFOд���������
// reg [12:0] debug_counter;
reg [12:0] BinPoint_counter;	//�������ڲ������������FIFO�����������
reg [2:0] state,next_state;

wire [31:0] din;
wire [15:0] dout;
wire fifo_valid;
reg  wr_counter_en;	//��д��������ʹ���źţ�������start�øߣ���wr_en���½����õ�
reg  wr_en_d;

//������ƣ�FIFO������״̬����״̬����
parameter  IDLE = 4'b0001,
           READOUT_FIFO = 4'b0010,
           OUTPUT_ZERO = 4'b0100,
           READ_FINISH  = 4'b1000;

//��ֵ
assign din = wr_counter_en? data_in : 32'b0;
assign data_out = fifo_valid? dout : 16'b0;
assign rd_clk = clk;
assign wr_clk = clk;

//����д���������ʹ���ź�
//��start�������ø�
//��wr_en���½�������
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        wr_counter_en <= 0;
    else if(wr_en_d == 1 && wr_en == 0)
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
    else if(rd_en == 1 && fifo_valid == 0)	//rd_en���������ø�
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
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        wr_en <= 0;
    else if(wr_counter_en == 0)
        wr_en <= 0;
    else if(wr_counter >= TOTAL_POINT)
        wr_en <= 0;
    else
        wr_en <= 1;
end

//�ӳ�wr_en�ź�1��clk���õ�wr_en_d
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        wr_en_d <= 0;
    else
        wr_en_d <= wr_en;
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
//����λ��32bit�����λ��16bit��д�����4096����дʱ��ͬ����
//���2048�͹���
fifo_Buffer_in Fifo_Buffer_in_m (
                        .rst(rst), // input rst
                        .wr_clk(wr_clk), // input wr_clk
                        .rd_clk(rd_clk), // input rd_clk
                        .din(din), // input [31 : 0] din
                        .wr_en(wr_en), // input wr_en
                        .rd_en(rd_en), // input rd_en
                        .dout(dout), // output [15 : 0] dout
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
