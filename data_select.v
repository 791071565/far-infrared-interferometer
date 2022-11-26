`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/02 10:05:08
// Design Name: 
// Module Name: data_select
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


module data_select#(
 parameter   select_cnt=26,
 parameter   frame_width =256, 
 parameter   data_width=32
)
(
  input                     clk,
  input                     rst_n,
  input  [data_width-1:0]   data_in,
  input                     data_in_valid, 
  output [data_width-1:0]   data_out, 
  output                    data_out_valid  
);
  reg  [7:0]                frame_cnt=8'd0,frame_cnt_next;
  reg                       first_frame_sig=1'b0,first_frame_sig_next;
  reg  [data_width-1:0]     r_data_out={data_width{1'b0}};
  reg                       r_data_out_valid=1'b0,r_data_out_valid_next;
  
  assign  data_out=r_data_out;
  assign  data_out_valid=r_data_out_valid;
  
  always@*
  begin
   frame_cnt_next=frame_cnt;
    if(data_in_valid&&(frame_cnt==(frame_width-1'b1)))
   frame_cnt_next=8'd0;
   else if(data_in_valid)
    frame_cnt_next=frame_cnt+1'b1;
  end
  
  always@*
  begin
   first_frame_sig_next=first_frame_sig;
    if(data_in_valid&&(frame_cnt==(frame_width-1'b1)))
   first_frame_sig_next=1'd1;
   
  end
  
   always@*
  begin
   r_data_out_valid_next=r_data_out_valid;
   if(data_in_valid&&(!first_frame_sig)&&(frame_cnt==8'd0))
   r_data_out_valid_next=1'b1;
   else if(data_in_valid&&first_frame_sig&&(frame_cnt==(select_cnt)))
   r_data_out_valid_next=1'b1;
   
//  else if((!first_frame_sig)&&data_in_valid&&(frame_cnt==(frame_width-1'b1))) 
   
//   r_data_out_valid_next=1'b0;
  else  if(data_in_valid&&(frame_cnt==(frame_width-select_cnt)))
   r_data_out_valid_next=1'b0;
  
  end
  
  always@(posedge  clk)
   begin
    frame_cnt<=(!rst_n)?8'd0:frame_cnt_next;
    first_frame_sig<=(!rst_n)?1'b0:first_frame_sig_next;
	r_data_out<=(!rst_n)?{data_width{1'b0}}:data_in;
    r_data_out_valid<=(!rst_n)?1'b0:r_data_out_valid_next;
   end
  
  endmodule
