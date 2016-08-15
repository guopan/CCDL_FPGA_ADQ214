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
wire data_valid_o;
wire [63:0] user_register_o;
wire [15:0] ul_partnum_1_o;
wire [15:0] ul_partnum_2_o;
wire [15:0] ul_partnum_3_o;
wire [15:0] ul_partnum_rev_o;

// �ļ����
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
reg pulse_tic;		// �����ظ�����źţ�10kHz��100��s

//��ȡ����
reg signed [15:0] mem[3999:0];

// ���������ظ�����ź�
initial begin
	pulse_tic = 0;
	repeat(100) @ (posedge clk_i);	//��ʼ�ӳ�
	pulse_tic = 1;
	forever # 50000 pulse_tic = ~ pulse_tic;
end

// ��Ҫ���Լ���
initial begin
    // Initialize Inputs
    clk_i = 1;
    rst_i = 1;
    x0_i = 0;
    x0z_i = 0;
    x1_i = 0;
    x1z_i = 0;
    trigger_vector_i = 0;
    user_register_i = 0;
	
    $readmemb("sinewave.txt",mem);

    // Wait 100 ns for global reset to finish
    #100;
    rst_i = 0;
    user_register_i = 16;
	
    // Add stimulus here
    #150;
    emit_1trigger(4'b0001);


    #300000;
    rst_i = 1;
	#5 rst_i = 0;
	
	#100000;
	$finish;

end

//�����Բ��Լ���
always @(posedge pulse_tic)
begin
	emit_1pulse(69,4'b0100);
end

//����ʱ��
always #2.5 clk_i = ~clk_i;	//	200MHz

//ֹͣ����
initial
begin
    #15000 ;//$stop;	//��һ��1024��FFT���
    #35000 ;//$stop;	//�ڰ���1024��FFT���
    $fclose(output_file);
    // $finish;
end

// �ļ���
initial
begin
    output_file = $fopen("..\\..\\source\\Matlab_verify\\FFT_SPEC_out.txt","w");
    if (!output_file)
    begin
        $display("Could not open \"FFT_SPEC_out.txt\"");
        $stop;
    end
end

// ����һ������Ĺ����׼�����д���ļ�
always @(posedge clk_i)
begin
    if(uut.Power_Spec_Cal_m.data_valid)
        $fwrite(output_file,"%d\t%d\n",uut.SPEC_Acc_m.data_index,uut.Power_Spec_Cal_m.Power_Spec);
end

// ��TASK������mem�е����ݣ����� x0_i �� x0z_i
task mem_data_output;
    input [31:0] tics;			// �������ݵ�������������4000��һ��
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

// ��TASK�����ɵ�����������
task emit_1trigger;
    input [3:0] trigger_vector;		//��������
    begin
		@ (posedge clk_i) trigger_vector_i = trigger_vector;
        # 5 trigger_vector_i = 0;
    end
endtask

// ��TASK�����ɵ�������������źţ���������������������
task emit_1pulse;
    input [15:0] Pre_trigger_clks;		// ���������ݵ��ӳ�ʱ����
    input [3:0] trigger_vector;		//��������
    begin
		emit_1trigger(trigger_vector);
        repeat (Pre_trigger_clks) @ (posedge clk_i);
        mem_data_output(4000);
    end
endtask

endmodule

