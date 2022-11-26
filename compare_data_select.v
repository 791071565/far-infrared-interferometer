`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/31 14:01:30
// Design Name: 
// Module Name: compare_data_select
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


module compare_data_select(
 input         rst_n                       ,// async reset_all
  input         clk                         ,  // 
  
  input  [31:0] floating_IM_square_add_RE_suqare,
  input         floating_IM_square_add_RE_suqare_en, 
  input         floating_IM_square_add_RE_suqare_last,
  
  input      [7:0]  start_cmp_position_r,
  
  output   [31:0]   floating_IM_square_add_RE_suqare_selected,
  output            floating_IM_square_add_RE_suqare_selected_en,  
  output  reg  [7:0]    floating_IM_square_add_RE_suqare_selected_position,
  output reg         floating_IM_square_add_RE_suqare_last_r,
  
  
  output reg [31:0] floating_IM_square_add_RE_suqare_o_r ,
  output reg        floating_IM_square_add_RE_suqare_en_o_r,    
  output  reg [7:0]    floating_IM_square_add_RE_suqare_o_position_r,
  
  output reg [31:0] floating_IM_square_add_RE_suqare_o_rr,
  output reg        floating_IM_square_add_RE_suqare_en_o_rr,
  output  reg [7:0]    floating_IM_square_add_RE_suqare_o_position_rr   
  );
 always@(posedge clk)  
  floating_IM_square_add_RE_suqare_last_r<=floating_IM_square_add_RE_suqare_last;
  
  
     reg [31:0] floating_IM_square_add_RE_suqare_o='d0;
     reg        floating_IM_square_add_RE_suqare_en_o='d0;

//   localparam    filter_points=(fft_points1/2)-1;
   reg [7:0]   data_cnt=0;
   reg         data_sel=0;
   reg         data_sel_r=0;
  always@(posedge clk or negedge rst_n)
     if(!rst_n)
     data_cnt<='d0;
    else if((floating_IM_square_add_RE_suqare_en)&&(&data_cnt[7:0])) 
     data_cnt<='d0;
    else if(floating_IM_square_add_RE_suqare_en)
     data_cnt<=data_cnt+'d1;
  
   always@(posedge clk or negedge rst_n)
     if(!rst_n)
       data_sel<=0;
     else if(data_cnt==start_cmp_position_r-'d1)
       data_sel<=1;
     else if((&data_cnt[6:0])&&(~data_cnt[7]))
       data_sel<=0;
  always@(posedge clk)
 data_sel_r<=data_sel;
  
  always@(posedge clk)
  begin
  floating_IM_square_add_RE_suqare_o<= (data_sel||data_sel_r)?floating_IM_square_add_RE_suqare:floating_IM_square_add_RE_suqare_o;
  floating_IM_square_add_RE_suqare_en_o<=(data_sel||data_sel_r)?floating_IM_square_add_RE_suqare_en:1'b0;
  end
 
  
  always@(posedge clk)
  begin   
  floating_IM_square_add_RE_suqare_o_r    <=floating_IM_square_add_RE_suqare_selected;
  floating_IM_square_add_RE_suqare_en_o_r <=floating_IM_square_add_RE_suqare_selected_en;  
  floating_IM_square_add_RE_suqare_o_rr   <=floating_IM_square_add_RE_suqare_o_r;
  floating_IM_square_add_RE_suqare_en_o_rr<=floating_IM_square_add_RE_suqare_en_o_r;
  end
  
   assign  floating_IM_square_add_RE_suqare_selected_en=floating_IM_square_add_RE_suqare_en_o;
   assign  floating_IM_square_add_RE_suqare_selected=floating_IM_square_add_RE_suqare_o;  
    
   
     always@(posedge clk or negedge rst_n)
       if(!rst_n)
       begin
     floating_IM_square_add_RE_suqare_selected_position<='d0;
  
     floating_IM_square_add_RE_suqare_o_position_r<='d0;
  
     floating_IM_square_add_RE_suqare_o_position_rr<='d0;
    end
    else if(floating_IM_square_add_RE_suqare_last_r)
    begin
        floating_IM_square_add_RE_suqare_selected_position<='d0;
     
        floating_IM_square_add_RE_suqare_o_position_r<='d0;
     
        floating_IM_square_add_RE_suqare_o_position_rr<='d0;
       end  
    else  begin
     floating_IM_square_add_RE_suqare_selected_position<= (data_sel||data_sel_r)?(data_cnt):floating_IM_square_add_RE_suqare_selected_position;
         
            floating_IM_square_add_RE_suqare_o_position_r<=floating_IM_square_add_RE_suqare_selected_position;
         
            floating_IM_square_add_RE_suqare_o_position_rr<=floating_IM_square_add_RE_suqare_o_position_r;
    
    
    end
    
    
    
  endmodule
  