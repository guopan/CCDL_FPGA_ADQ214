//////////////////////////////////////////////////////////////////////////////////
// (C)opyright 2008-2011 Signal Processing Devices Sweden AB
//
// Signal processing user logic
//
//////////////////////////////////////////////////////////////////////////////////


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
           output wire 							   data_valid_o,

           //User registers
           input wire [16*8-1:0]                      user_register_i,
           output wire [16*NofUserRegistersOut-1:0]   user_register_o,

           output wire [15:0]                         ul_partnum_1_o,
           output wire [15:0]                         ul_partnum_2_o,
           output wire [15:0]                         ul_partnum_3_o,
           output wire [15:0]                         ul_partnum_rev_o

       );

//Inter wire or reg
//TR
wire trigger_valid;
wire trigger_ready;
wire trigger_start;
//TC
wire fifo_tc_valid;
wire [31:0] fifo_tc_dataout;
//IN
wire [31:0] fifo_in_data;
wire [15:0] data_out;
wire fifo_in_valid;
//FFT
wire [15:0] fft_in_data;
wire [15:0] fft_data_out_re;
wire [15:0] fft_data_out_im;
wire [9:0]  data_index;
wire FFT_done;
//�����׼���
wire [31:0] Power_Spec;
wire data_valid_PSC;
wire [9:0] xn_index;
wire [9:0] xk_index_reg1;
//˫��RAM
wire wea;
wire [13:0] addra_dpram;
reg [31:0] dina_dpram;
wire [13:0] addrb_dpram;
wire [31:0] doutb_dpram;

//�������ۼ�
wire SPEC_Acc_Ctrl;
wire DPRAM_wea;
wire SPEC_Acc_Done;

//�����ż�����
wire [4:0] RangeBin_counts;


// -----------------------------------------------------------------------------------------------
// This section sets the user logic part number, which can be set in the user logic build script
// using set_userlogicpartnumber and read out through the API using GetAlgUserLogicPartNumber().
// Either rebuild the project or modify the include file, in order to change part number.
   `include "userlogicpartnumber.v"
assign ul_partnum_1_o      = `USER_LOGIC_PARTNUM_1;
assign ul_partnum_2_o      = `USER_LOGIC_PARTNUM_2;
assign ul_partnum_3_o      = `USER_LOGIC_PARTNUM_3;
assign ul_partnum_rev_o    = `USER_LOGIC_PARTNUM_REV;
// -----------------------------------------------------------------------------------------------

assign y0_o = fft_data_out_re;
assign y0z_o = fft_data_out_im;
assign y1_o = x1_i;
assign y1z_o = x1z_i;
assign trigger_vector_o = trigger_vector_i;

assign fifo_in_data = fifo_tc_dataout;
assign fft_in_data = data_out;

assign user_register_o = {(16*NofUserRegistersOut){1'b0}};

//Trigger ��������ģ�顣���������ʼ�źš�
Trigger_Decoder Trigger_Decoder_m (
                    .clk(clk_i),
                    .rst(rst_i),
                    .trigger_ready(trigger_ready),
                    .trigger_vector(trigger_vector_i),
                    .trigger_start(trigger_start)
                );

//FIFO_TC ģ�顣д�����1024������λ��32bit�����λ��32bit����дʱ��ͬ����
//��дʹ����ʱ69��ʱ�ӡ�
FIFO_TC FIFO_TC_m (
            .clk(clk_i),
            .rst(rst_i),
            .trigger(trigger_start),
            .x0_i(x0_i),
            .x0z_i(x0z_i),
            .fifo_tc_dataout(fifo_tc_dataout),
            .trigger_tc_ready(trigger_ready)
        );

//FIFO_IN ģ�顣����λ��32bit�����λ��16bit��д�����4096����дʱ��ͬ����
//����250�����������㡣
FIFO_in FIFO_in_m (
            .rst(rst_i),
            .clk(clk_i),
            .data_in(fifo_in_data),
            .start(trigger_start),
            .data_out(data_out),
            .data_valid(fifo_in_valid)
        );

//�����׼���ģ�飬����1024��FFT�����书���ס�
Power_Spec_Cal Power_Spec_Cal_m (
                   .clk(clk_i),
                   .rst(rst_i),
                   .fft_start(fifo_in_valid),
                   .fifo_data(fft_in_data),
                   .Power_Spec(Power_Spec),
                   .xn_index(xn_index),
                   .xk_index_reg1(xk_index_reg1),
                   .data_index(data_index),
                   .data_valid(data_valid_PSC),
				   .FFT_done(FFT_done)
               );

//�����״洢ģ�飬˫��RAM��λ��32�����16*1024��
DPRAM_Buffer DPRAM_Buffer_m (
                 .clka(clk_i), // input clka
                 .wea(DPRAM_wea), // input [0 : 0] wea, Port A��д�����ź�
                 .addra(addra_dpram), // input [13 : 0] addra
                 .dina(dina_dpram), // input [31 : 0] dina
                 .clkb(clk_i), // input clkb
                 .addrb(addrb_dpram), // input [13 : 0] addrb
                 .doutb(doutb_dpram) // output [31 : 0] doutb
             );

//�������ۼӿ���ģ�飬��DPRAM_Buffer�����ۼ�ֵ�����µĹ����������ۼӺ�д��ԭ��ַ
SPEC_Acc SPEC_Acc_m (
             .clk(clk_i),
             .rst(rst_i),
             .data_valid_in(data_valid_PSC),
             .xk_index_reg1(xk_index_reg1),
             .data_index(data_index),
             .RangeBin_Counter(RangeBin_counts),
             .wraddr_out(addra_dpram),
             .rdaddr_out(addrb_dpram),
             .SPEC_Acc_Ctrl(SPEC_Acc_Ctrl),
             .DPRAM_wea(DPRAM_wea),
			 .SPEC_Acc_Done(SPEC_Acc_Done)
         );

//�ۼӹ���
always @(posedge clk_i or posedge rst_i)
begin
    if(rst_i == 1)
        dina_dpram <= 0;
    else if(SPEC_Acc_Ctrl == 1)
        // dina_dpram <= Power_Spec + doutb_dpram;
        dina_dpram <= data_index + doutb_dpram;		//debug ��
    else
        // dina_dpram <= Power_Spec;		//����
        dina_dpram <= data_index;		//debug ��
end

//�����ż�����
RangeBin_Counter RangeBin_Counter_m (
    .clk(clk_i), 
    .rst(rst_i), 
    .cal_done(FFT_done), 
	.SPEC_Acc_Done(SPEC_Acc_Done),
    .bin_counts(RangeBin_counts)
    );

endmodule


