`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/12 13:08:23
// Design Name: 
// Module Name: cross_clock_domain
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


module cross_clock_domain#(
     parameter data_width=5'd1
)
(
   input  clk1,
   input  clk2,
   input  rst_n,
   input [data_width-1'b1:0] data_in,    //clk1
   input  data_in_en, //clk1
   output reg data_in_ready=1,//clk1
   output reg [data_width-1'b1:0] data_out=0,
   output reg   data_out_en =0
   );
  
      reg   data_in_en_r=0;
      reg   data_valid_r=0;
      reg   data_valid_rr=0; 
      reg   data_in_en_rr=0;
      reg   data_in_en_rrr=0;
  
  reg [data_width-1'b1:0] data_in_r=0;
   always@(posedge clk1 or negedge rst_n)
       if(rst_n == 1'b0)  
       data_in_r<='d0;
       else if(data_in_en)  
       data_in_r<=data_in;
       
  always@(posedge clk1 or negedge rst_n)
      if(rst_n == 1'b0)
      data_in_ready<=1;
	 else if((!data_valid_r)&&data_valid_rr)

	  data_in_ready<=1;
     else if(data_in_en)
      data_in_ready<=0;
  
  
	always@(posedge clk1 or negedge rst_n)
	   if(rst_n == 1'b0)
	   data_in_en_r<=1'b0;
	 else if(data_valid_rr)	   
	  
	   data_in_en_r<=1'b0;	   
	   else if(data_in_en)
	   data_in_en_r<=1'b1;
	  //else  
	  // data_in_en_r<=1'b0;	
	 always@(posedge clk2 or negedge rst_n)
	  if(!rst_n)
	  begin
	  data_in_en_rr <=1'b0;  
	  data_in_en_rrr<=1'b0;
	  end
	//  else if(  data_out_en  )
	//   begin
    //       data_in_en_rr <=1'b0;  
    //       data_in_en_rrr<=1'b0;
    //       end
           else
	  
	 begin
	 data_in_en_rr<=data_in_en_r;
	 data_in_en_rrr<=data_in_en_rr;	 
     end	 
     reg  data_out_en_r;
	 always@(posedge clk1 )
	    
		data_valid_r<=data_out_en_r;
	   
	 always@(posedge clk1)
	 data_valid_rr<=data_valid_r;
	 
	 always@(posedge clk2 or negedge rst_n)
	  if(rst_n == 1'b0)
	 data_out<=0;
	  else if((!data_in_en_rrr)&&data_in_en_rr)
	 data_out<=data_in_r;



 always@(posedge clk2  or negedge rst_n)
	 if(rst_n == 1'b0)
	data_out_en_r<=1'b0;
	else if(data_out_en)
	data_out_en_r<=1'b1;
	else if( (data_in_en_rrr)&&!data_in_en_rr)
	data_out_en_r<=1'b0;
	  always@(posedge clk2 or negedge rst_n)
	  if(rst_n == 1'b0)
	 data_out_en<=0;
	  else if((!data_in_en_rrr)&&data_in_en_rr)
	 data_out_en<=1;
	 else  data_out_en<=0;
	 endmodule