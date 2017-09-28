//////////////////////////////////////////////////////////////////////////////////
// (C)opyright 2008-2011 Signal Processing Devices Sweden AB
//
// Signal processing user logic
//
//////////////////////////////////////////////////////////////////////////////////
`define USER_LOGIC_PARTNUM_1 16'd0
`define USER_LOGIC_PARTNUM_2 16'd0
`define USER_LOGIC_PARTNUM_3 16'd0
`define USER_LOGIC_PARTNUM_REV 16'd0

module user_logic_signal_processing
       #(
           parameter NofBits = 16,
           parameter NofUserRegistersOut = 4
       )
       ( // Clocking input
           input wire                                 clk_i,
           input wire                                 rst_i,

           // Signal input
           input wire signed [NofBits-1:0]            x0_i,
           input wire signed [NofBits-1:0]            x0z_i,
           input wire signed [NofBits-1:0]            x1_i,
           input wire signed [NofBits-1:0]            x1z_i,

           // Trigger input
           input wire [3:0]                           trigger_vector_i,

           // Signal output
           output wire signed [NofBits-1:0]           y0_o,
           output wire signed [NofBits-1:0]           y0z_o,
           output wire signed [NofBits-1:0]           y1_o,
           output wire signed [NofBits-1:0]           y1z_o,
           output wire [3:0]                          trigger_vector_o,

           // Data_valid
           output wire 								   data_valid_o,

           //User registers
           input wire [16*8-1:0]                      user_register_i,
           output wire [16*NofUserRegistersOut-1:0]   user_register_o,

           output wire [15:0]                         ul_partnum_1_o,
           output wire [15:0]                         ul_partnum_2_o,
           output wire [15:0]                         ul_partnum_3_o,
           output wire [15:0]                         ul_partnum_rev_o

       );
parameter BIT_WIDTH = 14;

// ��ƽ�����ź�����
reg [15:0] Trigger_Level = 16'd500;
wire trigger_start;
wire [1:0] trigger_vector;
// FIFO_TC
wire [BIT_WIDTH*2-1:0] fifo_tc_dataout;
wire trigger_ready;
// FIFO_IN
wire [BIT_WIDTH-1 : 0] fifo_in_data_out;
wire fifo_in_valid, fifo_valid_to_overlap;

// FIFO_IN_OVERLAP
wire [BIT_WIDTH-1 : 0] fifo_in_overlap_data_out;
wire fifo_in_overlap_valid;

// �����׼���
wire [49:0] Power_Spec_1;
wire [49:0] Power_Spec_2;
wire data_valid_PSC_1;
wire data_valid_PSC_2;
wire dv_FFT_1;
wire dv_FFT_2;

// �������ۼӻ���
wire is_first_pls;
wire [63:0] FIFO_Buffer_data_out_1;
wire [63:0] FIFO_Buffer_data_out_2;
wire data_valid_o1;
wire data_valid_o2;

// ���������
wire [15:0] Pulse_counts;

// �ϴ�����
wire Upload_En_1;
wire Upload_En_2;

// �������
wire Capture_En;

// �ϴ��л�����
wire trigger_start_1;
wire trigger_start_2;
wire [63:0] data_out;


// SPI_CMD
wire [15:0] UR_EndPosition;
wire [15:0] UR_MirrorStart;
wire [15:0] UR_nOverlap;
wire [15:0] UR_nRangeBins;
wire [15:0] UR_nPoints_RB;
wire [15:0] UR_nACC_Pulses;
wire [15:0] UR_TriggerLevel;
wire [15:0] UR_CMD;

// ģ�����
reg [NofBits-1:0] y0_out;
reg [NofBits-1:0] y0z_out;
reg [NofBits-1:0] y1_out;
reg [NofBits-1:0] y1z_out;


// -----------------------------------------------------------------------------------------------
// This section sets the user logic part number, which can be set in the user logic build script
// using set_userlogicpartnumber and read out through the API using GetAlgUserLogicPartNumber().
// Either rebuild the project or modify the include file, in order to change part number.
   // `include "userlogicpartnumber.v"
assign ul_partnum_1_o      = `USER_LOGIC_PARTNUM_1;
assign ul_partnum_2_o      = `USER_LOGIC_PARTNUM_2;
assign ul_partnum_3_o      = `USER_LOGIC_PARTNUM_3;
assign ul_partnum_rev_o    = `USER_LOGIC_PARTNUM_REV;
//-----------------------------------------------------------------------------------------------

assign y0_o = y0_out;
assign y0z_o = y0z_out;
assign y1_o = y1_out;
assign y1z_o = y1z_out;
assign trigger_vector_o = trigger_vector_i;


// assign user_register_o = {(16*NofUserRegistersOut){1'b0}};

assign user_register_o[4*16-1:3*16] = UR_nPoints_RB;
assign user_register_o[3*16-1:2*16] = UR_nACC_Pulses;
assign user_register_o[2*16-1:1*16] = UR_TriggerLevel;
assign user_register_o[1*16-1:0*16] = UR_CMD;
// UR_HighLim_Spec;
// UR_LowLim_Spec;
// UR_nRangeBins;

// Trigger ����ģ�顣���������ʼ�źš�
Trigger_Generator Trigger_Generator_m (
                      .clk(clk_i),
                      .rst(rst_i),
                      .Capture_En(Capture_En|Upload_En_1|Upload_En_2),
                      .Trigger_Ready(trigger_ready),
                      .Trigger_Level(UR_TriggerLevel),
                      .x0_i(x0_i),
                      .x0z_i(x0z_i),
                      .trigger_start(trigger_start),
                      .trigger_vector(trigger_vector)
                  );

// FIFO_TC ģ�顣д�����1024������λ��32bit�����λ��32bit����дʱ��ͬ����
FIFO_TC FIFO_TC_m (
            .clk(clk_i),
            .rst(rst_i),
            .x0_i(x0_i),
            .x0z_i(x0z_i),
            .fifo_tc_dataout(fifo_tc_dataout),
            .trigger_tc_ready(trigger_ready)
        );

// FIFO_IN ģ��
// ����λ��28bit�����λ��14bit��д�����2048@28bit����дʱ��ͬ����
// ÿ�������ţ����� UR_nPoints_RB �����������㡣
// �������λ���۰룬����TOTAL_POINTS = UR_nTotalPoins/2
FIFO_in FIFO_in_m (
            .rst(rst_i),
            .clk(clk_i),
            .data_in(fifo_tc_dataout),
            .start(trigger_start & Capture_En),
			.nPointsPerBin(UR_nPoints_RB),
			.Mirror_Position(UR_MirrorStart),
			.End_Position(UR_EndPosition),	
            .data_out(fifo_in_data_out),
            .data_valid(fifo_in_valid),
			.fifo_valid(fifo_valid_to_overlap)
        );
		
// FIFO_IN_Overlap ģ��
// ����λ��14bit�����λ��14bit��д�����1024@14bit����дʱ��ͬ����
// ÿ�������ţ����� UR_nPoints_RB �����������㡣
// �������λ���۰룬����TOTAL_POINTS = UR_nTotalPoins/2
FIFO_in_Overlap FIFO_in_overlap_m (
            .rst(rst_i),
            .clk(clk_i),
            .data_in(fifo_in_data_out),
            .start(trigger_start & Capture_En),
            .fifo_valid_in(fifo_valid_to_overlap),
			.nPointsPerBin(UR_nPoints_RB),
			.nPoints_Overlap(UR_nOverlap),
            .data_out(fifo_in_overlap_data_out),
            .data_valid(fifo_in_overlap_valid)
        );
		
// ���������
Pulse_Counter Pulse_Counter_m (
                  .clk(clk_i),
                  .rst(rst_i),
                  .data_valid_i(dv_FFT_1|dv_FFT_2),
                  .Capture_En(Capture_En),
                  .Pulse_counts(Pulse_counts),
				  .is_first_pls(is_first_pls)
              );

// �����׼���ģ��1������1024��FFT�����书���ס�
Power_Spec_Cal Power_Spec_Cal_m1 (
                   .clk(clk_i),
                   .rst(rst_i),
                   .fft_start(fifo_in_valid),
                   .fifo_data(fifo_in_data_out),
                   .Power_Spec(Power_Spec_1),
                   .data_valid(data_valid_PSC_1),
                   .dv_FFT(dv_FFT_1)
               );

// �����׼���ģ��2������1024��FFT�����书���ס�
Power_Spec_Cal Power_Spec_Cal_m2 (
                   .clk(clk_i),
                   .rst(rst_i),
                   .fft_start(fifo_in_overlap_valid),
                   .fifo_data(fifo_in_overlap_data_out),
                   .Power_Spec(Power_Spec_2),
                   .data_valid(data_valid_PSC_2),
                   .dv_FFT(dv_FFT_2)
               );

// �������ۼӻ���Buffer	1
FIFO_Buffer FIFO_Buffer_m1 (
    .clk(clk_i), 
    .rst(rst_i), 
    .data_in(Power_Spec_1), 
	.trigger_start(trigger_start_1),
    .is_first_pls(is_first_pls), 
    .valid_in(data_valid_PSC_1), 
    .Buffer_En(Capture_En), 
    .data_out(FIFO_Buffer_data_out_1), 
	.Upload_En(Upload_En_1),
    .valid_out(data_valid_o1)
    );
	
// �������ۼӻ���Buffer	2
FIFO_Buffer FIFO_Buffer_m2 (
    .clk(clk_i), 
    .rst(rst_i), 
    .data_in(Power_Spec_2), 
	.trigger_start(trigger_start_2),
    .is_first_pls(is_first_pls), 
    .valid_in(data_valid_PSC_2), 
    .Buffer_En(Capture_En), 
    .data_out(FIFO_Buffer_data_out_2), 
	.Upload_En(Upload_En_2),
    .valid_out(data_valid_o2)
    );

// ����ɼ��������
Group_Ctrl Group_Ctrl_m (
    .clk(clk_i), 
    .rst(rst_i), 
    .Pulse_counts(Pulse_counts), 
    .UR_CMD(UR_CMD), 
    .TOTAL_PULSE(UR_nACC_Pulses), 
    .Capture_En(Capture_En)
    );

// Overlap˫ͨ�����ϴ��л�����
Upload_Switcher Upload_Switcher_m (
    .clk(clk_i), 
    .rst(rst_i), 
    .trigger_start(trigger_start), 
    .Upload_En(Upload_En_1|Upload_En_2), 
    .data_in_1(FIFO_Buffer_data_out_1), 
    .data_in_2(FIFO_Buffer_data_out_2), 
	.data_valid_i1(data_valid_o1),
	.data_valid_i2(data_valid_o2),
    .trigger_start_1(trigger_start_1), 
    .trigger_start_2(trigger_start_2), 
    .data_out(data_out),
    .data_valid_o(data_valid_o)
    );

//������λ����SPI����
SPI_CMD SPI_CMD_m (
    .clk(clk_i), 
    .rst(rst_i), 
    .CMD_Update_Disable(Capture_En), 
    .user_register_i(user_register_i), 
    .UR_EndPosition(UR_EndPosition), 
    .UR_MirrorStart(UR_MirrorStart), 
    .UR_nOverlap(UR_nOverlap), 
    .UR_nRangeBins(UR_nRangeBins), 
    .UR_nPoints_RB(UR_nPoints_RB), 
    .UR_nACC_Pulses(UR_nACC_Pulses), 
    .UR_TriggerLevel(UR_TriggerLevel), 
    .UR_CMD(UR_CMD)
    );

	
//��ģ�����y0_out��y0z_out��ֵ
always @ (posedge clk_i or posedge rst_i)
begin:CHANNELA_OUTPUT
    if(rst_i == 1)
    begin
        y0_out  <= 0;
        y0z_out <= 0;
    end
    else
    begin
        y0_out  <= data_out[63:48];
        y0z_out <= data_out[47:32];
    end
end

//��ģ�����y1_out��y1z_out��ֵ
always @ (posedge clk_i or posedge rst_i)
begin:CHANNELB_OUTPUT
    if(rst_i == 1)
    begin
        y1_out  <= 0;
        y1z_out <= 0;
    end
    else
    begin
        y1_out  <= data_out[31:16];
        y1z_out <= data_out[15:0];
    end
end
endmodule


