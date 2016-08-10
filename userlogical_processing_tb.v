`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:   20:51:22 07/07/2016
// Design Name:   user_logic_signal_processing
// Module Name:   D:/CustomerCD/FPGA/implementation/xilinx/userlogical_processing_test.v
// Project Name:  ADQ214_devkit
// Target Device:
// Tool versions:
// Description:
//
// Verilog Test Fixture created by ISE for module: user_logic_signal_processing
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
////////////////////////////////////////////////////////////////////////////////

module userlogical_processing_tb;

// Inputs
reg clk_i;
reg rst_i;
reg [15:0] x0_i;
reg [15:0] x0z_i;
reg [15:0] x1_i;
reg [15:0] x1z_i;
reg [3:0] trigger_vector_i;
reg [127:0] user_register_i;

// Outputs
wire [15:0] y0_o;
wire [15:0] y0z_o;
wire [15:0] y1_o;
wire [15:0] y1z_o;
wire [3:0] trigger_vector_o;
wire [63:0] user_register_o;
wire [15:0] ul_partnum_1_o;
wire [15:0] ul_partnum_2_o;
wire [15:0] ul_partnum_3_o;
wire [15:0] ul_partnum_rev_o;

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
                                 .user_register_i(user_register_i),
                                 .user_register_o(user_register_o),
                                 .ul_partnum_1_o(ul_partnum_1_o),
                                 .ul_partnum_2_o(ul_partnum_2_o),
                                 .ul_partnum_3_o(ul_partnum_3_o),
                                 .ul_partnum_rev_o(ul_partnum_rev_o)
                             );

//读取数据
reg signed [15:0] mem[3999:0];

initial begin
    $readmemb("sinewave.txt",mem);

    // Initialize Inputs
    clk_i = 0;
    rst_i = 1;
    x0_i = 0;
    x0z_i = 0;
    x1_i = 0;
    x1z_i = 0;
    trigger_vector_i = 0;
    user_register_i = 0;

    // Wait 100 ns for global reset to finish
    #100;
    rst_i = 0;
    user_register_i = 16;
    #50;
    trigger_vector_i = 4'b0001;
    #5;
    trigger_vector_i = 4'b0000;
    #200;
    trigger_vector_i = 4'b0100;
    #5;
    trigger_vector_i = 4'b0000;
    #200;
    trigger_vector_i = 4'b1000;
    #5;
    trigger_vector_i = 4'b0000;
    #200;
    trigger_vector_i = 4'b1000;
    #5;
    trigger_vector_i = 4'b0000;
    #90000;
    rst_i = 1;

    // Add stimulus here

end

//为模块输入端口赋值
integer rp = 0;
integer rp_z = 1;
always @(posedge clk_i)
begin
    if(rp < 4000)
    begin
        x0_i = mem[rp];
        rp = rp + 2;
    end
    else
        x0_i = 0;
end

always @(posedge clk_i)
begin
    if(rp_z < 4000)
    begin
        x0z_i = mem[rp_z];
        rp_z = rp_z + 2;
    end
    else
        x0z_i = 0;
end

//定义时钟
always #2.5 clk_i = ~clk_i;

//停止仿真
initial
begin
    #15000 ;//$stop;	//第一组1024点FFT完成
    #35000 ;//$stop;	//第八组1024点FFT完成
	$fclose(output_file);
	$finish;
end

// 文件打开
initial
begin
    output_file = $fopen("..\\..\\source\\Matlab_verify\\FFT_SPEC_out.txt","w");
	if (!output_file)
		begin
			$display("Could not open \"FFT_SPEC_out.txt\"");
			$stop;
		end
end

//将第一个脉冲的功率谱计算结果写入文件
always @(posedge clk_i)
begin
    if(uut.Power_Spec_Cal_m.data_valid)
        $fwrite(output_file,"%d\t%d\n",uut.SPEC_Acc_m.data_index,uut.Power_Spec_Cal_m.Power_Spec);
end

endmodule

