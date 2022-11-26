`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/31 13:45:43
// Design Name: 
// Module Name: selectram_group
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


module selectram_group(
 input               rst_n                       ,
 input               clk                         ,
 input   [7:0]       start_position_1            ,
 input   [7:0]       end_position_1              ,
 input   [7:0]       start_position_2            ,
 input   [7:0]       end_position_2              ,
 input   [7:0]       start_position_3            ,
 input   [7:0]       end_position_3              ,     
 input               position_3_error_sig        ,
 input               position_gen_en             ,
 
 output     wire       select_ram_out_1   ,        
 output     wire       select_ram_out_1_en,
 output     wire       select_ram_out_2   ,
 output     wire       select_ram_out_2_en,
 output     wire       select_ram_out_3   ,
 output     wire       select_ram_out_3_en,
 output     reg        rd_en='d0 ,
 output     reg  [7:0] rd_addr ='d0
 );
 
 
 wire       rd_ready_posedge;

 

 always@(posedge clk or negedge rst_n)
    if(!rst_n)
       rd_en<='d0;
  else if((rd_addr=='d255)&&rd_en)     
       rd_en<='d0;          
  else if(rd_ready_posedge)
       rd_en<='d1;

always@(posedge clk or negedge rst_n)
  if(!rst_n)
       rd_addr<='d0;
  else if((rd_addr=='d255)&&rd_en)     
       rd_addr<='d0;          
  else if(rd_en)
       rd_addr<=rd_addr+'d1;



 

 wire       rd_ready;
select_ram select_ram_0(
  .rst_n          (   rst_n                     ) ,    //input         rst_n                ,// async reset_all
  .clk            (   clk                       ) ,    //input         clk                  ,  // 
  .start_position (  start_position_1                ) ,    //input  [7:0]  start_position       ,
  .end_position   (  end_position_1                  ) ,    //input  [7:0]  end_position         ,
  .position_wr_en (  position_gen_en                ) ,    //input         position_wr_en       ,
  .rd_en          (  rd_en                        ) ,    //input         rd_en                ,
  .rd_addr        (  rd_addr                      ) ,    //input  [7:0]  rd_addr              ,
  .data_out       ( select_ram_out_1                 ) ,    //output  reg   data_out             ,
  .data_out_valid ( select_ram_out_1_en              ) ,    //output  reg   data_out_valid       ,
  .rd_ready       ( rd_ready             )      //output        rd_ready
 );

 
 select_ram select_ram_1(
  .rst_n          (   rst_n                     ) ,    //input         rst_n                ,// async reset_all
  .clk            (   clk                       ) ,    //input         clk                  ,  // 
  .start_position (  start_position_2                ) ,    //input  [7:0]  start_position       ,
  .end_position   (  end_position_2                  ) ,    //input  [7:0]  end_position         ,
  .position_wr_en (  position_gen_en                ) ,    //input         position_wr_en       ,
  .rd_en          ( rd_en                           ) ,    //input         rd_en                ,
  .rd_addr        ( rd_addr                         ) ,    //input  [7:0]  rd_addr              ,
  .data_out       ( select_ram_out_2                  ) ,    //output  reg   data_out             ,
  .data_out_valid ( select_ram_out_2_en               ) ,    //output  reg   data_out_valid       ,
  .rd_ready       (                                 )      //output        rd_ready
 );
 
 
 select_ram select_ram_2(
  .rst_n          (   rst_n                     ) ,    //input         rst_n                ,// async reset_all
  .clk            (   clk                       ) ,    //input         clk                  ,  // 
  .start_position (  start_position_3                ) ,    //input  [7:0]  start_position       ,
  .end_position   (  end_position_3                  ) ,    //input  [7:0]  end_position         ,
  .position_wr_en (  position_gen_en                ) ,    //input         position_wr_en       ,
  .rd_en          (  rd_en                          ) ,    //input         rd_en                ,
  .rd_addr        (  rd_addr                        ) ,    //input  [7:0]  rd_addr              ,
  .data_out       ( select_ram_out_3                  ) ,    //output  reg   data_out             ,
  .data_out_valid ( select_ram_out_3_en               ) ,    //output  reg   data_out_valid       ,
  .rd_ready       (                                 )      //output        rd_ready
 );
 
  low_frequency_edge_detect low_frequency_edge_detect_0(
        .clk           (  clk                 ),
        .signal_in     (  rd_ready            ),
        .signal_posedge(     rd_ready_posedge ),
        .signal_negedge(                      )
        );
 
 
 endmodule