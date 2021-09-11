# 65c02-FPGA-with-Acia
This repository contains HDL for a Xilinx Cmod A7 32T FPGA, which has onboard SRAM. The FPGA is connected to a WDC65c02 (see the XDC file). The ROM (rom_mon.coe) has a simple monitor. There is a 65c51 ACIA emulated. However, I cannot get the RX to work.

The ACIA Clock input is an external oscillator that runs at 1.8432
The Clock input is an external oscillator that runs up to 6mhz.
