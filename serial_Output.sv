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


module serial_Output(
    input logic en,
    input logic sClk,
    input logic start,
    input logic [39:0] data_In,
    output reg word_Sent,
    output reg data_Out
    );
  reg [5:0] out_Bit;
  reg [39:0] data;
  always @(posedge sClk or posedge start) begin
    if(start) begin
      data = 40'h0000000000;
      data_Out = 1'b0;
      out_Bit = 6'h00;
      word_Sent = 1'b0;
    end
    else begin
      if(en) begin
        data = data_In;
        data_Out = data[out_Bit];
        out_Bit = out_Bit + 1'b1;
        if(out_Bit == 6'h28) begin  // total 40 bits which is 28 in HEX
          word_Sent = 1'b1;
          out_Bit = 6'h00;
        end
      end
      else begin
        word_Sent = 1'b0;
      end
    end
  end	
    
endmodule:serial_Output
