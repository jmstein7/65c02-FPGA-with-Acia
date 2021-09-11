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

    wire we, re, ram_e, rom_e, acia_e;
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
    
    assign s2f = data_s2f_r_bus;
    assign resb = ~reset; 
    assign addr_bus = address;
    assign ram_e = ((address[15] == 0) || (address >= 16'h9000 && address < 16'hC000)) ? 1'b0 : 1'b1; //RAM Enable_n
    assign data_f2s_bus = (~rwb && ram_e == 0) ? dout : 'bZ;
    
    //master signals and mux
    assign ab = address; 
    
    assign phi2 = clk; 
    assign rom_e = (address >= 16'hC000) ? 1'b0 : 1'b1; 
    assign acia_e = (address >= 16'h8000 && address <= 16'h800F) ? 1'b0 : 1'b1;
    assign acia_in = (~rwb && acia_e == 0) ? dout : 'bZ;
    
    //tristate
    assign d = (rwb) ? di : 'bZ; 
    assign db = (rwb) ? d : 'bZ;
    assign dout = (~rwb) ? db : 'bZ; 
    
    assign di = (rwb) ? ((rom_e == 0) ? spo : ((ram_e == 0) ? s2f : ((acia_e == 0) ? acia_out : 8'hea))) : 'bZ;
      
    assign LED = (resb) ? 1'b0 : 1'b1;
    assign LED_B = (resb) ? 1'b1 : 1'b0; 
    
/*
r65c02_tc r65c02_tc_alpha(
      .clk_clk_i(clk),   //: in     std_logic;
      .d_i(di),         //: in     std_logic_vector (7 downto 0);
      .irq_n_i(1'b1),     //: in     std_logic;
      .nmi_n_i(1'b1),     //: in     std_logic;
      .rdy_i(1'b1),       //: in     std_logic;
      .rst_rst_n_i(resb), //: in     std_logic;
      .so_n_i(),     // : in     std_logic;
      .a_o(address),         //: out    std_logic_vector (15 downto 0);
      .d_o(dout),        //: out    std_logic_vector (7 downto 0);
      .rd_o(),        //: out    std_logic;
      .sync_o(sync),      //: out    std_logic;
      .wr_n_o(re),      //: out    std_logic;
      .wr_o(we)        //: out    std_logic
        );   
*/

sram_ctrl2 sram_one (
    .clk(clk), 
    .reset(reset), 
    .rw(rwb), 
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

