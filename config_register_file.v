`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/31 14:01:46
// Design Name: 
// Module Name: config_register_file
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


module config_register_file(
  input         rst_n                       ,// async reset_all
  input  PCIE_dma_engine_clk                ,
  input  [7:0]  narrow_band_width           ,
  input         narrow_band_width_en        ,                                      
  input  [1:0]  filter_mode                 ,
  input         filter_mode_en              ,
  input  [7:0]  start_cmp_position           ,
  input         start_cmp_position_en        ,
  output   reg   [7:0]  narrow_band_width_r='d25 ,
  output   reg   [1:0]  filter_mode_r='b00        ,//'b00 single frequency 
                                //'b01 three frequency   
  output   reg   [7:0]  start_cmp_position_r='d0
);
always@(posedge PCIE_dma_engine_clk or negedge rst_n)
   if(!rst_n)
    narrow_band_width_r<='d25;
 else if(narrow_band_width_en)
    narrow_band_width_r<=narrow_band_width;
    
 always@(posedge PCIE_dma_engine_clk or negedge rst_n)
   if(!rst_n)
    start_cmp_position_r<='d0;
 else if(start_cmp_position_en)
    start_cmp_position_r<=start_cmp_position;

 always@(posedge PCIE_dma_engine_clk or negedge rst_n)
    if(!rst_n)
     filter_mode_r<='b00;
//    else if(filter_mode_en)
    else
     filter_mode_r<=filter_mode;


    endmodule
