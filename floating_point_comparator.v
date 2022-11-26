`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/31 13:47:58
// Design Name: 
// Module Name: floating_point_comparator
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


module floating_point_comparator(
input         clk,
 input         rst_n,
 input [31:0]  floating_point_1,//1 bit sign  8bit  exp      23 bit float
 input         floating_point_1_en,
 input [7:0]   floating_point_1_position,
 input [31:0]  floating_point_2,
 input         floating_point_2_en,
 input  [7:0]  floating_point_2_position,
 output            equal,
 output            larger_en,
 output            smaller_en,
 output            comparator_out,
 output [31:0]    comparator_result_larger_data,
 output [7:0]     comparator_result_larger_position,
 output [31:0]    comparator_result_smaller_data,
 output [7:0]     comparator_result_smaller_position
 
 );
reg [31:0] floating_point_1_r         =0;
reg [7:0]  floating_point_1_position_r=0;
reg [31:0] floating_point_2_r         ='d0;  
reg [7:0]  floating_point_2_position_r=0;

assign comparator_result_larger_data=(larger_en)?floating_point_1_r:floating_point_2_r;

assign comparator_result_larger_position=(larger_en)?floating_point_1_position_r:floating_point_2_position_r;

assign comparator_result_smaller_data=(smaller_en)?floating_point_1_r:floating_point_2_r;

assign comparator_result_smaller_position=(smaller_en)?floating_point_1_position_r:floating_point_2_position_r;

always@(posedge clk)
begin
floating_point_1_r         <=floating_point_1;  
floating_point_1_position_r<=floating_point_1_position;  
floating_point_2_r         <=floating_point_2; 
floating_point_2_position_r<=floating_point_2_position;   
 end
 
 
wire  [9:0] exp_subtracted;//1bit sign 9bit data
   reg     larger=0;
   reg     smaller=0;
reg floating_point_1_en_r=0;
reg floating_point_2_en_r=0;

 assign   larger_en=floating_point_1_en_r&&larger;
 assign   smaller_en=smaller&&floating_point_1_en_r;
assign  equal=(!larger)&&(!smaller)&&floating_point_1_en_r;

always@(posedge clk)
begin
 floating_point_1_en_r<=floating_point_1_en ;
 floating_point_2_en_r<=floating_point_2_en ;
end

assign exp_subtracted=$signed({1'b0,floating_point_1[30:23]})-$signed({1'b0,floating_point_2[30:23]});
wire [24:0] floating_subtracted;
assign  floating_subtracted=$signed({1'b0,floating_point_1[22:0]})-$signed({1'b0,floating_point_2[22:0]});

 wire    exp_larger; 
 assign  exp_larger=(~exp_subtracted[9])&&(|exp_subtracted[8:0]); // >0?(~exp_subtracted[9]) sign 0 (|exp_subtracted[8:0]) data >0
 wire    exp_smaller;
 assign  exp_smaller=exp_subtracted[9]; //<0
// wire   exp_equal;
// assign  exp_equal=(!exp_larger)&&(!exp_smaller);
 
 wire    sign_larger;
 assign  sign_larger=(!floating_point_1[31])&&(floating_point_2[31]);
 wire    sign_smaller;
 assign  sign_smaller=(floating_point_1[31])&&(!floating_point_2[31]);
 //wire   sign_equal;
 //assign  sign_equal=~(floating_point_1[31]^floating_point_2[31]);
 wire    floating_larger;
 assign  floating_larger=(~floating_subtracted[24])&&(|floating_subtracted[23:0]); //>0
 wire    floating_smaller;
 assign  floating_smaller=floating_subtracted[24]; //<0
 //wire    floating_equal;
 //assign   floating_equal=(!floating_larger)&&(!floating_smaller);
 
 

 always@(posedge clk or negedge rst_n)
  if(!rst_n)
  begin
  larger<=0;
  smaller<=0;
  end
  else if(sign_larger)
  begin
   larger<=1;
   smaller<=0;  
   end
  else if(sign_smaller)
   begin
    larger<=0;
    smaller<=1;  
   end
   else if(exp_larger)
 begin
     larger<= ~floating_point_1[31];
     smaller<=floating_point_1[31];  
     end
    else if(exp_smaller)
     begin
         larger<= floating_point_1[31];
         smaller<=~floating_point_1[31];  
         end  
     
     
  else if(floating_larger)
  begin
       larger<= ~floating_point_1[31];
       smaller<=floating_point_1[31];   
       end
  else if(floating_smaller)
   begin
        larger <=floating_point_1[31]; 
        smaller<=~floating_point_1[31]; 
        end
  
   else  
   begin
     larger<=0;
     smaller<=0;
     end
  
  assign comparator_out=floating_point_1_en_r;
  endmodule