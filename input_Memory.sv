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


module input_Memory(
    input logic sClk,
    input logic start,
    input logic reset,
    input logic wr_En,
    input logic rd_En,
    input logic cntrl_rst,
    input logic [7:0] rd_Addr,
    input logic [7:0] wr_Addr,
    input logic [15:0] data_In,
    output reg w_Done,
    output reg sleep,
    output reg data_Valid,
    output reg [15:0] data_Out
    );
  
  reg [15:0] memory [255:0];
  reg [11:0] sleep_Cnt, temp_Sleep_Cnt;
  
  always @(posedge sClk) begin
    temp_Sleep_Cnt <= sleep_Cnt;
  end
  
  always @(wr_En or reset or start) begin
    if(reset == 1'b0) begin
      sleep 	<= 1'b0;
      sleep_Cnt <= 12'h0;
    end
    else if(start == 1'b1) begin
      w_Done 	<= 1'b0;
      sleep  	<= 1'b0;
      sleep_Cnt <= 12'h000;
	end
    else if(wr_En == 1'b1) begin
      if(cntrl_rst == 1'b1) begin
        memory[wr_Addr] <= 16'h0000;
        w_Done <= 1'b1;
      end 
      else begin
        memory[wr_Addr] = data_In;
        if( data_In == 16'h0000 ) 
          sleep_Cnt <= temp_Sleep_Cnt + 1'b1;
        
        else if(sleep_Cnt == 12'h320) begin
          sleep <= 1'b1;
          sleep_Cnt <= 12'h000;
        end
        w_Done = 1'b1;
      end
    end
    else begin
      w_Done = 1'b0;
    end
  end
  
  always @(rd_En or start) begin
    if(start == 1'b1) begin
      data_Out   <= 16'h0000;
      data_Valid <= 1'b0;
    end
    else if(rd_En == 1'b1) begin
      data_Out <= memory[rd_Addr];
      data_Valid = 1'b1;	
    end
    else begin
      data_Valid = 1'b0;
    end
  end

endmodule:input_Memory
