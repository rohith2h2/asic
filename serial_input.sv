`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Texas at Dallas
// Engineer: RXN220024
// 
// Create Date: 04/15/2023 06:04:14 PM
// Design Name: Mini Stereo - Digital Audio Processor
// Module Name: MSDAP
// Project Name: EEDG 6306 ASIC - MSDAP
// Target Devices: -
// Tool Versions: -
// Description: A top-level module is one which instantiates all other modules. 

// 
// Dependencies: NONE
// 
// Revision:NONE
// Revision 0.01 - File Created
// Additional Comments: 
// 
//////////////////////////////////////////////////////////////////////////////////

module serial_Input(
    input logic  frame_Edg,
    input logic  cntrl_rst,
    input logic  reset,
    input logic  dClk,
    input logic  data_In,
    input logic  ack,
    output reg w_Ready,
    output reg [15:0] data_Out
    );
  
  reg [3:0] out_Bit;
  always @ (negedge dClk or posedge cntrl_rst or posedge ack or negedge reset) begin
    if( reset == 1'b0 or cntrl_rst ) begin
      out_Bit    <= 4'h0;
      w_Ready	   <= 1'b0;
      data_Out   <= 16'h0000;
    end 
    // else if(cntrl_rst) begin
    //   out_Bit    <= 4'h0;
    //   w_Ready    <= 1'b0;
    //   data_Out   <= 16'h0000;
    // end 
    
    else if(ack == 1'b1)
      if(w_Ready== 1'b1)
        w_Ready <= 1'b0;
    
    else begin
      if (frame_Edg == 1'b1) begin
        if (out_Bit == 4'h0)
            w_Ready <= 1'b0;
        
        data_Out[out_Bit] <= data_In;
        {w_Ready,out_Bit} <= out_Bit+1'b1;
      
      end
        else begin
          out_Bit <= 4'h0;
          w_Ready <= 1'b0;
        end
    end   
  end
    
endmodule:serial_Input
