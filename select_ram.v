`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/31 13:58:20
// Design Name: 
// Module Name: select_ram
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


module select_ram(
input         rst_n               ,// async reset_all
   input         clk                  ,  // 
   input  [7:0]  start_position       ,
   input  [7:0]  end_position         ,
   input         position_wr_en       ,
   input         rd_en                ,
   input  [7:0]  rd_addr              ,
   output  reg   data_out            ,
   output  reg   data_out_valid      ,
   output         rd_ready
   );
   reg   [255:0] select_reg;
   reg  position_wr_en_r;
   wire [255:0] start_position_decode;      
   wire [255:0] end_position_decode;    
   assign rd_ready=!(position_wr_en_r||position_wr_en);  
   
   always@(posedge clk )
   position_wr_en_r<=position_wr_en;
      integer i;
   always@(posedge clk or negedge rst_n)
      if(!rst_n)
      select_reg <='d0;
      else if(position_wr_en_r&&(start_position==8'd0))
       select_reg <=256'd0^end_position_decode;
      
     else if(position_wr_en_r)
     for(i=0;i<256;i=i+1)
       begin    
          select_reg[i]<=start_position_decode[i]^end_position_decode[i];
        end   
    
        
   always@(posedge clk or negedge rst_n)      
        if(!rst_n)  
        begin
         data_out<='d0;
         data_out_valid<='d0;
         end
        else if(rd_en)
         begin
         data_out<=select_reg['d255-rd_addr];
         data_out_valid<='d1;
         end 
        else 
        begin
         data_out<='d0;
         data_out_valid<='d0;
         end  
       
         
 
   decode_data decode_data_0(
   .clka (    clk                 ), //: IN STD_LOGIC;
   .ena  (  position_wr_en        ), //: IN STD_LOGIC;
   .addra((start_position-1'b1)   ), //: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
   .douta( start_position_decode  )  //: OUT STD_LOGIC_VECTOR(255 DOWNTO 0)
 );      //this rom decodes start_position
 
 
 decode_data decode_data_1(
   .clka (    clk               ), //: IN STD_LOGIC;
   .ena  (  position_wr_en      ), //: IN STD_LOGIC;
   .addra(end_position          ), //: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
   .douta( end_position_decode  )  //: OUT STD_LOGIC_VECTOR(255 DOWNTO 0)
 );      //this rom decodes start_position
 endmodule