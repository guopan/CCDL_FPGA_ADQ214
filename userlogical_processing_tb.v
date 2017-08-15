`timescale 1ns / 1ps
//==============================================================================
// Copyright (C) 2016 By GUO Pan
// guopan@bit.edu.cn, All Rights Reserved
//==============================================================================
// Module : 	userlogical_processing_tb
// Author : 	GUO Pan
// Contact : 	guopan@bit.edu.cn
// Date : 		Jun.08.2016
//==============================================================================
// Description :	user_logic_signal_processing模块的测试台
//==============================================================================

module userlogical_processing_tb;

// Inputs
reg clk_i;
reg rst_i;
reg [15:0] x0_i;
reg [15:0] x0z_i;
reg [15:0] x1_i;
reg [15:0] x1z_i;
reg [3:0] trigger_vector_i;
wire [127:0] user_register_i;	// user_register_from_host

// Outputs
wire [15:0] y0_o;
wire [15:0] y0z_o;
wire [15:0] y1_o;
wire [15:0] y1z_o;
wire [3:0] trigger_vector_o;
wire data_valid_o;
wire [63:0] user_register_o;	// user_register_from_host
wire [15:0] ul_partnum_1_o;
wire [15:0] ul_partnum_2_o;
wire [15:0] ul_partnum_3_o;
wire [15:0] ul_partnum_rev_o;

// 上位机命令定义
reg [15:0] UR_nTotalPoins = 2000;
reg [15:0] UR_HighLim_Spec = 0;
reg [15:0] UR_LowLim_Spec = 0;
reg [15:0] UR_nRangeBins = 8;
reg [15:0] UR_nPoints_RB = 250;
reg [15:0] UR_nACC_Pulses = 3;
reg [15:0] UR_TriggerLevel = 500;
reg [15:0] UR_CMD = 0;

assign user_register_i[8*16-1:7*16] = UR_nTotalPoins;
assign user_register_i[7*16-1:6*16] = UR_HighLim_Spec;
assign user_register_i[6*16-1:5*16] = UR_LowLim_Spec;
assign user_register_i[5*16-1:4*16] = UR_nRangeBins;
assign user_register_i[4*16-1:3*16] = UR_nPoints_RB;
assign user_register_i[3*16-1:2*16] = UR_nACC_Pulses;
assign user_register_i[2*16-1:1*16] = UR_TriggerLevel;
assign user_register_i[1*16-1:0*16] = UR_CMD;

// 文件句柄
integer output_file;

// Instantiate the Unit Under Test (UUT)
user_logic_signal_processing uut (
                                 .clk_i(clk_i),
                                 .rst_i(rst_i),
                                 .x0_i(x0_i),
                                 .x0z_i(x0z_i),
                                 .x1_i(),
                                 .x1z_i(),
                                 .trigger_vector_i(trigger_vector_i),
                                 .y0_o(y0_o),
                                 .y0z_o(y0z_o),
                                 .y1_o(),
                                 .y1z_o(),
                                 .trigger_vector_o(trigger_vector_o),
                                 .data_valid_o(data_valid_o),
                                 .user_register_i(user_register_i),
                                 .user_register_o(user_register_o),
                                 .ul_partnum_1_o(ul_partnum_1_o),
                                 .ul_partnum_2_o(ul_partnum_2_o),
                                 .ul_partnum_3_o(ul_partnum_3_o),
                                 .ul_partnum_rev_o(ul_partnum_rev_o)
                             );

integer loop_i;
reg pulse_tic;		// 脉冲重复间隔信号，10kHz，100μs

//读取数据
reg signed [15:0] mem[3999:0];

// 生成脉冲重复间隔信号
initial begin
	pulse_tic = 0;
	repeat(100) @ (posedge clk_i);	//初始延迟
	pulse_tic = 1;
	forever # 50000 pulse_tic = ~ pulse_tic;
end

// 主要测试激励
initial begin
    // Initialize Inputs
    clk_i = 1;
    rst_i = 1;
    x0_i = 0;
    x0z_i = 0;
    x1_i = 0;
    x1z_i = 0;
    trigger_vector_i = 0;
	
    $readmemb("rangewave.txt",mem);

    // Wait 100 ns for global reset to finish
    #100;
    rst_i = 0;
    UR_CMD =  0;
	
    // Add stimulus here
    #150;
    emit_1trigger(4'b0001,0);		//一个过早的触发，理论上不应该响应
	UR_CMD = 1;

    #600000;
    rst_i = 1;
	#5 rst_i = 0;
	
	#1000000;
	$finish;

end

//周期性测试激励
//周期信号
always @(posedge pulse_tic)
begin
	mem_data_output(2000);
	// serial_data_output(2000);
end
//周期触发
always @(posedge pulse_tic)
begin
	emit_1trigger(4'b0100,69);
end

//定义时钟
always #2.5 clk_i = ~clk_i;	//	200MHz

//停止仿真
initial
begin
    // #15000 ;//$stop;	//第一组1024点FFT完成
    // #35000 ;//$stop;	//第八组1024点FFT完成
    #450000 
    $fclose(output_file);
    $stop;	//第3组脉冲完成
	// $finish;
end

// 文件打开
initial
begin
    output_file = $fopen("..\\..\\source\\Matlab_verify\\FIFO_out.txt","w");
    if (!output_file)
    begin
        $display("Could not open \"FIFO_out.txt\"");
        $stop;
    end
end

// 将输出的功率谱计算结果写入文件
reg output_sign = 0;
always @(posedge clk_i)
begin
   output_sign = uut.FIFO_Buffer_m.rd_en;
end

always @(posedge clk_i)
begin
   if(output_sign)
       $fwrite(output_file,"%d\n",uut.FIFO_Buffer_m.fifo_dout);
end

// 【TASK】读出mem中的数据，赋给 x0_i 和 x0z_i
task mem_data_output;
    input [31:0] tics;			// 读出数据的数量，不超过4000的一半
    begin
        loop_i = 0;
        repeat (tics) @ (posedge clk_i)
        begin
            x0_i = mem[loop_i];
            x0z_i = mem[loop_i+1];
            loop_i = loop_i + 2;
        end
		loop_i = 0;
    end
endtask

// 【TASK】生成单个触发向量
task emit_1trigger;
    input [3:0] trigger_vector;		// 触发向量
	input [15:0] Pre_trigger_clks;		// 触发延迟时钟数
    begin
	    repeat (Pre_trigger_clks) @ (posedge clk_i);
		#1 trigger_vector_i = trigger_vector;
        #5 trigger_vector_i = 0;
    end
endtask

// 【TASK】将自然数顺序，赋给 x0_i 和 x0z_i，用于调试
task serial_data_output;
    input [31:0] tics;			// 读出数据的数量，不超过4000的一半
    begin
        loop_i = 0;
        repeat (tics) @ (posedge clk_i)
        begin
            x0_i  = loop_i+1;
            x0z_i = loop_i+2;
            loop_i = loop_i + 2;
        end
		loop_i = 0;
    end
endtask
endmodule

