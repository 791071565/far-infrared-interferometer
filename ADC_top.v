`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/19 15:51:37
// Design Name: 
// Module Name: ADC_top
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


module ADC_top
#(
   parameter   channel_enable_mode ="No",  //"yes" or "no"
   parameter   sample_rate_enable_mode ="No" //"yes" or "no"
)
(
  input          clk_fpga,
// input          fifo_rd_clk,
output         CSB,
output         SCLK,
inout          SDIO,
input  [15:0]  DinA,
input          DCOA,
input          ORA,
input  [15:0]  DinB,
input          DCOB,
input          ORB,
output         SYNC,
output         PDWN,
output         OEB,
//  input          sample_en ,
// output         fifo_CHA_ready,
// output         fifo_CHB_ready,
// input          fifo_CHA_vld, 
// input          fifo_CHB_vld, 
// output [15:0]  DoutA,
// output reg  DoutA_en,
// output [15:0]  DoutB,
// output reg  DoutB_en,
// output  spi_write 
output     clk_adc,

output   [15:0] DAC1_DA,  
output   [15:0] DAC1_DB,  
//output   [15:0] DAC2_DA,  
                           
output     DAC1_PD ,         
output     DAC1_XOR,         
//output     DAC2_PD ,         
//output     DAC2_XOR  ,       



output   dac_clk_p,
output   dac_clk_n,



output   dac_clk_p_1,
output   dac_clk_n_1,

output   [15:0] DAC1_DA_1,  
output   [15:0] DAC1_DB_1,  
//output   [15:0] DAC2_DA,  
                            
output     DAC1_PD_1,         
output     DAC1_XOR_1  ,  


   output                  sample_clk  ,
  (*mark_debug = "true"*) output     reg [127:0]  sample_data_CH1  ,
  (*mark_debug = "true"*) output     reg          sample_data_valid_CH1  ,
   (*mark_debug = "true"*) output     reg [127:0]  sample_data_CH2  ,
   (*mark_debug = "true"*) output     reg          sample_data_valid_CH2  ,
 
   input                  start_sample,
   input                  stop_sample, 

output  wire         alg_clk,
output               sample_data_valid_posedge_CH1,
output               sample_data_valid_posedge_CH2 ,

input                test_mode,

input   [31:0]       sample_rate_cfg,
input                adc_ch1_en     ,
input                adc_ch2_en   ,

(*mark_debug = "true"*)  output  reg [15:0] DinA_r,

(*mark_debug = "true"*) output  reg [15:0] DinB_r,


(*mark_debug = "true"*)output  reg   DinB_vld,

(*mark_debug = "true"*)output  reg   DinA_vld,

input     count_equal,

output    alg_rst_trig ,


input         trig_work ,

output  reg  over_flow ,

input   [15:0]  feedback_data
);
wire clk;
 wire  rst_n;
 wire  clk_100M;
 wire  clk_100M_1; 

   assign dac_clk_p=clk_100M;
   assign dac_clk_n=clk_100M_1;
 assign dac_clk_p_1=clk_100M;
 assign dac_clk_n_1= clk_100M_1;  
  
  

  
  
 clk_wiz_0  clk_wiz_0_1
  (
   .clk_out1(    clk              ),
   .clk_out2(    clk_adc             ),
   .clk_out3(    clk_100M             ),
    .clk_out4(    clk_100M_1             ), 
    .clk_out5(    alg_clk             ),  
   .reset   (    0                    ),
   .locked  (                        ),
   .clk_in1 (  clk_fpga         )
  );
 
 
 
 reset_power_on reset_power_on_0(
 . clk         (clk               ) ,
 . user_rst    (  0                    ) ,          //user reset, high active
 . power_on_rst( rst_n              )            //power on reset,high active     
  );
  wire  DCOA_wire;
 assign DCOA_wire=DCOA;
  wire  DCOB_wire;
 assign DCOB_wire=DCOB;
 assign  sample_clk=DCOA;
 
 reg   stop_sample_sig;
 always@(posedge DCOA or negedge ch_A_rst_n)
   if(!ch_A_rst_n)
     stop_sample_sig<=1'b0;
   else if(count_equal&&stop_sample_sig )  
      stop_sample_sig<=1'b0;
   else if(stop_sample)
     stop_sample_sig<=1'b1;
 
reg sample_en;
reg sample_en_r;
assign alg_rst_trig=(!sample_en)&&sample_en_r;
 always@(posedge DCOA or negedge ch_A_rst_n)
  if(!ch_A_rst_n)
  sample_en<=1'b0;
  //else if(start_sample )
 else if(start_sample)
  sample_en<=1'b1;
  else if(stop_sample )
   //else if(count_equal&&stop_sample_sig ) 
   
 sample_en<=1'b0;
 always@(posedge DCOA or negedge ch_A_rst_n)
 if(!ch_A_rst_n)
  sample_en_r<=1'b0;
 else
  sample_en_r<=sample_en;
 
 
 wire adc_initial_finish;
wire  adc_initial_finish_0=1'b1;
 assign         PDWN=1'b0;
 assign         OEB=1'b0;  
 assign         SYNC=1'b0;     
 reg    adc_sample_rst_n_A_r=0;
 reg    adc_sample_rst_n_A_rr=0; 
 reg    adc_sample_rst_n_B_r=0;  
 reg    adc_sample_rst_n_B_rr=0;  
 wire   ch_A_rst_n;
 wire   ch_B_rst_n;
 assign ch_A_rst_n=adc_sample_rst_n_A_rr;
 assign ch_B_rst_n=adc_sample_rst_n_B_rr;
 always@(posedge DCOA)
 begin  
   adc_sample_rst_n_A_r<=adc_initial_finish_0;
   adc_sample_rst_n_A_rr<=adc_sample_rst_n_A_r;
 end
 
 always@(posedge DCOB)
 begin  
   adc_sample_rst_n_B_r<=adc_initial_finish_0;
   adc_sample_rst_n_B_rr<=adc_sample_rst_n_B_r;
 end
 
//(*mark_debug = "true"*)  reg  [15:0]  DAT_A;
//(*mark_debug = "true"*)  reg          DAT_A_en;
//(*mark_debug = "true"*)  reg  [15:0]  DAT_B; 
//(*mark_debug = "true"*)  reg          DAT_B_en;
 
//  wire  [15:0]  complement_binary_A;
// //assign  complement_binary_A={~DinA[15],DinA[14:0]};
// assign complement_binary_A=DinA;
// wire  [15:0]  complement_binary_B; 
//// assign  complement_binary_B={~DinB[15],DinB[14:0]}; 
// assign complement_binary_B=DinB;
// wire [15:0]  binary_A;
// wire[15:0]   binary_B;
//// assign  binary_A=(complement_binary_A[15])?({~complement_binary_A[15],~complement_binary_A[14:0]}):complement_binary_A;
//// assign  binary_B=(complement_binary_B[15])?({~complement_binary_B[15],~complement_binary_B[14:0]}):complement_binary_B; 
// assign  binary_A=complement_binary_A;
// assign  binary_B=complement_binary_B;
 
//(*mark_debug = "true"*) wire[15:0] complement_A;
//(*mark_debug = "true"*) wire[15:0] complement_B;
// 
// assign complement_A=(DinA[15])?({DinA[15],~DinA[14:0]+1'b1}):DinA;
// assign complement_B=(DinB[15])?({DinB[15],~DinB[14:0]+1'b1}):DinB;
// 
// always@(posedge DCOA  or negedge ch_A_rst_n)
//   if(!ch_A_rst_n)
//     DAT_A<=16'b0;
//   else  
//     DAT_A<=binary_A;
//  always@(posedge DCOA  or negedge ch_A_rst_n)
//   if((!ch_A_rst_n)||ORA)
//     DAT_A_en<=1'b0;
//   else if(sample_en)
//     DAT_A_en<=1'b1;
//   else   DAT_A_en<=1'b0;

 
//always@(posedge DCOB  or negedge ch_B_rst_n) 
//  if(!ch_B_rst_n) 
//    DAT_B<=16'b0; 
//  else   
//    DAT_B<=binary_B;
// always@(posedge DCOB  or negedge ch_B_rst_n) 
//  if((!ch_B_rst_n)||ORB) 
//    DAT_B_en<=1'b0; 
//  else  if(sample_en)
//    DAT_B_en<=1'b1; 
//  else   DAT_B_en<=1'b0;
/* wire  empty_fifo_A;
 wire  empty_fifo_B;
 assign  fifo_CHA_ready=!empty_fifo_A;
 assign  fifo_CHB_ready=!empty_fifo_B;
 
 
always@(posedge fifo_rd_clk  or negedge rst_n) 
  if(!rst_n)
    DoutA_en<=1'b0; 
  else  if(fifo_CHA_ready&&fifo_CHA_vld)
    DoutA_en<=1'b1; 
  else   DoutA_en<=1'b0; 
 
 
always@(posedge fifo_rd_clk  or negedge rst_n) 
  if(!rst_n)
    DoutB_en<=1'b0; 
  else  if(fifo_CHB_ready&&fifo_CHB_vld)
    DoutB_en<=1'b1; 
  else   DoutB_en<=1'b0;   
 
 
 fifo_generator_0 fifo_generator_0_0
     (
       .rst         ( 0                   ),   //: IN STD_LOGIC;
       .wr_clk      ( DCOA                  ),   //: IN STD_LOGIC;
       .rd_clk      ( fifo_rd_clk           ),   //: IN STD_LOGIC;
       .din         (DAT_A  ),                       //: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
       .wr_en       (DAT_A_en),                       //: IN STD_LOGIC;
       .rd_en       (fifo_CHA_ready&&fifo_CHA_vld),                       //: IN STD_LOGIC;
       .dout        (DoutA ),                       //: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
       .full        (       ),             //: OUT STD_LOGIC;
       .empty       (empty_fifo_A          )             //: OUT STD_LOGIC;
 
     );    
 
 fifo_generator_0 fifo_generator_0_1
     (
       .rst         ( 0        ),   //: IN STD_LOGIC;
       .wr_clk      ( DCOB       ),   //: IN STD_LOGIC;
       .rd_clk      ( fifo_rd_clk),   //: IN STD_LOGIC;
       .din         (DAT_B  ),                       //: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
       .wr_en       (DAT_B_en),                       //: IN STD_LOGIC;
       .rd_en       (fifo_CHB_ready&&fifo_CHB_vld),                       //: IN STD_LOGIC;
       .dout        (DoutB ),                       //: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
       .full        (          ),             //: OUT STD_LOGIC;
       .empty       (empty_fifo_B   )            //: OUT STD_LOGIC;
     );    
 
 */
 wire   trig; 
  spi_config_top spi_config_top_0(
 .trig              (trig              ),
 .clk               ( clk               ),
 .rst_n             ( rst_n             ),                  
 .CSB               ( CSB               ),
 .SCLK              ( SCLK              ),
 .SDIO              ( SDIO              ),
 .adc_initial_finish( adc_initial_finish)
//   .spi_write     (spi_write     )
   
);
  wire   button;
  ax_debounce ax_debounce_0(
 .clk           (   clk             ), 
 .rst           (    0                 ), 
 .button_in     (  button           ),
 .button_posedge(                     ),
 .button_negedge(  trig          ),
 .button_out    (                     )
 );
  
  
  
   vio_0 vio_0_1(
 .clk       (  clk             ),
 .probe_out0( button         )
 );
  
 
reg [15:0] DinA_r;
//(*mark_debug = "true"*) reg DCOA_r;
 reg ORA_r; 
 reg [15:0] DinB_r;
//(*mark_debug = "true"*) reg DCOB_r;
reg ORB_r; 
 
 always@(posedge DCOA )// or negedge ch_A_rst_n)
 // always@(posedge clk_100M)
  //if(!ch_A_rst_n)
  //begin
  //  DinA_r<=16'b0;
  //  ORA_r <=1'b0; 
  //  DinB_r<=16'b0;  
  //  ORB_r <=1'b0;    
  //  end
 // else  
   begin
    DinA_r<=DinA;
    ORA_r <=ORA; 
    DinB_r<=DinB;  
    ORB_r <=ORB;  
 end
//(*mark_debug = "true"*) reg [3:0] dco_cnt_A;
//  always@(posedge DCOA)
// dco_cnt_A<=dco_cnt_A+1'b1;
//(*mark_debug = "true"*) reg [3:0] dco_cnt_B;
//   always@(posedge DCOB)
//  dco_cnt_B<=dco_cnt_B+1'b1;
 
 
 
 dac_top dac_top_0(
  .rst     (    1'b0             ),
  .clk     (  clk_100M   ),
  .DAC1_DA (  DAC1_DA  ),
  .DAC1_DB (  DAC1_DB  ),
  .DAC2_DA (  DAC2_DA  ), 
  .DAC1_PD (  DAC1_PD  ),
  .DAC1_XOR(  DAC1_XOR ),
  .DAC2_PD (  DAC2_PD  ),
  .DAC2_XOR(  DAC2_XOR ),
  .feedback_data(feedback_data)
  );
 
 
 // OBUFDS #(
 //        .IOSTANDARD("LVDS25"), // Specify the output I/O standard
 //        .SLEW("SLOW")           // Specify the output slew rate
 //     ) OBUFDS_inst (
 //        .O(dac_clk_p),     // Diff_p output (connect directly to top-level port)
 //        .OB(dac_clk_n),   // Diff_n output (connect directly to top-level port)
 //        .I(clk_100M)      // Buffer input 
 //     );
 
 
 dac_top dac_top_1(
   .rst     (    1'b0             ),
   .clk     (  clk_100M   ),
   .DAC1_DA (  DAC1_DA_1  ),
   .DAC1_DB (  DAC1_DB_1  ),
   .DAC2_DA (  DAC2_DA_1  ), 
   .DAC1_PD (  DAC1_PD_1  ),
   .DAC1_XOR(  DAC1_XOR_1 ),
   .DAC2_PD (  DAC2_PD_1  ),
   .DAC2_XOR(  DAC2_XOR_1 ),
   .feedback_data(feedback_data)
   );
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 reg [7:0] shift_reg_CH1=8'b00000001;
 always@(posedge DCOA  or negedge ch_A_rst_n)
  if(!ch_A_rst_n)
 shift_reg_CH1<=8'b00000001;
 //else if(sample_en )
 else if(DinA_vld )
 shift_reg_CH1<={shift_reg_CH1[6:0],shift_reg_CH1[7]};
 //else if(!sample_en)
//  else if(!DinA_vld )
 else if(!sample_sig)
  shift_reg_CH1<=8'b00000001;
 
 reg [15:0] test_cnt;
  always@(posedge DCOA  or negedge ch_A_rst_n)
  if(!ch_A_rst_n)
 test_cnt<=16'd0;
 else if(sample_en&&test_mode)
  test_cnt<=test_cnt+1'b1;
 else
  test_cnt<=16'd0;
 
 always@(posedge DCOA  or negedge ch_A_rst_n)
  if(!ch_A_rst_n)
 sample_data_CH1<=128'd0;

 
 
  else if(sample_en&&test_mode)
  sample_data_CH1<={sample_data_CH1[111:0] ,{test_cnt}};
 
// else if(sample_en )
 else if(DinA_vld )
 sample_data_CH1<={sample_data_CH1[111:0] ,{DinA_r}};
 //else if(!sample_en)
  else if(!sample_sig)
  //else if(!DinA_vld )
  sample_data_CH1<=128'd0; 
//branch 
  generate 
   if(channel_enable_mode =="Yes")
  always@(posedge DCOA  or negedge ch_A_rst_n)
  if(!ch_A_rst_n)
 sample_data_valid_CH1<=1'b0;
 else if(shift_reg_CH1[7] &&adc_ch1_en)
 sample_data_valid_CH1<=1'b1;
 else 
 sample_data_valid_CH1<=1'b0;
 
 else 
 
  always@(posedge DCOA  or negedge ch_A_rst_n)
  if(!ch_A_rst_n)
 sample_data_valid_CH1<=1'b0;
 else if(shift_reg_CH1[7] )
 sample_data_valid_CH1<=1'b1;
 else 
 sample_data_valid_CH1<=1'b0;
 
 endgenerate
 
  reg  sample_data_valid_r_CH1=0;
  reg  sample_data_valid_rr_CH1=0;
  reg  sample_data_valid_rrr_CH1=0;
 always@(posedge clk_100M) 
 begin
 sample_data_valid_r_CH1<=sample_data_valid_CH1;    
 sample_data_valid_rr_CH1<=sample_data_valid_r_CH1;   
 sample_data_valid_rrr_CH1<=sample_data_valid_rr_CH1;  
 
 end
 assign  sample_data_valid_posedge_CH1=sample_data_valid_rr_CH1&&(!sample_data_valid_rrr_CH1);
 
 
 reg [7:0] shift_reg_CH2=8'b00000001;
  always@(posedge DCOB  or negedge ch_B_rst_n)
   if(!ch_B_rst_n)
  shift_reg_CH2<=8'b00000001;
  //else if(sample_en )
  else if( DinB_vld  )
  shift_reg_CH2<={shift_reg_CH2[6:0],shift_reg_CH1[7]};
  //else if(!sample_en)
   // else if( !DinB_vld  )
   else if(!sample_sig)
   shift_reg_CH2<=8'b00000001;
  

  
  
  always@(posedge DCOB  or negedge ch_B_rst_n)
   if(!ch_B_rst_n)
  sample_data_CH2<=128'd0;
 // else if(sample_en &&test_mode)
 //   sample_data_CH2<={sample_data_CH2[111:0] ,{test_cnt}};
 // else if(sample_en )
 else if( DinB_vld  )
  sample_data_CH2<={sample_data_CH2[111:0] ,{DinB_r}};
  
  
  
//  else if(!sample_en)
   // else if( !DinB_vld  )
     else if(!sample_sig)
   sample_data_CH2<=128'd0;
 //branch  
  generate 
     if(channel_enable_mode =="Yes") 
   always@(posedge DCOB  or negedge ch_B_rst_n)
   if(!ch_B_rst_n)
  sample_data_valid_CH2<=1'b0;
  else if(shift_reg_CH2[7]  &&adc_ch2_en)
  sample_data_valid_CH2<=1'b1;
  else 
  sample_data_valid_CH2<=1'b0;
  
  else
    always@(posedge DCOB  or negedge ch_B_rst_n)
   if(!ch_B_rst_n)
  sample_data_valid_CH2<=1'b0;
  else if(shift_reg_CH2[7] )
  sample_data_valid_CH2<=1'b1;
  else 
  sample_data_valid_CH2<=1'b0;
  
  endgenerate
  
  
   reg  sample_data_valid_r_CH2=0;
   reg  sample_data_valid_rr_CH2=0;
   reg  sample_data_valid_rrr_CH2=0;
  always@(posedge clk_100M) 
  begin
  sample_data_valid_r_CH2<=sample_data_valid_CH2;    
  sample_data_valid_rr_CH2<=sample_data_valid_r_CH2;   
  sample_data_valid_rrr_CH2<=sample_data_valid_rr_CH2;  
  
  end
  assign  sample_data_valid_posedge_CH2=sample_data_valid_rr_CH2&&(!sample_data_valid_rrr_CH2);
 
 
 
 
 
// (*mark_debug = "true"*)wire  data_get_trig;
// assign data_get_trig=(sample_en&&(DinB==16'd0)&&(DinB_r[15]));
 reg    sample_sig;
 
 always@(posedge DCOA)   
  if(!ch_A_rst_n)
  begin
   DinB_vld<=1'b0;           
   DinA_vld<=1'b0; 
   sample_sig<=0; 
   end  
//   else if( DinA_vld&& (&data_cnt))
//   begin
//    DinB_vld<=1'b0;           
//    DinA_vld<=1'b0;  
//    end  
 else if(!sample_en)
    begin
    DinB_vld<=1'b0;
    DinA_vld<=1'b0;
    sample_sig<=0;
    end


   
  //else if(sample_en&&(DinB==16'd0)&&(DinB_r[15]))
  else if(sample_en&&(!sample_sig))
  begin
   DinB_vld<=1'b1;
   DinA_vld<=1'b1;
   sample_sig<=1'b1; 
   end
 
 else if(sample_en&&sample_sig)
 begin
//    DinB_vld<=1'b1;
//    DinA_vld<=1'b1;
  DinB_vld<=~DinB_vld; 
  DinA_vld<=~DinA_vld; 
 
 
 end
    always@(posedge DCOA  )
     
    
over_flow<=(ORA_r||ORB_r);
 endmodule
