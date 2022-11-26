`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/30 14:33:25
// Design Name: 
// Module Name: data_pack
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


module data_pack(
 input              clk  ,
  input              rst_n,
  input  [31:0]      select_dat_update,
  input              frequency_mode,
  
  
   input  [15:0]      denisty_phase ,
   input              denisty_phase_valid,
   input  [15:0]      fradi_phase ,
   input              fradi_phase_valid,
  
  
  input  [15:0]      phase_f1,
  input              phase_f1_valid,
  input  [15:0]      phase_f2,
  input              phase_f2_valid,
  input  [15:0]      phase_f3,
  input              phase_f3_valid,  
  output   [127:0]   packed_data,
  output             packed_data_valid 
  );
   reg [31:0]   phase_in_count;
   reg  [15:0]  phase_f1_r;
   reg          phase_f1_valid_r;
   reg  [15:0]  phase_f2_r;
   reg          phase_f2_valid_r;
   reg  [15:0]  phase_f3_r;
   reg          phase_f3_valid_r; 
   wire [127:0] shift_out_f2;
   wire         shift_out_valid_f2;
   
   wire [127:0] data1;
   wire [127:0] data2;
   wire [127:0] data3;
   wire [127:0] data4;
   wire [127:0] data5;
      
   
   
   reg  [15:0] denisty_phase_r;
   reg    denisty_phase_valid_r;
   reg  [15:0] fradi_phase_r;  
   reg    fradi_phase_valid_r; 
   reg  [127:0] data1_r;
   reg  [127:0] data2_r;
   reg  [127:0] data3_r;
   reg  [127:0] data4_r;
   reg  [127:0] data5_r;
   
//   wire [383:0] packed_all      ;
  wire         packed_all_valid;
   
   reg  [127:0] packed_data_r;
   reg          packed_data_r_valid;
   
   reg         packed_all_valid_r;
   reg  [2:0]  packed_data_count;
   
   assign packed_data      =(!frequency_mode)?shift_out_f2      : packed_data_r      ;
   assign packed_data_valid=(!frequency_mode)?shift_out_valid_f2: packed_data_r_valid;
   
   
   
   always@(posedge clk or negedge  rst_n)
    if(!rst_n)
    phase_in_count<=0;
    else if(phase_f2_valid&&(phase_in_count== select_dat_update-1'b1))       
    phase_in_count<=0;
    else if(phase_f2_valid)
    phase_in_count<=phase_in_count+1'b1;
    
   always@(posedge clk or negedge  rst_n)
    if(!rst_n) 
    begin
     phase_f1_r      <=  0;
     phase_f1_valid_r<=  0;
     phase_f2_r      <=  0;
     phase_f2_valid_r<=  0;
     phase_f3_r      <=  0;
     phase_f3_valid_r<=  0; 
     denisty_phase_r<=0;
     fradi_phase_r<=0;  
     denisty_phase_valid_r<=0;
     fradi_phase_valid_r<=0;
     
     
    end
     else if(phase_f2_valid&&(phase_in_count== select_dat_update-1'b1))
      //else if(phase_f2_valid )
         begin
     phase_f1_r      <=  phase_f1;
     phase_f1_valid_r<=  1;
     phase_f2_r      <=  phase_f2;
     phase_f2_valid_r<=  1;
     phase_f3_r      <=  phase_f3;
     phase_f3_valid_r<=  1; 
     denisty_phase_r<=denisty_phase;
     fradi_phase_r<=fradi_phase;  
     denisty_phase_valid_r<=1;
     fradi_phase_valid_r<=1;
    end
    else
    begin      
     phase_f1_valid_r<=  0;
     phase_f2_valid_r<=  0;    
     phase_f3_valid_r<=  0; 
     denisty_phase_valid_r<=0;
     fradi_phase_valid_r<=0;
     
    end
  always@(posedge clk or negedge  rst_n)
    if(!rst_n)     
   
   packed_data_count<=0;
   else if(packed_data_r_valid&&(packed_data_count==3'd4))
   packed_data_count<=0;
   
   else if(packed_data_r_valid)
   packed_data_count<=packed_data_count+1;
    
   
  always@(posedge clk or negedge  rst_n)
    if(!rst_n)     
   begin
   //packed_data_r      <=0;
   packed_data_r_valid<=0;
   end
   else if(packed_data_r_valid&&(packed_data_count==3'd4) )
   packed_data_r_valid<=0;
  else if(packed_all_valid )
   packed_data_r_valid<=1;
   
   
   always@(posedge clk )
   packed_all_valid_r<=packed_all_valid;
   
   
   
   
  always@(posedge clk or negedge  rst_n)
     if(!rst_n)  
     begin
       //data1_r<=0;
       data2_r<=0;
       data3_r<=0;
       data4_r<=0;
       data5_r<=0;
       
       
    end
  else  if(packed_all_valid)
  begin
      //data1_r<=data1;
       data2_r<=data2;
       data3_r<=data3;
       data4_r<=data4;
       data5_r<=data5;
       
       
  end






   always@(posedge clk or negedge  rst_n)
    if(!rst_n)    
      packed_data_r<=0;
    else if(packed_all_valid)
      packed_data_r<=data1;
    else if(packed_data_r_valid&&(packed_data_count==3'd0))
      packed_data_r<=data2_r;
   else if(packed_data_r_valid&&(packed_data_count==3'd1))
      packed_data_r<=data3_r;
    else if(packed_data_r_valid&&(packed_data_count==3'd2))
           packed_data_r<=data4_r;
    else if(packed_data_r_valid&&(packed_data_count==3'd3))
                packed_data_r<=data5_r;
   
   
 shift_reg#(
 .shift_ele_width(16),
 .shift_stage    (8 )
 )
shift_reg_0(
  .clk         (   clk              )  ,                                      //input                                        clk,
  .rst_n       (   rst_n            )  ,                                      //input                                        rst_n,
  .data_in     (  phase_f2_r        )  ,                                      //input  [shift_ele_width-1:0]                 data_in,
  .data_in_vld (  phase_f2_valid_r  )  ,                                      //input                                        data_in_vld,
  .data_out    (  shift_out_f2      )  ,                                       //output     [shift_ele_width*shift_stage-1:0] data_out, 
  .data_out_vld(  shift_out_valid_f2)                                         //output                                       data_out_vld  
);
  shift_reg#(
  .shift_ele_width(80),
  .shift_stage    (8 )
  )
 shift_reg_2(
   .clk         (   clk                              )  ,                                      //input                                        clk,
   .rst_n       (   rst_n                            )  ,                                      //input                                        rst_n,
   .data_in     ({denisty_phase_r,fradi_phase_r,phase_f1_r,phase_f2_r,phase_f3_r}  )  ,                                      //input  [shift_ele_width-1:0]                 data_in,
   .data_in_vld (  phase_f2_valid_r                  )  ,                                      //input                                        data_in_vld,
   .data_out    ({ data1,data2,data3,data4,data5}               )  ,                                       //output     [shift_ele_width*shift_stage-1:0] data_out, 
   .data_out_vld(  packed_all_valid               )                                         //output                                       data_out_vld  

////.data_out    (            )  ,  
////.data_out_vld(           )       
 ); 






    
    endmodule
