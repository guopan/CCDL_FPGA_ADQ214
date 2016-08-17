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
          TOTAL_POINT = 1000,	//单脉冲处理点数的一半（因为2个数据/时钟）
          RANGEBIN_LENGTH = 250,	//每距离门处理点数
          NFFT = 1024				//补零后的FFT点数
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
reg [12:0] wr_counter;		//采样点计数器,FIFO写入点数控制
// reg [12:0] debug_counter;
reg [12:0] BinPoint_counter;	//距离门内采样点计数器，FIFO读出补零控制
reg [2:0] state,next_state;

wire [31:0] din;
wire [15:0] dout;
wire fifo_valid;
reg  wr_counter_en;	//读写计数器的使能信号，由输入start置高，有wr_en的下降沿置低
reg  wr_en_d;

//补零控制（FIFO读出）状态机，状态定义
parameter  IDLE = 4'b0001,
           READOUT_FIFO = 4'b0010,
           OUTPUT_ZERO = 4'b0100,
           READ_FINISH  = 4'b1000;

//赋值
assign din = wr_counter_en? data_in : 32'b0;
assign data_out = fifo_valid? dout : 16'b0;
assign rd_clk = clk;
assign wr_clk = clk;

//生成写入计数器的使能信号
//由start触发其置高
//由wr_en的下降沿清零
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

//生成数据输出有效信号data_valid
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        data_valid <= 0;
    else if(rd_en == 1 && fifo_valid == 0)	//rd_en的上升沿置高
        data_valid <= 1;
    else if(state == IDLE)
        data_valid <= 0;
    else
        data_valid <= data_valid;
end

//采样点计数器
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

//debug点计数器,比data_out晚一个时钟
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

//生成FIFO写入控制信号wr_en
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

//延迟wr_en信号1个clk，得到wr_en_d
always @(posedge clk or posedge rst)
begin
    if(rst == 1)
        wr_en_d <= 0;
    else
        wr_en_d <= wr_en;
end

//读控制计数循环
//在IDLE状态时，empty的下降沿开始计数
//再次回到IDLE状态时，停止计数
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

//状态转换条件描述
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

//状态输出描述
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
//输入位宽32bit，输出位宽16bit，写入深度4096。读写时钟同步。
//深度2048就够了
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
