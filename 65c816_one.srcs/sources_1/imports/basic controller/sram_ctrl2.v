`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.10.2018 01:07:38
// Design Name: 
// Module Name: sram_ctrl2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sram_ctrl2(

  input wire clk,                        //  Clock signal
  input wire reset,                      //  Reset signal

  input wire rw,                         //  With this signal, we select reading or writing operation
  input wire wr_n,
  input wire rd_n,
  input wire [15:0] addr,                //  Address bus
  input wire [7:0] data_f2s,             //  Data to be written in the SRAM
  
  output wire [7:0] data_s2f_r,           //  It is the 8-bit registered data retrieved from the SRAM (the -s2f suffix stands for SRAM to FPGA)
  output wire [15:0] ad,                 //  Address bus
  output wire we_n,                      //  Write enable (active-low)
  output wire oe_n,                      //  Output enable (active-low)

  inout wire [7:0] dio_a,                //  Data bus
  output wire ce_a_n,                     //  Chip enable (active-low). Disables or enables the chip.
  input wire ram_e
  );

  assign ce_a_n = ram_e;
  //assign oe_n = (addr[15] == 0 || (addr >= 16'h9000 && addr < 16'hE000)) ? 1'b0 : 1'b1;
  //assign we_n = rw;
  assign oe_n = rd_n;
  assign we_n = wr_n; 
  assign ad = addr;
  
  assign dio_a = (rw == 1'b1)? 8'hZZ : data_f2s;
  assign data_s2f_r = (rw == 1'b1) ? dio_a : 8'hZZ; 
  
  //always @(posedge clk) begin
    //if (rw == 1'b1)
      //data_s2f_r <= dio_a;
  //end
endmodule