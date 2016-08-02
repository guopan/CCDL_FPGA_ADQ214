//////////////////////////////////////////////////////////////////////////////////
//
// Copyright © 2009 Signal Processing Devices Sweden AB. All rights reserved.
//
// Module Name:    SPI_registers
// Project Name:   ADQ
// Revision:       $Revision: 19553 $
// Description:
//
//////////////////////////////////////////////////////////////////////////////////
`include "config.v"
`include "swrev.v"

module SPI_registers
       (
           input wire        clk_i,
           input wire        wr_en_i,
           input wire        rd_en_i,
           input wire [14:0] address_i,
           input wire [15:0] data_i,
           output reg [15:0] data_o,
           output reg [2:0]  idelay_control_o,

           (* TIG = "TRUE" *) input wire [15:0] ur_0_i,
           (* TIG = "TRUE" *) input wire [15:0] ur_1_i,
           (* TIG = "TRUE" *) input wire [15:0] ur_2_i,
           (* TIG = "TRUE" *) input wire [15:0] ur_3_i,
           (* TIG = "TRUE" *) input wire [15:0] ur_4_i,
           (* TIG = "TRUE" *) input wire [15:0] ur_5_i,
           (* TIG = "TRUE" *) input wire [15:0] ur_6_i,
           (* TIG = "TRUE" *) input wire [15:0] ur_7_i,
           (* TIG = "TRUE" *) output reg [15:0] ur_0_o,
           (* TIG = "TRUE" *) output reg [15:0] ur_1_o,
           (* TIG = "TRUE" *) output reg [15:0] ur_2_o,
           (* TIG = "TRUE" *) output reg [15:0] ur_3_o,
           (* TIG = "TRUE" *) output reg [15:0] ur_4_o,
           (* TIG = "TRUE" *) output reg [15:0] ur_5_o,
           (* TIG = "TRUE" *) output reg [15:0] ur_6_o,
           (* TIG = "TRUE" *) output reg [15:0] ur_7_o,

           (* TIG = "TRUE" *) output reg [15:0] ur_8_o,
           (* TIG = "TRUE" *) output reg [15:0] ur_9_o,

           (* TIG = "TRUE" *) output reg [15:0] ur_10_o,
           (* TIG = "TRUE" *) output reg [15:0] ur_11_o,

           (* TIG = "TRUE" *) output reg [15:0] ur_12_o,
           (* TIG = "TRUE" *) output reg [15:0] ur_13_o,

           (* TIG = "TRUE" *) output reg [15:0] ur_14_o,
           (* TIG = "TRUE" *) output reg [15:0] ur_15_o,

           (* TIG = "TRUE" *) output reg [15:0] ur_16_o,
           (* TIG = "TRUE" *) output reg [15:0] ur_17_o,

           (* TIG = "TRUE" *) output reg [15:0] ur_18_o,
           (* TIG = "TRUE" *) output reg [15:0] ur_19_o,

           (* TIG = "TRUE" *) output reg [15:0] ur_20_o,
           (* TIG = "TRUE" *) output reg [15:0] ur_21_o,

           (* TIG = "TRUE" *) output reg [15:0] ur_22_o,
           (* TIG = "TRUE" *) output reg [15:0] ur_23_o,

           (* TIG = "TRUE" *) output reg [15:0] ur_24_o,
           (* TIG = "TRUE" *) output reg [15:0] ur_25_o,

           (* TIG = "TRUE" *) output reg [15:0] ur_26_o,
           (* TIG = "TRUE" *) output reg [15:0] ur_27_o,

           (* TIG = "TRUE" *) output reg [ 27:0] ur_dv_o,

           (* TIG = "TRUE" *) output reg [3:0] afe_ctrl_o,
           (* TIG = "TRUE" *) output reg [15:0] sample_skip_value_o,
           (* TIG = "TRUE" *) output reg signed [15:0] gain_control_1_o,
           (* TIG = "TRUE" *) output reg signed [15:0] offset_control_1_o,
           (* TIG = "TRUE" *) output reg signed [15:0] gain_control_2_o,
           (* TIG = "TRUE" *) output reg signed [15:0] offset_control_2_o,
           (* TIG = "TRUE" *) output reg signed [15:0] max_code_control_1_o,
           (* TIG = "TRUE" *) output reg signed [15:0] max_code_control_2_o,
           (* TIG = "TRUE" *) output reg signed [15:0] min_code_control_1_o,
           (* TIG = "TRUE" *) output reg signed [15:0] min_code_control_2_o,
           (* TIG = "TRUE" *) output reg [8:0] decim_ctrl_o,
           (* TIG = "TRUE" *) output reg [3:1] led_o,
           (* TIG = "TRUE" *) output reg [1:0] adc_powerdown_o,
           (* TIG = "TRUE" *) output reg [1:0] data_format_o,
           input wire [15:0] average_status_i,
           input wire [15:0] average_records_collected_i,
           (* TIG = "TRUE" *) output reg [15:0] average_control_o,
           (* TIG = "TRUE" *) output reg [15:0] debug_counter_control_o,
           (* TIG = "TRUE" *) output reg [15:0] debug_counter_init_value_o,
           (* TIG = "TRUE" *) output reg [15:0] debug_counter_bitwidth_o,
           (* TIG = "TRUE" *) output reg [15:0] trigger_counter_control_o,
           (* TIG = "TRUE" *) output reg [15:0] average_NofSampleCycles_o,
           (* TIG = "TRUE" *) output reg [15:0] average_NofPreTrigCycles_o,
           (* TIG = "TRUE" *) output reg [15:0] average_NofHoldoffCycles_o,
           (* TIG = "TRUE" *) output reg [15:0] average_NofReadoutWaitCycles_o,
           (* TIG = "TRUE" *) output reg [15:0] average_NofWaveforms_o,
           (* TIG = "TRUE" *) output reg [15:0] packet_streamer_PacketSize_o,
           (* TIG = "TRUE" *) output reg [15:0] packet_streamer_Control_o,
           (* TIG = "TRUE" *) output reg [15:0] packet_streamer_HoldoffCycles_o,
           (* TIG = "TRUE" *) output reg [15:0] packet_streamer_PreTrigCycles_o,

           input wire [15:0] ul_partnum_1_i,
           input wire [15:0] ul_partnum_2_i,
           input wire [15:0] ul_partnum_3_i,
           input wire [15:0] ul_partnum_rev_i

       );

reg [27:0]         ur_dv;
reg [15:0]         ur_0_in;
reg [15:0]         ur_1_in;
reg [15:0]         ur_2_in;
reg [15:0]         ur_3_in;
reg [15:0]         ur_4_in;
reg [15:0]         ur_5_in;
reg [15:0]         ur_6_in;
reg [15:0]         ur_7_in;

reg [2:0]          idelay_control_r;
reg [2:0]          idelay_control_r2;
reg                idelay_control_r3_2;

wire [31:0]        ver_reg;
reg [3:0]          afe_ctrl;
reg [15:0]         sample_skip_value;

reg [15:0]         gain_control_1 = 16'd1024;
reg [15:0]         gain_control_2 = 16'd1024;
reg [15:0]         offset_control_1 = 16'd0;
reg [15:0]         offset_control_2 = 16'd0;

reg signed [15:0]  max_code_control_1 = 16'd8191;
reg signed [15:0]  max_code_control_2 = 16'd8191;
reg signed [15:0]  min_code_control_1 = -16'd8192;
reg signed [15:0]  min_code_control_2 = -16'd8192;

reg [8:0]          decim_ctrl;
reg [3:1]          led;
reg [1:0]          adc_powerdown;
reg [1:0]          data_format;
reg [15:0] 	      average_status;
reg [15:0] 	      average_records_collected;
reg [15:0] 	      average_control = 16'b0000_0000_0000_0000;
reg [15:0]         debug_counter_control = 16'b0000_0000_0000_0000;
reg [15:0]         debug_counter_init_value = 16'b0000_0000_0000_0000;
reg [15:0]         debug_counter_bitwidth = 16'b0000_0000_0000_0000;
reg [15:0]         trigger_counter_control = 16'b0000_0000_0000_0000;

// Constant register containing version information
assign ver_reg = {`VER_REG_PRJ, `VER_REG_FCN, `VER_REG_MAJORREV, `VER_REG_MINORREV, `VER_REG_REL};

// Pipelined output of registers
always @(posedge clk_i)
begin
    led_o <= led;
    afe_ctrl_o <= afe_ctrl;
    sample_skip_value_o <= sample_skip_value;
    decim_ctrl_o <= decim_ctrl;
    adc_powerdown_o <= adc_powerdown;
    data_format_o <= data_format;

    gain_control_1_o <= gain_control_1;
    gain_control_2_o <= gain_control_2;
    offset_control_1_o <= offset_control_1;
    offset_control_2_o <= offset_control_2;

    max_code_control_1_o <= max_code_control_1;
    max_code_control_2_o <= max_code_control_2;
    min_code_control_1_o <= min_code_control_1;
    min_code_control_2_o <= min_code_control_2;

    average_control_o <= average_control;
    debug_counter_control_o <= debug_counter_control;
    debug_counter_init_value_o <= debug_counter_init_value;
    debug_counter_bitwidth_o <= debug_counter_bitwidth;
    trigger_counter_control_o <= trigger_counter_control;

    ur_dv_o <= ur_dv;
end

// Input sampling
always @(posedge clk_i)
begin
    ur_0_in <= ur_0_i;
    ur_1_in <= ur_1_i;
    ur_2_in <= ur_2_i;
    ur_3_in <= ur_3_i;
    ur_4_in <= ur_4_i;
    ur_5_in <= ur_5_i;
    ur_6_in <= ur_6_i;
    ur_7_in <= ur_7_i;

    average_status <= average_status_i;
    average_records_collected <= average_records_collected_i;
end

// Read operation
always @(posedge clk_i)
    if (rd_en_i)
    case (address_i)
        /* First 4 registers are version information
         * Please keep to facilitate support */
        15'h0:
            data_o <= ver_reg[15:0];
        15'h1:
            data_o <= ver_reg[31:16];
        15'h2:
            data_o <= 16'd0;
        15'h3:
            data_o <= {`VER_REG_VLDTR, 8'd0};
        15'h4:
            data_o <= {`SWREV};
        15'h5:
            data_o <= {`SWMOD,`SWMIX, 14'd0};
        15'h6:
            data_o <= 16'd214;

        // User Defined registers

        15'h20:
            data_o <= ur_0_in;
        15'h21:
            data_o <= ur_1_in;
        15'h22:
            data_o <= ur_2_in;
        15'h23:
            data_o <= ur_3_in;
        15'h24:
            data_o <= ur_4_in;
        15'h25:
            data_o <= ur_5_in;
        15'h26:
            data_o <= ur_6_in;
        15'h27:
            data_o <= ur_7_in;

        15'h30:
            data_o <= ur_0_o;
        15'h31:
            data_o <= ur_1_o;
        15'h32:
            data_o <= ur_2_o;
        15'h33:
            data_o <= ur_3_o;
        15'h34:
            data_o <= ur_4_o;
        15'h35:
            data_o <= ur_5_o;
        15'h36:
            data_o <= ur_6_o;
        15'h37:
            data_o <= ur_7_o;

        15'h38:
            data_o <= ur_8_o;
        15'h39:
            data_o <= ur_9_o;


        15'h3A:
            data_o <= ur_10_o;
        15'h3B:
            data_o <= ur_11_o;

        15'h3C:
            data_o <= ur_12_o;
        15'h3D:
            data_o <= ur_13_o;

        15'h3E:
            data_o <= ur_14_o;
        15'h3F:
            data_o <= ur_15_o;

        15'h40:
            data_o <= ur_16_o;
        15'h41:
            data_o <= ur_17_o;

        15'h42:
            data_o <= ur_18_o;
        15'h43:
            data_o <= ur_19_o;

        15'h44:
            data_o <= ur_20_o;
        15'h45:
            data_o <= ur_21_o;

        15'h46:
            data_o <= ur_22_o;
        15'h47:
            data_o <= ur_23_o;

        15'h48:
            data_o <= ur_24_o;
        15'h49:
            data_o <= ur_25_o;

        15'h4A:
            data_o <= ur_26_o;
        15'h4B:
            data_o <= ur_27_o;
        // System registers, used by ADQ system

        15'h2AA0:
            data_o <= {sample_skip_value};

        15'h2AA1:
            data_o <= {14'h0, idelay_control_r};

        15'h2AA2:
            data_o <= {12'h0, afe_ctrl};

        15'h2AA3:
            data_o <= {7'h0, decim_ctrl};

        15'h2AAA:
            data_o <= {13'h0,led};

        15'h2AAB:
            data_o <= {14'd0, adc_powerdown};

        15'h2AAC:
            data_o <= {14'd0, data_format};

        15'h2AB0:
            data_o <= gain_control_1;

        15'h2AB1:
            data_o <= gain_control_2;

        15'h2AC0:
            data_o <= offset_control_1;

        15'h2AC1:
            data_o <= offset_control_2;

        15'h2AD0:
            data_o <= max_code_control_1;
        15'h2AD1:
            data_o <= max_code_control_2;
        15'h2AD2:
            data_o <= min_code_control_1;
        15'h2AD3:
            data_o <= min_code_control_2;

        15'h2AE0:
            data_o <= ul_partnum_1_i;
        15'h2AE1:
            data_o <= ul_partnum_2_i;
        15'h2AE2:
            data_o <= ul_partnum_3_i;
        15'h2AE3:
            data_o <= ul_partnum_rev_i;

        // Registers for averaging unit
        15'h2C00:
            data_o <= average_control;
        15'h2C01:
            data_o <= average_NofSampleCycles_o;
        15'h2C02:
            data_o <= average_NofWaveforms_o;
        15'h2C03:
            data_o <= average_NofPreTrigCycles_o;
        15'h2C04:
            data_o <= average_NofHoldoffCycles_o;
        15'h2C10:
            data_o <= {4'b1010, average_status[11:0]};
        15'h2C11:
            data_o <= average_records_collected;

        // Registers for packet streamer unit
        15'h2D00:
            data_o <= packet_streamer_Control_o;
        15'h2D01:
            data_o <= packet_streamer_PacketSize_o;
        15'h2D02:
            data_o <= packet_streamer_HoldoffCycles_o;
        15'h2D03:
            data_o <= packet_streamer_PreTrigCycles_o;
        15'h2D04:
            data_o <= debug_counter_control;
        15'h2D05:
            data_o <= debug_counter_init_value;
        15'h2D06:
            data_o <=  debug_counter_bitwidth;
        15'h2D07:
            data_o <=  trigger_counter_control;

        // Non-existing registers are read as zero
        default:
            data_o <= 16'd0;
    endcase

// Write operation
always @(posedge clk_i)
begin

    ur_dv <=28'h0; //Default value

    if (wr_en_i)
    case (address_i)
        // First four registers are read-only.
        // So nothing is done here

        // User defined registers
        // Registers 0x20-0x27 are read-only

        15'h30: begin
            ur_0_o <= data_i;
            ur_dv <=28'h01;
        end
        15'h31: begin
            ur_1_o <= data_i;
            ur_dv <=28'h02;
        end
        15'h32: begin
            ur_2_o <= data_i;
            ur_dv <=28'h04;
        end
        15'h33: begin
            ur_3_o <= data_i;
            ur_dv <=28'h08;
        end
        15'h34: begin
            ur_4_o <= data_i;
            ur_dv <=28'h10;
        end
        15'h35: begin
            ur_5_o <= data_i;
            ur_dv <=28'h20;
        end
        15'h36: begin
            ur_6_o <= data_i;
            ur_dv <=28'h40;
        end
        15'h37: begin
            ur_7_o <= data_i;
            ur_dv <=28'h80;
        end

        15'h38: begin
            ur_8_o <= data_i;
            ur_dv <=28'h100;
        end
        15'h39: begin
            ur_9_o <= data_i;
            ur_dv <=28'h200;
        end
        15'h3A: begin
            ur_10_o <= data_i;
            ur_dv <=28'h400;
        end
        15'h3B: begin
            ur_11_o <= data_i;
            ur_dv <=28'h800;
        end



        15'h3C: begin
            ur_12_o <= data_i;
            ur_dv <=28'h1000;
        end
        15'h3D: begin
            ur_13_o <= data_i;
            ur_dv <=28'h2000;
        end

        15'h3E: begin
            ur_14_o <= data_i;
            ur_dv <=28'h4000;
        end
        15'h3F: begin
            ur_15_o <= data_i;
            ur_dv <=28'h8000;
        end

        15'h40: begin
            ur_16_o <= data_i;
            ur_dv <=28'h10000;
        end
        15'h41: begin
            ur_17_o <= data_i;
            ur_dv <=28'h20000;
        end

        15'h42: begin
            ur_18_o <= data_i;
            ur_dv <=28'h40000;
        end
        15'h43: begin
            ur_19_o <= data_i;
            ur_dv <=28'h80000;
        end
        15'h44: begin
            ur_20_o <= data_i;
            ur_dv <=28'h100000;
        end
        15'h45: begin
            ur_21_o <= data_i;
            ur_dv <=28'h200000;
        end

        15'h46: begin
            ur_22_o <= data_i;
            ur_dv <=28'h400000;
        end
        15'h47: begin
            ur_23_o <= data_i;
            ur_dv <=28'h800000;
        end

        15'h48: begin
            ur_24_o <= data_i;
            ur_dv <=28'h1000000;
        end
        15'h49: begin
            ur_25_o <= data_i;
            ur_dv <=28'h2000000;
        end

        15'h4A: begin
            ur_26_o <= data_i;
            ur_dv <=28'h4000000;
        end
        15'h4B: begin
            ur_27_o <= data_i;
            ur_dv <=28'h8000000;
        end

        // System registers, used by ADQ system

        15'h2AA0:
            sample_skip_value <= data_i[15:0];

        15'h2AA1:
            idelay_control_r <= data_i[2:0];

        15'h2AA2:
            afe_ctrl <= data_i[3:0];

        15'h2AA3:
            decim_ctrl <= data_i[8:0];

        15'h2AAA:
            led <= data_i[2:0];       // update register with SPI data

        15'h2AAB:
            adc_powerdown <= data_i[1:0];

        15'h2AAC:
            data_format <= data_i[1:0];

        15'h2AB0:
            gain_control_1 <= data_i[15:0];

        15'h2AB1:
            gain_control_2 <= data_i[15:0];

        15'h2AC0:
            offset_control_1 <= data_i[15:0];

        15'h2AC1:
            offset_control_2 <= data_i[15:0];

        15'h2AD0:
            max_code_control_1 <= data_i[15:0];

        15'h2AD1:
            max_code_control_2 <= data_i[15:0];

        15'h2AD2:
            min_code_control_1 <= data_i[15:0];

        15'h2AD3:
            min_code_control_2 <= data_i[15:0];

        // Registers for averaging unit
        15'h2C00:
            average_control <= data_i[15:0];
        15'h2C01:
            average_NofSampleCycles_o <= data_i[15:0];
        15'h2C02:
            average_NofWaveforms_o <= data_i[15:0];
        15'h2C03:
            average_NofPreTrigCycles_o <= data_i[15:0];
        15'h2C04:
            average_NofHoldoffCycles_o <= data_i[15:0];
        15'h2C05:
            average_NofReadoutWaitCycles_o <= data_i[15:0];

        // Registers for packet streamer unit
        15'h2D00:
            packet_streamer_Control_o <= data_i[15:0];
        15'h2D01:
            packet_streamer_PacketSize_o <= data_i[15:0];
        15'h2D02:
            packet_streamer_HoldoffCycles_o <= data_i[15:0];
        15'h2D03:
            packet_streamer_PreTrigCycles_o <= data_i[15:0];
        15'h2D04:
            debug_counter_control <=  data_i[15:0];
        15'h2D05:
            debug_counter_init_value <=  data_i[15:0];
        15'h2D06:
            debug_counter_bitwidth <=  data_i[15:0];
        15'h2D07:
            trigger_counter_control <=  data_i[15:0];

        // Do nothing (Discard data) if target is non-existant
        default:
        begin end
    endcase // case (address_i)
end // always @ (posedge clk_i)

always @(posedge clk_i)
begin
    idelay_control_r2 <= idelay_control_r;
    idelay_control_r3_2 <= idelay_control_r2[2];

    if (idelay_control_r2[2] && ~idelay_control_r3_2)
        idelay_control_o <= idelay_control_r2[2:0];
    else
        idelay_control_o[2] <= 1'b0;

end


endmodule
