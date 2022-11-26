`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/19 17:54:38
// Design Name: 
// Module Name: dac_top
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


module dac_top(
rst,
clk,




DAC1_DA,
DAC1_DB,
DAC2_DA,

DAC1_PD,
DAC1_XOR,

DAC2_PD,
DAC2_XOR,

 feedback_data 
);

input rst;
input clk;
 
input  [15:0]   feedback_data;
output reg [15:0] DAC1_DA;
output reg [15:0] DAC1_DB;
output reg [15:0] DAC2_DA;

output     DAC1_PD;
output     DAC1_XOR;
output     DAC2_PD;
output     DAC2_XOR;

assign     DAC1_PD    = 1'b0;
assign     DAC1_XOR   = 1'b0;
assign     DAC2_PD    = 1'b0;
assign     DAC2_XOR   = 1'b0;

//reg [31:0] dac_cnt;

//always @(posedge clk or posedge rst)
//  if(rst)
//dac_cnt<=32'd0;
//else if(dac_cnt==32'd10000-1'b1)
//dac_cnt<=32'd0;

//else  
//dac_cnt<=dac_cnt+1'b1;

always @(posedge clk or posedge rst)
if(rst)
begin

   DAC1_DA  <=  16'h0000;
   DAC1_DB  <=  16'h0000;
  // DAC2_DA  <=  16'hffff;
   
end
 

else  
begin

   DAC1_DA  <= feedback_data;
   DAC1_DB  <= feedback_data;
   
end





endmodule
