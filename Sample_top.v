`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/19 15:39:21
// Design Name: 
// Module Name: Sample_top
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


module Sample_top#(
   parameter PL_LINK_CAP_MAX_LINK_WIDTH          = 4,            // 1- X1; 2 - X2; 4 - X4; 8 - X8
   parameter PL_SIM_FAST_LINK_TRAINING           = "FALSE",      // Simulation Speedup
   parameter PL_LINK_CAP_MAX_LINK_SPEED          = 1,             // 1- GEN1; 2 - GEN2; 4 - GEN3
   parameter C_DATA_WIDTH                        = 64 ,
   parameter EXT_PIPE_SIM                        = "FALSE",  // This Parameter has effect on selecting Enable External PIPE Interface in GUI.
   parameter C_ROOT_PORT                         = "FALSE",      // PCIe block is in root port mode
   parameter C_DEVICE_NUMBER                     = 0,            // Device number for Root Port configurations only
   parameter AXIS_CCIX_RX_TDATA_WIDTH     = 128, 
   parameter AXIS_CCIX_TX_TDATA_WIDTH     = 128,
   parameter AXIS_CCIX_RX_TUSER_WIDTH     =1,
   parameter AXIS_CCIX_TX_TUSER_WIDTH     = 1,
   parameter Bram_data_width     = 128
   )
   ( 
   //pcie 
     output [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0] pci_exp_txp,
     output [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0] pci_exp_txn,
     input [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0]  pci_exp_rxp,
     input [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0]  pci_exp_rxn,

     input 					 sys_clk_p,
     input 					 sys_clk_n,
     input 					 sys_rst_n  ,
   // ADC  
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
      
         input CLK_IN1_D_0_clk_n, 
          input CLK_IN1_D_0_clk_p,
          
          output [14:0]DDR3_0_addr,
            output [2:0]DDR3_0_ba,
            output DDR3_0_cas_n,
            output [0:0]DDR3_0_ck_n, 
            output [0:0]DDR3_0_ck_p,
            output [0:0]DDR3_0_cke,
            output [0:0]DDR3_0_cs_n,
            output [7:0]DDR3_0_dm,
            inout [63:0]DDR3_0_dq,
            inout [7:0]DDR3_0_dqs_n,
            inout [7:0]DDR3_0_dqs_p,
            output [0:0]DDR3_0_odt,
            output DDR3_0_ras_n,
            output DDR3_0_reset_n,
            output DDR3_0_we_n,
           input resetn_0, 
      
          input     extrenal_trig ,
         output      back_board_dir ,
       //   output    back_board_trig 
       inout      back_board_trig_0 
       
     );
     
  wire   sample_clk        ;
  wire  [127:0]  sample_data       ;
  wire   sample_data_valid ;
  wire   start_sample      ;
  wire   stop_sample       ;
  wire  sample_data_valid_posedge;
  wire   test_mode;
  wire   adc_ch1_en     ;
  wire   adc_ch2_en     ;
  wire   alg_en         ;
  wire [31:0]  sample_rate_cfg;
  wire  [127:0] sample_data_CH2      ;
  wire          sample_data_valid_CH2;
  
  wire     sample_data_valid_posedge_0;
 wire    alg_clk;
 
   wire     [15:0]        ADC_data_in_A_channel   ;       
   wire                   ADC_data_in_A_channel_en;       
   wire    [15:0]         ADC_data_in_B_channel   ;       
   wire                   ADC_data_in_B_channel_en;   
 
 
 wire  [127:0]    raw_phase_to_pcie_frequency1      ;
 wire             raw_phase_to_pcie_frequency1_valid;
 
 wire             count_equal;
 wire             alg_rst_trig;
  wire            bram_clk_out;
 (*mark_debug = "true"*)reg     extrenal_trig_r;
 
  wire     trig_out_0;
 (*mark_debug = "true"*) reg  back_board_trig_0_r;
 wire  [15:0]     feedback_data;
 
  assign back_board_trig_0=(!back_board_dir)?1'bz:trig_out_0;
 assign  trig_out_0=extrenal_trig;
 always@(posedge bram_clk_out)
 
 extrenal_trig_r<= extrenal_trig;
 
  always@(posedge bram_clk_out)
 
 back_board_trig_0_r<= back_board_trig_0;
 
 
 
//(*mark_debug = "true"*)  wire              trig_work;
//wire              extrenal_trig;
 
//  IBUFDS #(
//      .DIFF_TERM("FALSE"),       // Differential Termination
//      .IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE" 
//      .IOSTANDARD("LVCOMS33")     // Specify the input I/O standard
//   ) IBUFDS_inst (
//      .O(extrenal_trig),  // Buffer output
//      .I(extrenal_trig_p),  // Diff_p buffer input (connect directly to top-level port)
//      .IB(extrenal_trig_n) // Diff_n buffer input (connect directly to top-level port)
//   );

 
 
 wire  trig_work;
 assign trig_work=(back_board_dir)?extrenal_trig:back_board_trig_0;
 
 
 reg   trig_work_r;
 reg   trig_work_rr;
 wire  trig_work_posedge;
 assign trig_work_posedge=trig_work_r&&(!trig_work_rr);
  
 always@(posedge DCOA)
 begin
 trig_work_r<=extrenal_trig;
 trig_work_rr<=trig_work_r;
 end
// assign    back_board_trig=extrenal_trig;
// ax_debounce ax_debounce_0(
//. clk            (   DCOA           )  , 
//. rst            (     1'b0         )  , 
//. button_in      ((back_board_dir)?extrenal_trig:back_board_trig_0)  ,
//. button_posedge (  trig_work       )  ,
//. button_negedge (                  )  ,
//. button_out     (                  )
// );
 wire  tirg_to_pcie;
    cross_clock_domain#(
                .data_width(5'd1)
              )
             cross_clock_domain_2 (
            .clk1         (     DCOA            ),                                               //input                          clk1,
            .clk2         (      bram_clk_out        ),                                               //input                          clk2,
            .rst_n        (      1'b1           ),                                              //input                          rst_n,
            .data_in      ( trig_work_posedge     ),                                            //input [data_width-1'b1:0]      data_in,              //clk1
            .data_in_en   ( trig_work_posedge     ),                                         //input                          data_in_en,           //clk1
            .data_in_ready(                     ),           //output reg                     data_in_ready     =1,//clk1
            .data_out     (                     ),           //output reg [data_width-1'b1:0] data_out          =0,
            .data_out_en  ( tirg_to_pcie    )            //output reg                     data_out_en         =0
                 );
 
 
 
 wire  over_flow;
 
ADC_top ADC_top_0(
   . clk_fpga          ( clk_fpga                 ) ,
  
   . CSB               ( CSB                      ) ,
   . SCLK              ( SCLK                     ) ,
   . SDIO              ( SDIO                     ) ,
   . DinA              ( DinA                     ) ,
   . DCOA              ( DCOA                     ) ,
   . ORA               ( ORA                      ) ,
   . DinB              ( DinB                     ) ,
   . DCOB              ( DCOB                     ) ,
   . ORB               ( ORB                      ) ,
   . SYNC              ( SYNC                     ) ,
   . PDWN              ( PDWN                     ) ,
   . OEB               ( OEB                      ) ,
   . clk_adc           ( clk_adc                  ) , 
   . DAC1_DA           ( DAC1_DA                  ) ,  
   . DAC1_DB           ( DAC1_DB                  ) ,                               
   . DAC1_PD           ( DAC1_PD                  ) ,         
   . DAC1_XOR          ( DAC1_XOR                 ) ,         
   .dac_clk_p          (dac_clk_p                ) ,
   .dac_clk_n          (dac_clk_n                ) ,
   .dac_clk_p_1        (dac_clk_p_1              ) ,
   .dac_clk_n_1        (dac_clk_n_1              ) ,
   .DAC1_DA_1          (DAC1_DA_1                ) ,  
   .DAC1_DB_1          (DAC1_DB_1                ) ,                          
   .DAC1_PD_1          (DAC1_PD_1                ) ,         
   .DAC1_XOR_1         (DAC1_XOR_1               ) ,  
   .sample_clk         (     sample_clk             ) ,
   .sample_data_CH1        (  sample_data            ) ,
   .sample_data_valid_CH1  (  sample_data_valid      ) ,
   .  sample_data_CH2      ( sample_data_CH2        ) ,       
   . sample_data_valid_CH2 (sample_data_valid_CH2   ) , 
   .start_sample       (  start_sample           ) ,
   .stop_sample        (  stop_sample            ),
   .sample_data_valid_posedge_CH1(sample_data_valid_posedge),
   . sample_data_valid_posedge_CH2(sample_data_valid_posedge_0     ) ,
   . test_mode       ( test_mode     ),
   .sample_rate_cfg  (sample_rate_cfg),
   . adc_ch1_en      ( adc_ch1_en    ) ,
   . adc_ch2_en      ( adc_ch2_en    ) ,
   . alg_clk        (alg_clk      )  , 
  . DinA_r          ( ADC_data_in_A_channel   ),
   .DinB_r          ( ADC_data_in_B_channel              ),
   .DinB_vld        ( ADC_data_in_B_channel_en              ),
   .DinA_vld        ( ADC_data_in_A_channel_en              ), 
   
  .count_equal  (   count_equal    ) ,
  .alg_rst_trig (   alg_rst_trig    ),

   .trig_work( trig_work      ),
   .   over_flow (over_flow  ),
  . feedback_data(feedback_data)
   );
   
                wire   [0:0]  ddr3_ui_rst_n  ;
                wire          ddr3_user_clk  ;
                wire  [31:0]  rd_addr_0      ;
                wire   [127:0]rd_data_0      ;
                wire          rd_data_end_0  ;
                wire          rd_data_valid_0;
                wire  [19:0]  rd_len_0       ;
                wire          rd_ready_0     ;
                wire          rd_valid_0     ;
                wire  [31:0]  wr_addr_0      ;
                wire   [127:0]wr_data_0      ;
                wire          wr_data_end_0  ;
                wire          wr_data_req_0  ;
                wire   [19:0] wr_len_0       ;
                wire          wr_ready_0     ;
                wire          wr_valid_0     ;
                wire   [1:0]   frequency_mode; 
                wire  [31:0]   select_dat_update; 
                wire           phase_invert; 
                wire   [23:0]   ref_frequency; 
                wire   [23:0]   measure_frequency;   
    
    
    
     PCIE_DMA_TOP PCIE_DMA_TOP_0
      ( 
       . pci_exp_txp(pci_exp_txp),
       . pci_exp_txn(pci_exp_txn),
       . pci_exp_rxp(pci_exp_rxp),
       . pci_exp_rxn(pci_exp_rxn),
       . sys_clk_p(sys_clk_p ),
       . sys_clk_n(sys_clk_n ),
       . sys_rst_n(sys_rst_n ),  
       
         
        .sample_clk( alg_clk   ),
        .sample_data( raw_phase_to_pcie_frequency1 ),
        .sample_data_valid(raw_phase_to_pcie_frequency1_valid ) ,  
        
         .over_flow(over_flow ),
        .start_sample(  start_sample   )  ,
        .stop_sample (  stop_sample    ),
        .adc_clk(sample_clk),
        .test_mode(test_mode),
     //   output                 fan
       . adc_ch1_en     ( adc_ch1_en  ) ,
       . adc_ch2_en     ( adc_ch2_en  ) ,
       . alg_en         ( alg_en      ) ,
       . sample_rate_cfg_clk_adc(sample_rate_cfg  ),
        . CLK_IN1_D_0_clk_n( CLK_IN1_D_0_clk_n         ), 
        . CLK_IN1_D_0_clk_p( CLK_IN1_D_0_clk_p         ),
           
         .DDR3_0_addr   ( DDR3_0_addr                      ),
         .DDR3_0_ba     ( DDR3_0_ba                        ),
         .DDR3_0_cas_n  ( DDR3_0_cas_n                     ),
         .DDR3_0_ck_n   ( DDR3_0_ck_n                      ), 
         .DDR3_0_ck_p   ( DDR3_0_ck_p                      ),
         .DDR3_0_cke    ( DDR3_0_cke                       ),
         .DDR3_0_cs_n   ( DDR3_0_cs_n                      ),
         .DDR3_0_dm     ( DDR3_0_dm                        ),
         .DDR3_0_dq     ( DDR3_0_dq                        ),
         .DDR3_0_dqs_n  ( DDR3_0_dqs_n                     ),
         .DDR3_0_dqs_p  ( DDR3_0_dqs_p                     ),
         .DDR3_0_odt    ( DDR3_0_odt                       ),
         .DDR3_0_ras_n  ( DDR3_0_ras_n                     ),
         .DDR3_0_reset_n( DDR3_0_reset_n                   ),
         .DDR3_0_we_n   ( DDR3_0_we_n                      ),
         .resetn_0      ( resetn_0                         ),
         
          .ddr3_ui_rst_n  (   ddr3_ui_rst_n                        ),
          .ddr3_user_clk  (   ddr3_user_clk                        ),
          .rd_addr_0      (   rd_addr_0                            ),
          .rd_data_0      (   rd_data_0                            ),
          .rd_data_end_0  (   rd_data_end_0                        ),
          .rd_data_valid_0(   rd_data_valid_0                      ),
          .rd_len_0       (   rd_len_0                             ),
          .rd_ready_0     (   rd_ready_0                           ),
          .rd_valid_0     (   rd_valid_0                           ),
          .wr_addr_0      (   wr_addr_0                            ),
          .wr_data_0      (   wr_data_0                            ),
          .wr_data_end_0  (   wr_data_end_0                        ),
          .wr_data_req_0  (   wr_data_req_0                        ),
          .wr_len_0       (   wr_len_0                             ),
          .wr_ready_0     (   wr_ready_0                           ),
          .wr_valid_0     (   wr_valid_0                           ),
          .tirg_to_pcie   (   tirg_to_pcie                         ),
          .bram_clk_out   (   bram_clk_out                          ),
          .back_board_dir (  back_board_dir                         ),
          .frequency_mode   (  frequency_mode                       ),       // output   [1:0]   frequency_mode,
          .select_dat_update(  select_dat_update                    ),    // output  [31:0]   select_dat_update,
          .phase_invert     (  phase_invert                         ),         // output           phase_invert, 
          .ref_frequency    (  ref_frequency                        ),        // input   [23:0]   ref_frequency,
          .measure_frequency(  measure_frequency                    )     // input   [23:0]   measure_frequency  
          
//          .select_dat_update ( select_dat_update                    ),        
//          .phase_invert      ( phase_invert                          ), 
//          .ref_frequency     ( ref_frequency                         ), 
//          .measure_frequency ( measure_frequency                     )   
          
          
          
       );
    
    data_store data_store_0
    (
       .sample_clk           ( dac_clk_p                             )  ,
       .sample_data_CH1      (  sample_data                           )  ,
       .sample_data_valid_CH1(  sample_data_valid_posedge                     )  , 
       
        .sample_data_CH2      ( sample_data_CH2                          )  ,
        .sample_data_valid_CH2( sample_data_valid_posedge_0                    )  , 
       
       .algorithm_clk         (   dac_clk_p   ),
       .algorithm_data        (     0           ),
       .algorithm_data_valid  (      0          ),  
       
       
       .ddr3_ui_rst_n        ( ddr3_ui_rst_n                           )  ,
       .ddr3_user_clk        ( ddr3_user_clk                           )  ,
       .rd_addr_0            ( rd_addr_0                               )  ,
       .rd_data_0            ( rd_data_0                               )  ,
       .rd_data_end_0        ( rd_data_end_0                           )  ,
       .rd_data_valid_0      ( rd_data_valid_0                         )  ,
       .rd_len_0             ( rd_len_0                                )  ,
       .rd_ready_0           ( rd_ready_0                              )  ,
       .rd_valid_0           ( rd_valid_0                              )  ,
       .wr_addr_0            ( wr_addr_0                               )  ,
       .wr_data_0            ( wr_data_0                               )  ,
       .wr_data_end_0        ( wr_data_end_0                           )  ,
       .wr_data_req_0        ( wr_data_req_0                           )  ,
       .wr_len_0             ( wr_len_0                                )  ,
       .wr_ready_0           ( wr_ready_0                              )  ,
       .wr_valid_0           ( wr_valid_0                              )
     
    );
    
   (*mark_debug = "true"*) wire rst_n;
       reset_power_on #
         (
            .FREQ(125),
           . MAX_TIME(200)
         ) 
        reset_power_on_m0
         (            
            .clk                        (alg_clk                  ),               
            .user_rst                   (1'b0                     ),               //user reset high active
            .power_on_rst               (rst_n              )                //power on low active     
         );
    
   (*mark_debug = "true"*) wire  trig_rst_n;
    
    
    
    
    
    
    
    
    alg_top alg_top_0(
     .alg_clk                 (  alg_clk                       ),                                                         //input         alg_clk,
     .rst_n                   (    rst_n  &&trig_rst_n         ),                                                           //input         rst_n,
     .FFT_rst_n               (    rst_n                       ),                                                       //input         FFT_rst_n,
     .adc_clk                 (    DCOA               ),                                                         //input         adc_clk,
     .ADC_data_in_A_channel   (     ADC_data_in_A_channel   ),                                        //input  [15:0] ADC_data_in_A_channel   ,//2's complement
     .ADC_data_in_A_channel_en(  ADC_data_in_A_channel_en  ),                                        //input         ADC_data_in_A_channel_en,
     .ADC_data_in_B_channel   (  ADC_data_in_B_channel   ),                                        //input [15:0]  ADC_data_in_B_channel   ,
     .ADC_data_in_B_channel_en(  ADC_data_in_B_channel_en  ),                                        //input         ADC_data_in_B_channel_en,
     .start                   (         rst_n                           ),
     .PCIE_dma_engine_clk     (       alg_clk                           ),       
     .RAM_wr_en               (         1'b0                            ),               
     .RAM_wr_data             (         32'd0                           ),       
     .RAM_wr_addr             (          8'd0                           ),      
     .RAM_SEL                 (           1'b0                          ),  
     .ROM_SEL                 (           1'b0                          ), 
     .narrow_band_width       (          8'd0                           ),//        (        'd0                                ),             //input  [7:0]          narrow_band_width           ,
     .narrow_band_width_en    (          1'b0                           ),//    (        'd0                                ),             //input                 narrow_band_width_en        ,  
     .filter_mode             (        frequency_mode                   ), //           (        'd0                             ),             //input  [1:0]          filter_mode                 ,
     .filter_mode_en          (     1'b0                      ), // (        'd0                             ),             //input                 filter_mode_en              ,  
     .start_cmp_position      (         8'd0                            ), //     (         'd0                             ),            //input  [7:0]          start_cmp_position           ,
     .start_cmp_position_en   (         1'b0                            ), // (         'd0                             ),            //input                 start_cmp_position_en     
//     .PHASE_out_to_PCIE       (                        ),
//     .PHASE_out_to_PCIE_en    (                        ),
     .raw_phase_to_pcie_frequency1      (  raw_phase_to_pcie_frequency1        ),        
     .raw_phase_to_pcie_frequency1_valid(  raw_phase_to_pcie_frequency1_valid  ),                                     
//     .raw_phase_to_pcie_frequency2      (                                 ),        
//     .raw_phase_to_pcie_frequency2_valid(                                 ),                                      
//     .raw_phase_to_pcie_frequency3      (                                 ),        
//     .raw_phase_to_pcie_frequency3_valid(                                 ),   
     .ref_frequency     ( ref_frequency                         ), 
     .mea_frequency ( measure_frequency                     ) ,
     .select_dat_update(  select_dat_update                    ),
     .     feedback_data(   feedback_data)
    );
    
    
    pulse_count#(
      .COUNT_WIDTH(8    ) ,
      .count_data (256  )
    )
    pulse_count_0(
     .  clk         (      DCOA               ) ,
     .  rst_n       (   trig_rst_n           ) ,
     .  pulse       ( ADC_data_in_A_channel_en) ,
     .  count_equal (    count_equal          )
    
    );
   
    
    wire  alg_rst_trig_cdc;
    
    
    rst_gen rst_gen_0(
       . clk      (  alg_clk         ) ,
       . rst_n    (      1'b1        ) ,
       . rst_trig (alg_rst_trig_cdc  ) ,
       . rst_n_out( trig_rst_n       )
      );
    
      cross_clock_domain#(
                  .data_width(5'd1)
                )
               cross_clock_domain_1 (
              .clk1         (     DCOA            ),                                               //input                          clk1,
              .clk2         (      alg_clk        ),                                               //input                          clk2,
              .rst_n        (      1'b1           ),                                              //input                          rst_n,
              .data_in      ( alg_rst_trig        ),                                            //input [data_width-1'b1:0]      data_in,              //clk1
              .data_in_en   (  alg_rst_trig       ),                                         //input                          data_in_en,           //clk1
              .data_in_ready(                     ),           //output reg                     data_in_ready     =1,//clk1
              .data_out     (                     ),           //output reg [data_width-1'b1:0] data_out          =0,
              .data_out_en  ( alg_rst_trig_cdc    )            //output reg                     data_out_en         =0
                   );
    
    
    
    
    
    
    
endmodule
