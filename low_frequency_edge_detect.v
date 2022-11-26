`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/31 13:06:12
// Design Name: 
// Module Name: low_frequency_edge_detect
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


module low_frequency_edge_detect(
 input  clk,
input  signal_in,
output signal_posedge,
output signal_negedge
);
reg  signal_in_r;
always@(posedge clk) 

signal_in_r<=signal_in;
assign  signal_posedge= (signal_in)&&(!signal_in_r);
assign  signal_negedge= (!signal_in)&&(signal_in_r); 
endmodule

