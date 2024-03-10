
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

module coeffecient_Memory(
    input logic en,
    input logic cntrl_rst,
    input logic wr,
    input logic start,
    input logic [8:0] wr_Addr,
    input logic [8:0] rd_Addr,
    input logic [15:0] data_In,
    output reg w_Done,
    output reg data_Valid,
    output reg [15:0] data_Out
    );
  
  reg [15:0] memory [511:0];
  always @(start or en) begin
    if(start == 1'b1) begin
      w_Done <= 1'b0;
      data_Valid <= 1'b0;
      data_Out <= 16'h0000;
    end
    else if(en == 1'b1) begin
      if (cntrl_rst == 1'b1) begin
        memory[wr_Addr] <= 16'h0000;
        w_Done <= 1'b1;
      end
      else begin
        if (wr == 1'b1) begin
          memory[wr_Addr] <= data_In[15:0];
          w_Done <= 1'b1;
        end
        else begin
          data_Out <= memory[rd_Addr];
          data_Valid <= 1'b1;
        end
      end
    end
    else begin
      w_Done <= 1'b0;
      data_Valid <= 1'b0;
    end
  end
  
endmodule
