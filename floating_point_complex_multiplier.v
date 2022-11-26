`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/31 14:03:32
// Design Name: 
// Module Name: floating_point_complex_multiplier
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


module floating_point_complex_multiplier(
input          rst_n  ,
input          clk    ,
input   [31:0]  A_re,
input           A_re_en,
input   [31:0]  B_im,
input           B_im_en,
input   [31:0]  C_re,
input           C_re_en,
input   [31:0]  D_im,
input           D_im_en,

output [31:0]   A_C_B_D_re,
output          A_C_B_D_re_en,

output [31:0]   A_D_B_C_im,
output          A_D_B_C_im_en

);

 wire [31:0] A_multiply_C;
 wire A_multiply_C_en;

floating_point_multiply floating_point_multiply_0(
  .  aclk                 (   clk                                  ),//: IN STD_LOGIC;
  .  s_axis_a_tvalid      (  A_re_en                               ),//: IN STD_LOGIC;
  .  s_axis_a_tdata       (  A_re                                  ),//: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  .  s_axis_b_tvalid      (  C_re_en                               ),//: IN STD_LOGIC;
  .  s_axis_b_tdata       (  C_re                                  ),//:  IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  .  m_axis_result_tvalid (  A_multiply_C_en                       ),//: OUT STD_LOGIC;
  .  m_axis_result_tdata  (  A_multiply_C                          )//: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
  
 wire [31:0] A_multiply_D;
 wire A_multiply_D_en;
  
floating_point_multiply floating_point_multiply_1(
  .  aclk                 (   clk                                  ),//: IN STD_LOGIC;
  .  s_axis_a_tvalid      (  A_re_en                               ),//: IN STD_LOGIC;
  .  s_axis_a_tdata       (  A_re                                  ),//: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  .  s_axis_b_tvalid      (  D_im_en                               ),//: IN STD_LOGIC;
  .  s_axis_b_tdata       (  D_im                                  ),//:  IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  .  m_axis_result_tvalid (  A_multiply_D_en                       ),//: OUT STD_LOGIC;
  .  m_axis_result_tdata  (  A_multiply_D                          )//: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );

 wire [31:0] B_multiply_C;
 wire B_multiply_C_en;
  
floating_point_multiply floating_point_multiply_2(
  .  aclk                 (   clk                                  ),//: IN STD_LOGIC;
  .  s_axis_a_tvalid      (  B_im_en                               ),//: IN STD_LOGIC;
  .  s_axis_a_tdata       (  B_im                                  ),//: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  .  s_axis_b_tvalid      (  C_re_en                               ),//: IN STD_LOGIC;
  .  s_axis_b_tdata       (  C_re                                  ),//:  IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  .  m_axis_result_tvalid (  B_multiply_C_en                       ),//: OUT STD_LOGIC;
  .  m_axis_result_tdata  (  B_multiply_C                          )//: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );

  
 wire [31:0] B_multiply_D;
 wire B_multiply_D_en;
  
floating_point_multiply floating_point_multiply_3(
  .  aclk                 (   clk                                  ),//: IN STD_LOGIC;
  .  s_axis_a_tvalid      (  B_im_en                               ),//: IN STD_LOGIC;
  .  s_axis_a_tdata       (  B_im                                  ),//: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  .  s_axis_b_tvalid      (  D_im_en                               ),//: IN STD_LOGIC;
  .  s_axis_b_tdata       (  D_im                                  ),//:  IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  .  m_axis_result_tvalid (  B_multiply_D_en                       ),//: OUT STD_LOGIC;
  .  m_axis_result_tdata  (  B_multiply_D                          )//: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  ); 
  
   floating_point_adder floating_point_adder_0(
   . aclk                 (    clk                          ),  //       : IN STD_LOGIC;
   . s_axis_a_tvalid      (  A_multiply_C_en                 ),  //       : IN STD_LOGIC;
   . s_axis_a_tdata       (  A_multiply_C                    ),  //       : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
   . s_axis_b_tvalid      (  B_multiply_D_en                 ),  //       : IN STD_LOGIC;
   . s_axis_b_tdata       ({(~B_multiply_D[31]),B_multiply_D[30:0]}),  //       : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
   . m_axis_result_tvalid (  A_C_B_D_re_en                   ),  //       : OUT STD_LOGIC;
   . m_axis_result_tdata  (  A_C_B_D_re                      )  //       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );              //AC-BD                                        
  
   floating_point_adder floating_point_adder_1(
   . aclk                 (    clk                          ),  //       : IN STD_LOGIC;
   . s_axis_a_tvalid      (  A_multiply_D_en                 ),  //       : IN STD_LOGIC;
   . s_axis_a_tdata       (  A_multiply_D                    ),  //       : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
   . s_axis_b_tvalid      (  B_multiply_C_en                 ),  //       : IN STD_LOGIC;
   . s_axis_b_tdata       (  B_multiply_C                    ),  //       : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
   . m_axis_result_tvalid (  A_D_B_C_im_en                   ),  //       : OUT STD_LOGIC;
   . m_axis_result_tdata  (  A_D_B_C_im                      )  //       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  ); 
  
  
  endmodule
