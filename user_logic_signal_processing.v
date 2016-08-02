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

           //User registers
           input wire [16*8-1:0]                      user_register_i,
           output wire [16*NofUserRegistersOut-1:0]   user_register_o,

           output wire [15:0]                         ul_partnum_1_o,
           output wire [15:0]                         ul_partnum_2_o,
           output wire [15:0]                         ul_partnum_3_o,
           output wire [15:0]                         ul_partnum_rev_o

       );

//Inter wire or reg
///TR
wire trigger_valid;
wire trigger_ready;
wire trigger_start;
///TC
wire fifo_tc_valid;
wire [31:0] fifo_tc_dataout;
///IN
wire [31:0] fifo_in_data;
wire [15:0] data_out;
wire fifo_in_valid;
//FFT
wire [15:0] fft_in_data;
wire [15:0] fft_data_out_re;
wire [15:0] fft_data_out_im;
wire [9:0]  xn_index;
wire [9:0]  xk_index;
// wire [9:0]  scl_ch;
// wire scl_ch_we;
wire rfd,busy,edone,done,dv;

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

//Trigger 向量解码模块。输出触发开始信号。
Trigger_Decoder Trigger_Decoder_m (
                    .clk(clk_i),
                    .rst(rst_i),
                    .trigger_ready(trigger_ready),
                    .trigger_vector(trigger_vector_i),
                    .trigger_start(trigger_start)
                );

//FIFO_TC 模块。写入深度1024，输入位宽32bit，输出位宽32bit，读写时钟同步。
//读写使能延时69个时钟。
FIFO_TC FIFO_TC_m (
            .clk(clk_i),
            .rst(rst_i),
            .trigger(trigger_start),
            .x0_i(x0_i),
            .x0z_i(x0z_i),
            .fifo_tc_dataout(fifo_tc_dataout),
            .trigger_tc_ready(trigger_ready)
        );

//FIFO_IN 模块。输入位宽32bit，输出位宽16bit，写入深度4096。读写时钟同步。
//读数250个点后输出补零。
FIFO_in FIFO_in_m (
            .rst(rst_i),
            .clk(clk_i),
            .data_in(fifo_in_data),
            .start(trigger_start),
            .data_out(data_out),
            .data_valid(fifo_in_valid)
        );

//FFT_1024 模块。
Power_Spect_Cal Power_Spect_Cal_m (
                    .clk(clk_i),
                    .rst(rst_i),
                    .fft_start(fifo_in_valid),
                    .fifo_data(fft_in_data),
                    .fft_data_out_re(fft_data_out_re),
                    .fft_data_out_im(fft_data_out_im),
                    .xn_index(xn_index),
                    .xk_index(xk_index),
                    .rfd(rfd),
                    .busy(busy),
                    .edone(edone),
                    .done(done),
                    .dv(dv)
                );

endmodule


