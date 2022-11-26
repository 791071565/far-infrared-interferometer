`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/01 23:04:43
// Design Name: 
// Module Name: phase_inv_judge_sub_bias
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


module phase_inv_judge_sub_bias(
 input               clk,
  input               rst_n,
  input   [15:0]      phase_in,
  input               phase_in_valid,
  output reg  [15:0]  phase_out,
  output reg          phase_out_valid  
);
reg  phase_in_valid_r;
 //reg  [15:0]  phase_average;
 wire  phase_in_negedge;
 wire  phase_in_posedge; 
 assign  phase_in_negedge=(!phase_in_valid)&&phase_in_valid_r;
 assign  phase_in_posedge=phase_in_valid&&(!phase_in_valid_r);


reg [22:0]  phase_accum;
wire   [15:0]  phase_average;
wire   [15:0]  phase_average_inv;
assign  phase_average=phase_accum[22:7];
assign  phase_average_inv={~phase_accum[22],~phase_accum[21:7]+1'b1};
wire [15:0]  phase_in_inv;
assign  phase_in_inv={~phase_in[15],~phase_in[14:0]+1'b1};
reg  [7:0]   accum_count;
reg          accum_sig;


reg [2:0] state;
localparam  IDLE         =3'd0;
localparam  PHASE_COUNT  =3'd1;
localparam  PHASE_JUDGE  =3'd2;
localparam  PHASE_CORRECTION  =3'd3;
localparam  PHASE_NO_CORRECTION  =3'd4;

 always@(posedge clk or negedge rst_n)
  if(!rst_n)
  state<=IDLE;
  else  begin
   case(state)
   IDLE:
     state<=(phase_in_posedge)?PHASE_COUNT:IDLE;
     
   PHASE_COUNT:
     state<=(phase_in_negedge)?PHASE_JUDGE:PHASE_COUNT;     
     
   PHASE_JUDGE:  
     state<=(positive_count>=negative_count)?PHASE_NO_CORRECTION:PHASE_CORRECTION;
     
     
   PHASE_CORRECTION:  
     state<=PHASE_CORRECTION;  
     
     
   PHASE_NO_CORRECTION:  
     state<=PHASE_NO_CORRECTION;

    default:;
    endcase
    end

    reg [7:0] positive_count;
    reg [7:0] negative_count;
    
   always@(posedge clk or negedge rst_n)
    if(!rst_n) 
    positive_count<=0;
    else if(((state==IDLE)&&phase_in_posedge)||((state==PHASE_COUNT)&&phase_in_valid))
    positive_count<=(!phase_in[15])?(positive_count+1'b1):positive_count;
    
   always@(posedge clk or negedge rst_n)
    if(!rst_n) 
    negative_count<=0;
    else if(((state==IDLE)&&phase_in_posedge)||((state==PHASE_COUNT)&&phase_in_valid))
    negative_count<=(phase_in[15])?(negative_count+1'b1):negative_count; 
    
    
 always@(posedge clk or negedge rst_n)
  if(!rst_n)
    phase_out_valid<=0;
   else if((state==PHASE_CORRECTION)||(state==PHASE_NO_CORRECTION ) )
    phase_out_valid<=phase_in_valid;
    
  always@(posedge clk or negedge rst_n)
  if(!rst_n) 
    phase_out<=0;
   else if(state==PHASE_CORRECTION) 
    phase_out<=phase_in_inv+phase_average;
   // phase_out<=phase_in_inv+phase_average;
    else
    phase_out<=phase_in+phase_average_inv;
    
   always@(posedge clk or negedge rst_n)
     if(!rst_n)  
    accum_count<=0;
    else if(((state==IDLE)&&(phase_in_posedge)||((state==PHASE_COUNT)&&phase_in_valid)))
    accum_count<=accum_count+1'b1;
    
    always@(posedge clk or negedge rst_n)
     if(!rst_n) 
      accum_sig<=0;
    else if(accum_count==8'd127)
      accum_sig<=1;
    
  always@(posedge clk or negedge rst_n)
   if(!rst_n)
    phase_accum<=0; 
  else if(((state==IDLE)&&(phase_in_posedge)||((state==PHASE_COUNT)&&phase_in_valid)))
    phase_accum<=(!accum_sig)?($signed(phase_accum)+$signed(phase_in)):phase_accum; 

  always@(posedge clk)
    phase_in_valid_r<=phase_in_valid;

   
endmodule
