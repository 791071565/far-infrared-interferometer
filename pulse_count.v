`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/01 12:39:49
// Design Name: 
// Module Name: pulse_count
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


module pulse_count#(
  parameter   COUNT_WIDTH=8,
  parameter   count_data=256
)
(
  input                                        clk,
  input                                        rst_n,
  input                                        pulse,

  output                                       count_equal

);

 reg   [COUNT_WIDTH-1:0] count=0,count_next;
  assign  count_equal=(count==(count_data-2'd2));
 always@*
 begin
   count_next=count;
    if(count_equal)
   count_next={COUNT_WIDTH{1'b0}};
   else if( pulse )
   count_next=count_next+1'b1; 
   end
 always@(posedge clk)
 begin
   count<=(!rst_n)?{COUNT_WIDTH{1'b0}}:count_next;
 end
 
 
 endmodule
