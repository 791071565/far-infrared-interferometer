`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/01 10:47:58
// Design Name: 
// Module Name: shift_reg
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


module shift_reg#(
  parameter    shift_ele_width=32,
  parameter    shift_stage=4

)
(
  input                                        clk,
  input                                        rst_n,
  input  [shift_ele_width-1:0]                 data_in,
  input                                        data_in_vld,
  output     [shift_ele_width*shift_stage-1:0] data_out, 
  output                                       data_out_vld  
);
   reg [shift_stage-1:0] shift_sig={{(shift_stage-1){1'b0}},1'b1},shift_sig_next;
   reg [shift_ele_width*shift_stage-1:0]  shift_data={(shift_ele_width*shift_stage){1'b0}},shift_data_next;
   reg [shift_ele_width*shift_stage-1:0]  shift_data_r={(shift_ele_width*shift_stage){1'b0}};
   reg                                    shift_data_vld=1'b0,shift_data_vld_next;
   reg                   shift_sig_r=1'b0;
   assign        data_out=shift_data;
   assign        data_out_vld=shift_data_vld;
   
   always@*
   begin
   shift_data_vld_next=1'b0;
    if( shift_sig[shift_stage-1]&&data_in_vld)
   shift_data_vld_next=1'b1;
   
   end
   
   always@*
   begin
   shift_sig_next=shift_sig;
    if(data_in_vld)
   shift_sig_next= (shift_sig<<1)| shift_sig[shift_stage-1] ;
   
   end
   
    always@*
   begin
   shift_data_next=shift_data;
    if(data_in_vld)
   shift_data_next= (shift_data<<shift_ele_width)| data_in ;
   
   end
   
   always@(posedge clk)
   begin
   shift_sig<=(!rst_n)?{{(shift_stage-1){1'b0}},1'b1}:shift_sig_next;
   shift_data<=(!rst_n)?{(shift_ele_width*shift_stage){1'b0}}:shift_data_next;
   shift_data_vld<=(!rst_n)?1'b0:shift_data_vld_next;
   shift_sig_r<=(!rst_n)?1'b0:shift_sig[shift_stage-1];
   shift_data_r<=(!rst_n)?{(shift_ele_width*shift_stage){1'b0}}:shift_data;
   end
   
   
   endmodule
