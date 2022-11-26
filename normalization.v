`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/31 21:06:11
// Design Name: 
// Module Name: normalization
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


module normalization(
input        clk,         
  input        rst_n,
  
  
  input [31:0]   A_C_B_D_re,
  input          A_C_B_D_re_en,
  
  input [31:0]   A_D_B_C_im,
  input          A_D_B_C_im_en,
  
  output [31:0]   A_C_B_D_re_normalized   ,//fixed point 31_29
  output          A_C_B_D_re_normalized_en,//fixed point 31_29
  
  output  [31:0]   A_D_B_C_im_normalized   ,//fixed point 31_29
  output           A_D_B_C_im_normalized_en //fixed point 31_29
  );
  reg  [23:0]  A_C_B_D_re_sign_and_Mantissa  =24'd0;
  reg  [23:0]  A_D_B_C_im_sign_and_Mantissa  =24'd0;
  reg  [23:0]  A_C_B_D_re_sign_and_Mantissa_r=24'd0;
  reg  [23:0]  A_D_B_C_im_sign_and_Mantissa_r=24'd0;
always @(posedge clk)
 begin
  A_C_B_D_re_sign_and_Mantissa  <={A_C_B_D_re[31],A_C_B_D_re[22:0]};
  A_D_B_C_im_sign_and_Mantissa  <={A_D_B_C_im[31],A_D_B_C_im[22:0]};
  A_C_B_D_re_sign_and_Mantissa_r<=A_C_B_D_re_sign_and_Mantissa;
  A_D_B_C_im_sign_and_Mantissa_r<=A_D_B_C_im_sign_and_Mantissa;

 end
  
 reg  A_C_B_D_re_en_r =0;
 reg  A_C_B_D_re_en_rr=0;
 always @(posedge clk)
 begin
  A_C_B_D_re_en_r<=A_C_B_D_re_en;
  A_C_B_D_re_en_rr<=A_C_B_D_re_en_r;  
 end
  wire [7:0]  A_C_B_D_re_exponent; 
  wire [7:0]  A_D_B_C_im_exponent; 
  assign  A_C_B_D_re_exponent =A_C_B_D_re[30:23];
  assign  A_D_B_C_im_exponent =A_D_B_C_im[30:23];
  
  reg  larger =1'b0;
  reg  smaller=1'b0;
  reg  equal  =1'b0;
  reg [7:0] abs_exponent_difference=8'd0;
  always @(posedge clk or negedge rst_n)
      if(!rst_n )
      begin
      larger <=1'b0;
      smaller<=1'b0;
      equal  <=1'b0;
      abs_exponent_difference<=8'd0;
      end
     else if(A_C_B_D_re_en)
   if(A_C_B_D_re_exponent>A_D_B_C_im_exponent)
    begin
      larger <=1'd1;
      smaller<=1'd0;
      equal  <=1'd0;
      abs_exponent_difference<=A_C_B_D_re_exponent-A_D_B_C_im_exponent;   
    end
 else  if(A_C_B_D_re_exponent<A_D_B_C_im_exponent)
    begin
     larger <=1'd0;
     smaller<=1'd1;
     equal  <=1'd0;
  abs_exponent_difference<=A_D_B_C_im_exponent-A_C_B_D_re_exponent;  
  end
  
  else  if(A_C_B_D_re_exponent==A_D_B_C_im_exponent)
    begin
     larger <=1'd0;
     smaller<=1'd0;
     equal  <=1'd1;
     abs_exponent_difference<=8'd0;
  end 
   else 
    begin
     larger <=1'd0;
     smaller<=1'd0;
     equal  <=1'd0;  
     abs_exponent_difference<=8'd0;
    end
   else  begin
     larger <=1'd0;
     smaller<=1'd0;
     equal  <=1'd0; 
     abs_exponent_difference<=abs_exponent_difference;
   end
  

  reg [7:0] A_C_B_D_re_exponent_after_normalized=8'd0;
  reg [7:0] A_D_B_C_im_exponent_after_normalized=8'd0;
   always @(posedge clk or negedge rst_n)
      if(!rst_n )
      begin
      A_C_B_D_re_exponent_after_normalized<=8'd0;
      A_D_B_C_im_exponent_after_normalized<=8'd0;
      end
     else if(larger&&A_C_B_D_re_en_r)
     begin
      A_C_B_D_re_exponent_after_normalized<=8'd126;
      A_D_B_C_im_exponent_after_normalized<=(8'd126>abs_exponent_difference)?(8'd126-abs_exponent_difference):'d0;
      end
     else if(smaller&&A_C_B_D_re_en_r)
     begin
      A_C_B_D_re_exponent_after_normalized<=(8'd126>abs_exponent_difference)?(8'd126-abs_exponent_difference):'d0;
      A_D_B_C_im_exponent_after_normalized<=8'd126;
      end
    else  if(equal&&A_C_B_D_re_en_r)
    begin
      A_C_B_D_re_exponent_after_normalized<=8'd126;
      A_D_B_C_im_exponent_after_normalized<=8'd126;
      end
    else  
    begin
      A_C_B_D_re_exponent_after_normalized<=8'd0;
      A_D_B_C_im_exponent_after_normalized<=8'd0;
      end
  wire [31:0] after_normalized_floating_point_A;
  wire [31:0] after_normalized_floating_point_B;
  assign after_normalized_floating_point_A={ A_C_B_D_re_sign_and_Mantissa_r[23],A_C_B_D_re_exponent_after_normalized,A_C_B_D_re_sign_and_Mantissa_r[22:0]}                       ;  
  assign after_normalized_floating_point_B={A_D_B_C_im_sign_and_Mantissa_r[23],A_D_B_C_im_exponent_after_normalized,A_D_B_C_im_sign_and_Mantissa_r[22:0]}                        ;  
  
  floating_point_to_fixed_31_29 floating_point_to_fixed_31_29_0(
   .aclk                (      clk                    ),//  : IN STD_LOGIC;
   .s_axis_a_tvalid     (  A_C_B_D_re_en_rr           ),//  : IN STD_LOGIC;
   .s_axis_a_tdata      ( {A_C_B_D_re_sign_and_Mantissa_r[23],A_C_B_D_re_exponent_after_normalized,A_C_B_D_re_sign_and_Mantissa_r[22:0]}  ),//  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
   .m_axis_result_tvalid(  A_C_B_D_re_normalized_en   ),//  : OUT STD_LOGIC;
   .m_axis_result_tdata (  A_C_B_D_re_normalized      )//  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
 );
  floating_point_to_fixed_31_29 floating_point_to_fixed_31_29_1(
   .aclk                 (    clk                      ), //: IN STD_LOGIC;
   .s_axis_a_tvalid      ( A_C_B_D_re_en_rr            ), //: IN STD_LOGIC;
   .s_axis_a_tdata       ({A_D_B_C_im_sign_and_Mantissa_r[23],A_D_B_C_im_exponent_after_normalized,A_D_B_C_im_sign_and_Mantissa_r[22:0]}  ), //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
   .m_axis_result_tvalid (   A_D_B_C_im_normalized_en  ), //: OUT STD_LOGIC;
   .m_axis_result_tdata  (   A_D_B_C_im_normalized     )  //: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
 );
  
  
  endmodule
