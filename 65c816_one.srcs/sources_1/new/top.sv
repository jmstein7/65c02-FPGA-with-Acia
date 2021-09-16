`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/09/2021 06:12:15 PM
// Design Name: 
// Module Name: top
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

module top(
    input clk,
    input wire acia_clk,
    input reset,
    output resb,
    inout [7:0] db,
    input [15:0] ab,
    input e_bit,
    input vpa,
    input vda,
    input rwb,
    output phi2,
    output LED,
    output LED_B,
    output nmib,
    output irqb,
    // to/from SRAM
    output wire [15:0] ad,   
    inout wire [7:0] dio_a, 
    output wire we_n,
    output wire oe_n,
    output wire ce_a_n, 
    //acia
    output wire rts,
    output wire tx,
    input wire rx,
    input wire cts
    );

    logic [7:0] acia_in;
    logic [7:0] acia_out;
    logic [7:0] spo; 

    wire ram_e, rom_e, acia_e, phi2_n, wr_n, rd_n;
    logic [7:0] di;
    logic [7:0] d_in; 
    logic [7:0] dout; 
    logic [15:0] address;
    reg [7:0] d; 
    
    //sram signals
    wire [7:0] data_f2s_bus;
    wire [7:0] data_s2f_r_bus;
    wire [7:0] s2f;
    wire [15:0] addr_bus;
    
    assign nmib = 1'b1;
    assign irqb = 1'b1; 
    assign wr_n = (~rwb && phi2) ? 1'b0 : 1'b1;
    assign rd_n = (rwb && phi2) ? 1'b0 : 1'b1;
    assign phi2_n = ~phi2; 
    assign s2f = data_s2f_r_bus;
    assign resb = ~reset; 
    assign addr_bus = address;
    assign ram_e = ((address[15] == 0) || (address >= 16'h9000 && address < 16'hC000)) ? 1'b0 : 1'b1; //RAM Enable_n
    assign data_f2s_bus = (~rwb && ram_e == 0) ? dout : 'bZ;
    
    //master signals and mux
    assign ab = address; 
    
    assign rom_e = (address >= 16'hC000) ? 1'b0 : 1'b1; 
    assign acia_e = (address >= 16'h8000 && address <= 16'h800F) ? 1'b0 : 1'b1;
    assign acia_in = (~rwb && acia_e == 0) ? dout : 'bZ;
    
    //tristate
    assign d = (rwb == 1 && phi2_n == 0) ? di : 'bZ; 
    assign db = (rwb == 1 && phi2_n == 0) ? d : 'bZ;
    assign dout = (rwb == 0 && phi2_n == 0) ? db : 'bZ; 
    
    assign di = (rwb) ? ((rom_e == 0 && phi2) ? spo : ((ram_e == 0) ? s2f : ((acia_e == 0) ? acia_out : 'bZ))) : 'bZ;
      
    assign LED = (resb) ? 1'b0 : 1'b1;
    assign LED_B = (resb) ? 1'b1 : 1'b0; 
    
clk_wiz_0 clock_a(
  // Clock in ports
  // Clock out ports
  .clk_out1(phi2),
  // Status and control signals
  .resetn(resb),
  .clk_in1(clk)
 );

sram_ctrl2 sram_one (
    .clk(clk), 
    .reset(reset), 
    .rw(rwb), 
    .wr_n(wr_n),
    .rd_n(rd_n),
    .addr(addr_bus), 
    .data_f2s(data_f2s_bus), 
    .data_s2f_r(data_s2f_r_bus), 
    .ad(ad), 
    .we_n(we_n), 
    .oe_n(oe_n), 
    .dio_a(dio_a), 
    .ce_a_n(ce_a_n),
    .ram_e(ram_e)
    );

ACIA ACIA_one (
    .RESET(resb),      //: in     std_logic;
    .PHI2(phi2),       //: in     std_logic;
    .CS(acia_e),         //: in     std_logic;
    .RWN(rwb),        //: in     std_logic;
    .RS(address[1:0]),         //: in     std_logic_vector(1 downto 0);
    .DATAIN(acia_in),     //: in     std_logic_vector(7 downto 0);
    .DATAOUT(acia_out),    //: out    std_logic_vector(7 downto 0);
    .XTLI(acia_clk),       //: in     std_logic;
    .RTSB(rts),       //: out    std_logic;
    .CTSB(cts),       //: in     std_logic;
    .DTRB(),       //: out    std_logic;
    .RXD(rx),        //: in     std_logic;
    .TXD(tx),        //: buffer std_logic;
    .IRQn(1'b1)       //: buffer std_logic
   );

dist_rom_0 rom_0(
    .a(address[13:0]),      // : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    .spo(spo)               //: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );

endmodule

