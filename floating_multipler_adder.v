`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/31 13:22:41
// Design Name: 
// Module Name: floating_multipler_adder
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


module floating_multipler_adder(
  input         rst_n                       ,// async reset_all
  input         clk                         ,  // 
 
  input [31:0]  floating_data_RE           ,
  input [31:0]  floating_data_IM           ,
  input         floating_data_en           , 
  input         floating_data_last         ,
  
 (*mark_debug = "true"*) output  [31:0] floating_IM_square_add_RE_suqare,
 (*mark_debug = "true"*) output         floating_IM_square_add_RE_suqare_en,
 (*mark_debug = "true"*) output        floating_IM_square_add_RE_suqare_last  
 

  );

  
  wire  [31:0] floating_RE_square;
  wire         floating_RE_square_en;
  
  floating_point_multiply floating_point_multiply_0(
   .aclk                ( clk                              ),      //: IN STD_LOGIC;
   .s_axis_a_tvalid     (floating_data_en                  ),      //: IN STD_LOGIC;
   .s_axis_a_tdata      (floating_data_RE                  ),      //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
   .s_axis_b_tvalid     (floating_data_en                  ),      //: IN STD_LOGIC;
   .s_axis_b_tdata      (floating_data_RE                  ),      //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
   .m_axis_result_tvalid(floating_RE_square_en             ),      //: OUT STD_LOGIC;
   .m_axis_result_tdata (floating_RE_square                )      //: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
       );
 
  wire  [31:0] floating_IM_square;
  wire         floating_IM_square_en;

   floating_point_multiply floating_point_multiply_1(
   .aclk                ( clk                              ),      //: IN STD_LOGIC;
   .s_axis_a_tvalid     (floating_data_en                 ),      //: IN STD_LOGIC;
   .s_axis_a_tdata      (floating_data_IM                 ),      //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
   .s_axis_b_tvalid     (floating_data_en                 ),      //: IN STD_LOGIC;
   .s_axis_b_tdata      (floating_data_IM                 ),      //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
   .m_axis_result_tvalid(floating_IM_square_en            ),      //: OUT STD_LOGIC;
   .m_axis_result_tdata (floating_IM_square               )      //: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
      );
      
    
      
    floating_point_adder floating_point_adder_0(
   .aclk                 (    clk                    ),           //: IN STD_LOGIC;
   .s_axis_a_tvalid      (floating_RE_square_en    ),           //: IN STD_LOGIC;
   .s_axis_a_tdata       (floating_RE_square          ),           //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
   .s_axis_b_tvalid      (floating_IM_square_en             ),           //: IN STD_LOGIC;
   .s_axis_b_tdata       (floating_IM_square                ),           //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
   .m_axis_result_tvalid ( floating_IM_square_add_RE_suqare_en ),           //: OUT STD_LOGIC;
   .m_axis_result_tdata  ( floating_IM_square_add_RE_suqare )           //: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
      );   
reg [2:0] delay_cnt='d0;
reg      cnt_add_en=0;
always@(posedge clk or negedge rst_n)
if(!rst_n)
   delay_cnt<=0;
   else if((&delay_cnt)&&cnt_add_en)
   delay_cnt<=0; 
   else if(cnt_add_en)
   delay_cnt<=delay_cnt+'d1;


always@(posedge clk or negedge rst_n)
if(!rst_n)
   cnt_add_en<=0;
   else if((&delay_cnt)&&cnt_add_en)
   cnt_add_en<=0; 
   else if(floating_data_last)
    cnt_add_en<='d1; 
    assign    floating_IM_square_add_RE_suqare_last=&delay_cnt;
endmodule