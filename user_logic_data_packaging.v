//////////////////////////////////////////////////////////////////////////////////
// (C)opyright 2008-2011 Signal Processing Devices Sweden AB
//
// Data packaging user logic
// 
//////////////////////////////////////////////////////////////////////////////////


module user_logic_data_packaging
  #(
   parameter NofBits = 16,
   parameter NofUserRegistersOut = 4
   )
  ( // Clocking input
    input wire 				     clk_i,
    input wire 				     rst_i,

    // Signal input
    input wire signed [NofBits-1:0] 	     x0_i,
    input wire signed [NofBits-1:0] 	     x0z_i,
    input wire signed [NofBits-1:0] 	     x1_i,
    input wire signed [NofBits-1:0] 	     x1z_i,
    input wire 				     data_valid_i,

    // Trigger input
    input wire [3:0] 			     trigger_vector_i,
    output wire [3:0]          trigger_vector_o,

    // Signal output
    output wire signed [NofBits-1:0] 	     y0_o,
    output wire signed [NofBits-1:0] 	     y0z_o,
    output wire signed [NofBits-1:0] 	     y1_o,
    output wire signed [NofBits-1:0] 	     y1z_o,
    output wire 			     data_valid_o,

    //User registers
    input wire [16*8-1:0] 		     user_register_i,
    output wire [16*NofUserRegistersOut-1:0] user_register_o
    );

   assign y0_o  = x0_i;
   assign y0z_o = x0z_i;
   assign y1_o  = x1_i;
   assign y1z_o = x1z_i;
   assign trigger_vector_o = trigger_vector_i;
   assign data_valid_o = data_valid_i;
   
   assign user_register_o[16*NofUserRegistersOut-1:0] = {(16*NofUserRegistersOut){1'b0}};
   
endmodule


