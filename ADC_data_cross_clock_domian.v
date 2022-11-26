`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/31 13:05:22
// Design Name: 
// Module Name: ADC_data_cross_clock_domian
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


module ADC_data_cross_clock_domian(
  input         adc_clk,
   input  [15:0] ADC_data_in_A_channel,
   input         ADC_data_in_A_channel_en,
   input  [15:0] ADC_data_in_B_channel,
   input         ADC_data_in_B_channel_en,
   
   input          alg_clk,
   input          alg_rst_n,
   output  [15:0] data_in_A_channel,
   output   reg   data_in_A_channel_en,
   output  [15:0] data_in_B_channel,
   output   reg   data_in_B_channel_en);
   
   reg rd_en_CHA=0;
   reg rd_en_CHB=0; 
   
   reg  fifo_rst=0;
   wire empty_fifo_A;
   wire empty_fifo_B;     
   
   wire empty_fifo_A_negedge;
   wire empty_fifo_B_negedge; 
  
   always @ (posedge alg_clk or negedge alg_rst_n)
       if(!alg_rst_n)          
        rd_en_CHA<=0;
      else if((rd_en_CHA==1'b1)&&(!empty_fifo_A))  
        rd_en_CHA<=0; 
     else if(empty_fifo_A_negedge||(!empty_fifo_A))
        rd_en_CHA<=1;
     else    
        rd_en_CHA<=0;
   
   
    always @ (posedge alg_clk or negedge alg_rst_n)
       if(!alg_rst_n)          
        rd_en_CHB<=0;
      else if((rd_en_CHB==1'b1)&&(!empty_fifo_B))  
               rd_en_CHB<=0;  
     else if(empty_fifo_B_negedge||(!empty_fifo_B))
        rd_en_CHB<=1;
     else    
        rd_en_CHB<=0;
   
   always @ (posedge alg_clk)
     data_in_A_channel_en<=rd_en_CHA;
     
   
   always @ (posedge alg_clk)
     data_in_B_channel_en<=rd_en_CHB; 
  
  wire  full_A;
  wire  full_B;
   
   ADC_cross_clk_domian_fifo_0 ADC_cross_clk_domian_fifo_0_0
   (
     .rst         (fifo_rst               ),   //: IN STD_LOGIC;
     .wr_clk      ( adc_clk             ),   //: IN STD_LOGIC;
     .rd_clk      ( alg_clk             ),   //: IN STD_LOGIC;
     .din         (ADC_data_in_A_channel),                       //: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
     .wr_en       (ADC_data_in_A_channel_en),                       //: IN STD_LOGIC;
     .rd_en       (rd_en_CHA),                       //: IN STD_LOGIC;
     .dout        (data_in_A_channel ),                       //: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
     .full        (full_A),             //: OUT STD_LOGIC;
     .empty       (empty_fifo_A          )             //: OUT STD_LOGIC;

   );    
   
   
   ADC_cross_clk_domian_fifo_0 ADC_cross_clk_domian_fifo_0_1
   (
     .rst         ( fifo_rst                 ),   //: IN STD_LOGIC;
     .wr_clk      ( adc_clk            ),   //: IN STD_LOGIC;
     .rd_clk      ( alg_clk            ),   //: IN STD_LOGIC;
     .din         (ADC_data_in_B_channel),                       //: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
     .wr_en       (ADC_data_in_B_channel_en),                       //: IN STD_LOGIC;
     .rd_en       (rd_en_CHB           ),                       //: IN STD_LOGIC;
     .dout        (data_in_B_channel   ),                       //: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
     .full        ( full_B            ),             //: OUT STD_LOGIC;
     .empty       (empty_fifo_B        )             //: OUT STD_LOGIC;

   );    
   
   low_frequency_edge_detect low_frequency_edge_detect_0(
        .clk           (  alg_clk                 ),
        .signal_in     (  empty_fifo_A            ),
        .signal_posedge(                          ),
        .signal_negedge( empty_fifo_A_negedge     )
        );
   
    low_frequency_edge_detect low_frequency_edge_detect_1(
        .clk           (  alg_clk                 ),
        .signal_in     (  empty_fifo_B            ),
        .signal_posedge(                          ),
        .signal_negedge( empty_fifo_B_negedge     )
        );
   
  endmodule 