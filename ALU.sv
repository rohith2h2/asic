
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

module ALU(
    input logic sClk, 
    input logic reset,
    input logic en,
    input logic valid,
    input logic start,
    input logic x_FlagBit,
    input logic sleep,
    input logic r_Valid,
    input logic [15:0] rj_Data_In,
    input logic [15:0] x_Data_In,
    input logic [7:0] n,
    input logic h_Valid,
    input logic [15:0] h_Data_In,
    output reg prev_OutReady,
    output reg [39:0] y,
    output reg rj_En,
    output reg [3:0] rr_Ptr,
    output reg h_En,
    output reg [8:0] hr_Ptr,
    output reg x_Rd_En,
    output reg [7:0] xr_Ptr
    );
  reg [15:0] rj_Data;
  reg [4:0] rr_Ptr_Buff, rr_Ptr_Buff_Temp;
  reg rj_Read;
  reg [15:0] h_Data;
  reg [8:0] hr_Ptr_Buff, hr_Ptr_Buff_Temp;
  reg [7:0] h_Cntr;
  reg h_Read, calc, h_Finish, last_H, last_X;
  reg [15:0] x_Data;
  reg x_Read, x_Finish;
  reg [1:0] neg;
  reg h_Sign;
  reg [39:0] U;
  reg [39:0] u_Curr;
  
  always @ (posedge sClk or negedge reset or posedge start or posedge valid) begin
    if(reset == 1'b0) begin
      rj_En   <= 1'b0;
      rr_Ptr  <= 4'h0;
      rj_Data <= 16'h0000;
      rj_Read <= 1'b0;
      h_En    <= 1'b0;
      hr_Ptr  <= 9'h000;
      h_Cntr  <= 8'h00;
      h_Data  <= 16'h0000;
      h_Read  <= 1'b0;
      calc    <= 1'b0;
      h_Finish<= 1'b0;
      last_H  <= 1'b0;
      x_Rd_En <= 1'b0;
      xr_Ptr  <= 8'h00;
      x_Read  <= 1'b0;
      x_Data  <= 16'h0000;
      x_Finish<= 1'b0;
      last_X  <= 1'b0;
      U       <= 40'h0000000000;
      u_Curr  <= 40'h0000000000;
      y       <= 40'h0000000000;
      neg     <= 2'h0;
      prev_OutReady <= 1'b0;
    end
    else if(start == 1'b1) begin
      rj_En   <= 1'b0;
      rr_Ptr  <= 4'h0;
      rj_Data <= 16'h0000;
      rj_Read <= 1'b0;
      h_En    <= 1'b0;
      hr_Ptr  <= 9'h000;
      h_Cntr  <= 8'h00;
      h_Data  <= 16'h0000;
      h_Read  <= 1'b0;
      calc    <= 1'b0;
      h_Finish<= 1'b0;
      last_H  <= 1'b0;
      x_Rd_En <= 1'b0;
      xr_Ptr  <= 8'h00;
      x_Read  <= 1'b0;
      x_Data  <= 16'h0000;
      x_Finish<= 1'b0;
      last_X  <= 1'b0;
      U       <= 40'h0000000000;
      u_Curr  <= 40'h0000000000;
      y       <= 40'h0000000000;
      neg     <= 2'h0;
      prev_OutReady <= 1'b0;
	end
    else if(valid == 1'b1) begin
      rj_En = 1'b0;
      h_En = 1'b0;
      x_Rd_En = 1'b0; 
    end
    else begin
      if(en == 1'b1) begin
        prev_OutReady = 1'b0;
        if(sleep == 1'b0) begin
          if(x_Read == 1'b1) begin
            if(neg[1]== 1'b0) begin
              x_Data = x_Data_In;
            end
            else begin
              x_Data = 16'h0000; 
            end
            x_Read = 1'b0;
            if ( h_Sign== 1'b0 ) begin
              U = U + {{8{x_Data[15]}},x_Data,{16{1'b0}}};
              u_Curr = u_Curr + {{8{x_Data[15]}},x_Data,{16{1'b0}}};
            end
            else begin
              U = U - {{8{x_Data[15]}},x_Data,{16{1'b0}}};
              u_Curr = u_Curr - {{8{x_Data[15]}},x_Data,{16{1'b0}}};
            end
          end
          
          if(x_Finish== 1'b1) begin
            U = {U[39],U[39:1]};
            u_Curr = {40{1'b0}};
            if(last_X == 1'b1) begin
              last_X = 1'b0;
              y = U;
              prev_OutReady = 1'b1;
              calc = 1'b0;
            end
            x_Finish = 1'b0;
          end
          if(h_Finish== 1'b1) begin
            x_Finish = 1'b1;
            if(last_H== 1'b1) begin
              last_X = 1'b1;
            end
            h_Finish = 1'b0;
          end
          if(h_Read== 1'b1) begin 
            h_Data = h_Data_In;
            h_Read = 1'b0;
            calc = 1'b1;
          end
          if(calc== 1'b1) begin
            {neg,xr_Ptr} = {x_FlagBit, n} - h_Data[7:0];
            if( neg[1]== 1'b0 ) begin
              x_Rd_En = 1'b1;
            end
            h_Sign = h_Data[8];
            x_Read = 1'b1;
          end
          if(rj_Read== 1'b1) begin
            rj_Data = rj_Data_In;
            rj_Read = 1'b0;
          end
          if(h_Cntr != rj_Data) begin
            hr_Ptr = hr_Ptr_Buff;
            h_En = 1'b1;
            h_Read = 1'b1;
            h_Cntr = h_Cntr + 1'b1;
          end
          if(((h_Cntr == rj_Data) || (rr_Ptr_Buff == 4'h0)) && (last_H == 1'b0)) begin
            if(rr_Ptr == 4'hf) begin
              last_H = 1'b1;
              h_Finish = 1'b1;
              rr_Ptr = rr_Ptr_Buff;
            end
            else begin
              rr_Ptr = rr_Ptr_Buff;
              if(rr_Ptr != 1'b0) begin
                h_Finish = 1'b1;
              end
              h_Cntr = 8'h00;
              rj_En = 1'b1;
              rj_Read = 1'b1;
            end
          end
        end
      end
      else begin
        rj_En = 1'b0;
        rr_Ptr = 4'h0;
        rj_Data = 16'h0000;
        rj_Read = 1'b0;
        h_En = 1'b0;
        hr_Ptr = 9'h000;
        h_Cntr = 8'h00;
        h_Data = 16'h0000;
        h_Read = 1'b0;
        calc = 1'b0;
        h_Finish = 1'b0;
        last_H = 1'b0;
        x_Rd_En = 1'b0;
        x_Read = 1'b0;
        x_Data = 16'h0000;
        x_Finish = 1'b0;
        last_X = 1'b0;
        U = 40'h0000000000;
        u_Curr = 40'h0000000000;
        neg = 2'h0;
      end
    end
  end
  always @(negedge reset or posedge valid or posedge start) begin
    if (reset == 1'b0) begin
      rr_Ptr_Buff = 4'h0;
      hr_Ptr_Buff = 9'h000;
    end
    else if(start== 1'b1) begin
      rr_Ptr_Buff = 4'h0;
      hr_Ptr_Buff = 9'h000;
    end
    else begin
      if (r_Valid) begin
        rr_Ptr_Buff = rr_Ptr + 1'b1;
      end
      if (h_Valid) begin
        hr_Ptr_Buff = hr_Ptr + 1'b1;
      end
    end
  end

endmodule:ALU
