`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/31 21:07:03
// Design Name: 
// Module Name: RPJP_processing_unit_v2
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


module RPJP_processing_unit_v2(
 input		wire		   clk,
input        wire           rst_n,
input        wire[31:0]     PHASE_IN,
input        wire           PHASE_IN_en,
output       wire[31:0]     PHASE_out,//floating_point
output       wire           PHASE_out_EN,
output      wire [15:0]     phase_out_fix,     
output       wire           phase_out_fix_en,
output       reg           PHASE_out_complement_binary_en_r ,
output       reg   [75:0]  phase_result_degree   //1bit sign   27bit interger   48 bit fraction    

);
localparam PI=             32'b01100100100000000000000000000000; //0 sign 11 interger 0010010000000 fraction 29
localparam PI_cmp=         33'b001100100100000000000000000000000;//0 sign 011 interger 0010010000000 fraction 13
localparam PImupti2=       32'b01100100100000000000000000000000; //0 sign 110   interger 010010000000 fraction 28
localparam PI_invert=      {~PI[31],~PI[30:0]+1'b1};                                      //'b1110010010000000; //1 sign 11 interger 0010010000000 fraction 13
localparam PI_invert_cmp=  {~PI_cmp[32],~PI_cmp[31:0]+1'b1};   // 'b10110010010000000;//1 sign 011 interger 0010010000000 fraction 13
localparam PImupti2_invert={~PImupti2[31],~PImupti2[30:0]+1'b1};      //'b11100100100000000;//1 sign 110   interger 010010000000 fraction 12
reg [31:0]  PHASE_IN_r1='d0;  
reg [31:0]  PHASE_IN_r2='d0;
reg [31:0]  PHASE_IN_r3='d0;
reg [31:0]  PHASE_IN_r4='d0;
reg [31:0]  PHASE_IN_r5='d0;
 reg [31:0]  PHASE_IN_r6='d0;
reg [32:0] phase_subtract='d0;
always@(posedge clk or negedge rst_n)
   if(!rst_n)
   begin   
    PHASE_IN_r1 <='d0;//PHASE_IN_en_r
    PHASE_IN_r2 <='d0;//PHASE_IN_en_rr
    PHASE_IN_r3 <='d0;//PHASE_IN_en_rrr
    PHASE_IN_r4 <='d0;//PHASE_IN_en_rrrr
    PHASE_IN_r5 <='d0;//PHASE_IN_en_rrrrr
    PHASE_IN_r6 <='d0; 
   end
   else
   begin   
    PHASE_IN_r1 <=PHASE_IN;
    PHASE_IN_r2 <=PHASE_IN_r1;
    PHASE_IN_r3 <=PHASE_IN_r2;
    PHASE_IN_r4 <=PHASE_IN_r3;
    PHASE_IN_r5 <=PHASE_IN_r4;
    PHASE_IN_r6 <=PHASE_IN_r5;
   end    
reg  PHASE_IN_en_r=0;
reg  PHASE_IN_en_rr=0;
reg  PHASE_IN_en_rrr=0;
reg  PHASE_IN_en_rrrr=0;
reg  PHASE_IN_en_rrrrr=0; 

always@(posedge clk)
 begin
    PHASE_IN_en_r<=PHASE_IN_en;
    PHASE_IN_en_rr<=PHASE_IN_en_r;
    PHASE_IN_en_rrr<=PHASE_IN_en_rr;
    PHASE_IN_en_rrrr<=PHASE_IN_en_rrr;
    PHASE_IN_en_rrrrr<=PHASE_IN_en_rrrr; 
 end

 always@(posedge clk or negedge rst_n)
   if(!rst_n)
  phase_subtract<='d0;
 else if(PHASE_IN_en_r)
  phase_subtract<=$signed(PHASE_IN_r1)-$signed(PHASE_IN_r2);//PHASE_IN_en_rr VALID
 
 reg     larger=0;
 reg     smaller=0;
 reg     sign=0;
 
always@(posedge clk or negedge rst_n)
   if(!rst_n)
  begin
   larger <=0;
   smaller<=0;
   sign   <=0;     
  end
 else if((~phase_subtract[32])&&(phase_subtract[31:0]>=PI_cmp[31:0])&&(PHASE_IN_en_rr))//>pi
  begin
   larger <=1;
   smaller<=0;
   sign   <=0;     
  end  
 else if((phase_subtract[32])&&(phase_subtract<=PI_invert_cmp)&&(PHASE_IN_en_rr))//>-pi   2's complement
  begin
   larger <=1;
   smaller<=0;
   sign   <=1;     
  end  
 else if(PHASE_IN_en_rr)
 begin
   larger <=0;
   smaller<=1;
   sign   <=phase_subtract[32];     
  end
 else  
 begin
   larger <=0;
   smaller<=0;
   sign   <=0;    
 end
 
 reg  [15:0] phase_acc_register='d0; //complement
 
always@(posedge clk or negedge rst_n)
   if(!rst_n)
      phase_acc_register<=0;
//  else if( PHASE_IN_en_rrr&&larger&&sign&&(phase_acc_register==16'hFFFF)  )
//       phase_acc_register<=16'h0001; 
// else if  (PHASE_IN_en_rrr&&larger&&(~sign)&&(phase_acc_register==16'h0001) ) 
//      phase_acc_register<=16'hFFFF;      
 else  if(PHASE_IN_en_rrr&&larger&&sign)     
       phase_acc_register<=phase_acc_register+16'h0001; //1 complement
 else  if(PHASE_IN_en_rrr&&larger&&(~sign))
       phase_acc_register<=phase_acc_register+16'hFFFF;  //-1
         
 reg [47:0] phase_correction_data='d0;//1bit sign   19bit interger   28bit fraction
always@(posedge clk or negedge rst_n)  ////1 sign 3  interger  fraction 28* 1 sign   interger  15
   if(!rst_n)
      phase_correction_data<=0;    
 else if(PHASE_IN_en_rrrr)
    phase_correction_data<=$signed(phase_acc_register)*$signed(PImupti2);////0 sign 110   interger 010010000000 fraction 28
 
 (*mark_debug = "true"*)reg   [48:0] PHASE_out_complement_binary='d0;//1bit sign   20bit interger   28 bit fraction
(*mark_debug = "true"*) reg          PHASE_out_complement_binary_en='d0;    
 wire  [47:0]       phase_rr_compl;
(*mark_debug = "true"*) wire  [48:0]  PHASE_out_complement_binary_abs;
 assign  PHASE_out_complement_binary_abs=(PHASE_out_complement_binary[48])? {~PHASE_out_complement_binary[48],~PHASE_out_complement_binary[47:0]+1'b1 }  :PHASE_out_complement_binary ;
    parameter   coef_degree=27'b011100101001011101110000011; //1bit sign   6bit interger   20 bit fraction 
                               
always@(posedge clk or negedge rst_n)  ////1 sign 3  interger  fraction 28* 1 sign   interger  15
       if(!rst_n)
    phase_result_degree<=0;
    else if(PHASE_out_complement_binary_en  )
    phase_result_degree<=$signed(coef_degree)*$signed(PHASE_out_complement_binary);
    
  always@(posedge clk)  
   PHASE_out_complement_binary_en_r<= PHASE_out_complement_binary_en;
    
assign           phase_out_fix= {phase_result_degree[75],phase_result_degree[58:44]}   ;     
assign           phase_out_fix_en=PHASE_out_complement_binary_en_r       ;
 
 
 
 assign  phase_rr_compl={PHASE_IN_r5[31],(PHASE_IN_r5[31])?17'b11111111111111111:17'b0,PHASE_IN_r5[30:1]};
 always@(posedge clk or negedge rst_n)
   if(!rst_n)
   begin
 PHASE_out_complement_binary<='d0;//1bit sign   18bit interger   29 bit fraction
 
 end
 
 else if(PHASE_IN_en_rrrr||PHASE_IN_en_rrrrr)
 begin
 PHASE_out_complement_binary<=$signed(phase_correction_data)+$signed(phase_rr_compl);//1bit sign   19bit interger   28 bit fraction

 end

  always@(posedge clk or negedge rst_n)
     if(!rst_n)
  PHASE_out_complement_binary_en<='d0;
  else if(PHASE_IN_en_rrrrr)
   PHASE_out_complement_binary_en<='d1;
  else  
  PHASE_out_complement_binary_en<='d0;
  
 floating_point_3 floating_point_3_0 (
 .aclk                 (   clk                          ), // : IN STD_LOGIC;
 .s_axis_a_tvalid      ( PHASE_out_complement_binary_en ), // : IN STD_LOGIC;
 .s_axis_a_tdata       ({7'b0,PHASE_out_complement_binary}), // : IN STD_LOGIC_VECTOR(55 DOWNTO 0);
 .m_axis_result_tvalid ( PHASE_out_EN                   ), // : OUT STD_LOGIC;
 .m_axis_result_tdata  (  PHASE_out                     )  // : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
); 
  
endmodule  

