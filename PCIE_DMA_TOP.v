`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/16 21:17:15
// Design Name: 
// Module Name: PCIE_DMA_TOP
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


module PCIE_DMA_TOP#
  (
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
   parameter Bram_data_width     = 128,
   parameter Trig_mode           ="Internal"// external or internal
   )
   ( 
     output [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0] pci_exp_txp,
     output [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0] pci_exp_txn,
     input [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0]  pci_exp_rxp,
     input [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0]  pci_exp_rxn,

     input 					 sys_clk_p,
     input 					 sys_clk_n,
     input 					 sys_rst_n  ,  
  
     input                  sample_clk  ,
     input      [127:0]            sample_data ,
     input                  sample_data_valid ,
     input                   over_flow,
  
     (*mark_debug = "true"*)output                  start_sample,
     (*mark_debug = "true"*)output                  stop_sample ,
   input     adc_clk,
   
      output   test_mode,
      
      output         adc_ch1_en,
      output         adc_ch2_en,
      output         alg_en,
      output  [31:0] sample_rate_cfg_clk_adc,
      
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
        input resetn_0 ,
  //   output                 fan
         output [0:0]  ddr3_ui_rst_n  ,
         output        ddr3_user_clk  ,
         input [31:0]  rd_addr_0      ,
         output [127:0]rd_data_0      ,
         output        rd_data_end_0  ,
         output        rd_data_valid_0,
         input [19:0]  rd_len_0       ,
         output        rd_ready_0     ,
         input         rd_valid_0     ,
         input [31:0]  wr_addr_0      ,
          input [127:0]wr_data_0      ,
          output       wr_data_end_0  ,
          output       wr_data_req_0  ,
          input [19:0] wr_len_0       ,
          output       wr_ready_0     ,
          input        wr_valid_0    ,
      (*mark_debug = "true"*)    input       tirg_to_pcie   ,
      
      output           bram_clk_out,
      output           back_board_dir,
      
      (*mark_debug = "true"*)output   [1:0]   frequency_mode,
      (*mark_debug = "true"*)output  [31:0]   select_dat_update,
      (*mark_debug = "true"*)output           phase_invert,
      
     (*mark_debug = "true"*)input   [23:0]   ref_frequency,
     (*mark_debug = "true"*)input   [23:0]   measure_frequency  
      
	);
	wire   sample_rate_cfg;
    wire  [63:0] MM_2_S_data_0;
    wire   axi_aclk;
    wire   MM_2_S_ready;
    reg    MM_2_S_valid;
    
    wire        sys_rst_n_c;
    wire        sample_ready;
    (*mark_debug = "true"*)     reg         sample_valid;
  //  reg [127:0] sample_data=0; 	
    
        wire [13:0]  bram_addr_a ;      
 wire         bram_clk_a ;       
        wire [31:0]  bram_wr_data_a  ;  
 
      wire        bram_en_a   ;      
      wire        bram_rst_a ;       
      wire [3:0]  bram_we_a ;        
    (*mark_debug = "true"*) wire        start_sample_0;    
    
     //(*mark_debug = "true"*)    wire  start_sample;
   
     (*mark_debug = "true"*)    reg   sample;
    
   
  assign  bram_clk_out=bram_clk_a;
    
    
     IBUF #(
            .IBUF_LOW_PWR("TRUE"),  // Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards 
            .IOSTANDARD("DEFAULT")  // Specify the input I/O standard
         ) IBUF_inst (
            .O(sys_rst_n_c),     // Buffer output
            .I(sys_rst_n)      // Buffer input (connect directly to top-level port)
         );
    wire start_sample_pcie;
    wire start_sample_axi;
    wire ex_trig_cdc;
    generate 
      if(Trig_mode=="Internal")
  //   assign  start_sample=start_sample_axi||start_sample_pcie; 
  //
  // assign  start_sample=ex_trig_cdc||start_sample_pcie; 
   assign  start_sample= start_sample_pcie; 
    else 
      assign  start_sample=start_sample_pcie;
   endgenerate
  // assign  start_sample=(Trig_mode=="Internal")?start_sample_axi:start_sample_pcie;
   always@(posedge adc_clk or negedge sys_rst_n_c)
      if(!sys_rst_n_c)
     sample<=1'b0;
    else  if(start_sample)
     sample<=1'b1;
    else  if(stop_sample)
     sample<=1'b0;
   
   reg  sample_r;
    always@(posedge adc_clk )
    sample_r<=sample;
   wire sample_nege;
    assign sample_nege=(!sample)&&sample_r;
   
 //  (*mark_debug = "true"*)  reg  [7:0] clear_cnt=8'b0;
 // 
 //  always@(posedge axi_aclk or negedge sys_rst_n_c)
 //   if(!sys_rst_n_c) 
 //  clear_cnt<=8'b0;
 //  else if(clear_cnt[7])
 //    clear_cnt<=8'b0;
 //  else if(!sample)
 //  clear_cnt<=clear_cnt+1'b1;
 //  (*mark_debug = "true"*)   reg  [31:0]  delay_cnt=32'd0;
 //   always@(posedge axi_aclk or negedge sys_rst_n_c)
 //    if(!sys_rst_n_c)
 //   delay_cnt<=32'd0;
 //  else if((sample_ready&&sample_valid)||(clear_cnt[7])||(delay_cnt==32'd10-1))
 //   //else if(sample_ready&&sample_valid)
 //   delay_cnt<=32'd0;
 //   else  if(sample)
 //    delay_cnt<=delay_cnt+1'b1;
 //  else 
 //    delay_cnt<=delay_cnt;   
 //    
 //   always@(posedge axi_aclk or negedge sys_rst_n_c)
 //       if(!sys_rst_n_c)
 //        sample_valid<=1'b0;
 //    else if((delay_cnt==32'd10-1)&&sample_ready&&sample)
 //        sample_valid<=1'b1;
 //    else 
 //        sample_valid<=1'b0;
    
  //  always@(posedge axi_aclk or negedge sys_rst_n_c)
  //     if(!sys_rst_n_c)
  //  
  //  sample_data<=128'b0;
  //  else if(sample_ready&&sample_valid)
  //   sample_data<=sample_data+1'b1;
    
    
    
    
    
    
    always@(posedge axi_aclk )
    
    MM_2_S_valid<=MM_2_S_ready;
    
    
    reg  [31:0]  delay_time=32'd0;
    
    reg  [31:0]  slv_reg_1;
    
    reg  [31:0]  slv_reg_2;
    
    reg  [31:0]  slv_reg_3; 
    
    reg  [31:0]  slv_reg_4; 
    
    reg  [31:0]  slv_reg_5; 
    
    reg  [31:0]  slv_reg_6; 
    
    reg  [31:0]  slv_reg_7;  
    
    reg  [31:0]  slv_reg_8; 
    
    reg  [31:0]  slv_reg_9; 
    
    reg  [31:0]  slv_reg_10=32'h7D0; 
    
    reg  [31:0]  slv_reg_11; 
    
    wire [31:0]  bram_wr_data_a_1;
  
   genvar i;
        generate
            for(i = 0; i < 4; i = i + 1) begin
                assign bram_wr_data_a_1[(i*8+7) -: 8] =(bram_we_a[i])?bram_wr_data_a[(i*8+7) -: 8]:8'b0 ;
            end
            
        endgenerate
  
    
   always@(posedge bram_clk_a  or negedge sys_rst_n_c) 
      if(!sys_rst_n_c)
      begin
    delay_time<=32'd10;     
     //slv_reg_1[1] start_sample ,slv_reg_1[0]stop_sample                     
    slv_reg_1<=32'd0;             
    // increase data mode                       
    slv_reg_2<=32'd0;             
    //external trig                      
    slv_reg_3<=32'd0;           
    //filter window width                     
    slv_reg_4<=32'd0;           
    //sample rate                     
    slv_reg_5<=32'd0;           
    //[0]channel 1 enalbe  [1]channel 2 enable   [2] channel 3 enable 。。。。。               
    slv_reg_6<=32'd0;           
                         
    slv_reg_7<=32'd0;           
                         
    slv_reg_8<=32'd0;           
       //three frequency                   
    slv_reg_9<=32'd0;           
    
    slv_reg_10<=32'h7D0; 
    
    slv_reg_11<=32'd0; 
    end
    else if(tirg_to_pcie )
    slv_reg_3<=32'd1;     
    
    else if(bram_en_a&&(&bram_we_a))
    begin 
    case(bram_addr_a)
    13'd0:
    delay_time<=bram_wr_data_a_1;
    13'd4:
    slv_reg_1<=bram_wr_data_a_1;
    13'd8:
    slv_reg_2<=bram_wr_data_a_1;
    13'd12:
    slv_reg_3<=bram_wr_data_a_1; 
    13'd16:
    slv_reg_4<=bram_wr_data_a_1;
    13'd20: 
    slv_reg_5<=bram_wr_data_a_1;
    13'd24:
    slv_reg_6<=bram_wr_data_a_1; 
    13'd28:
    slv_reg_7<=bram_wr_data_a_1;
    13'd32:
    slv_reg_8<=bram_wr_data_a_1; 
    13'd36: 
    slv_reg_9<=bram_wr_data_a_1;
     13'd40: 
     slv_reg_10<=bram_wr_data_a_1;
    
     13'd44: 
    slv_reg_11<=bram_wr_data_a_1;
     
  
    
    
    default:;
    endcase
    
    end
    
       reg [31:0] BRAM_DATA_OUT;
    assign test_mode      =slv_reg_2[0];
    assign sample_rate_cfg=slv_reg_5;
    assign adc_ch1_en     =slv_reg_6[0];
    assign adc_ch2_en     =slv_reg_6[1];
    assign alg_en         =slv_reg_6[2];
   // assign  start_sample_pcie=slv_reg_1[0];
    
   assign  back_board_dir =slv_reg_7[0];
    
          
    assign   frequency_mode=slv_reg_9[1:0];
    
    assign  select_dat_update=slv_reg_10;
    
     assign   phase_invert =slv_reg_11;
     
    always@(posedge bram_clk_a  or negedge sys_rst_n_c) 
        if(!sys_rst_n_c)  
    BRAM_DATA_OUT<=32'd0;
    else if(bram_en_a&&(~(|bram_we_a)))
    begin
    
     case(bram_addr_a)
       13'd0:
       BRAM_DATA_OUT<={delay_time[31:1],over_flow};
       13'd4:
       BRAM_DATA_OUT<=slv_reg_1;
       13'd8:
       BRAM_DATA_OUT<=slv_reg_2;
       13'd12:
       BRAM_DATA_OUT<=slv_reg_3; 
       13'd16:
       BRAM_DATA_OUT<=slv_reg_4;
       13'd20: 
       BRAM_DATA_OUT<=slv_reg_5;
       13'd24:
       BRAM_DATA_OUT<=slv_reg_6; 
       13'd28:
       BRAM_DATA_OUT<=slv_reg_7;
       13'd32:
       BRAM_DATA_OUT<=slv_reg_8; 
       13'd36: 
       BRAM_DATA_OUT<=slv_reg_9;
        13'd40: 
       BRAM_DATA_OUT<=slv_reg_10;
         13'd44: 
       BRAM_DATA_OUT<=slv_reg_11 ;
        13'd48: 
       BRAM_DATA_OUT<={8'b0,ref_frequency};  
         13'd52:     
        BRAM_DATA_OUT<={8'b0,measure_frequency};   
       
       
       
       
       default:BRAM_DATA_OUT<=BRAM_DATA_OUT;
       endcase
       
       end
    
  
     reg  sample_stop_sig_r;
   
      always@(posedge bram_clk_a )
    if(!sys_rst_n_c)  
    sample_stop_sig_r<=1'b0;
    else
    sample_stop_sig_r<=slv_reg_1[0];
    
    wire  sample_stop_posedge;
   assign sample_stop_posedge=slv_reg_1[0]&&(!sample_stop_sig_r);
    
      reg  sample_start_pcie_reg;
   
      always@(posedge bram_clk_a )
    if(!sys_rst_n_c)  
    sample_start_pcie_reg<=1'b0;
    else
    sample_start_pcie_reg<=slv_reg_1[1];
    
    wire   start_sample_pcie_reg_posedge;
   assign start_sample_pcie_reg_posedge=slv_reg_1[1]&&(!sample_start_pcie_reg); 
    
    
     reg   ex_trig_r;
    wire   ex_trig_before_cdc;
    assign ex_trig_before_cdc=slv_reg_3[0]&&(!ex_trig_r);
    always@(posedge bram_clk_a )
    begin
    ex_trig_r<=slv_reg_3[0];
    
    
    end
    
    
    
    
    reg fifo_rst_0=1'b0;
     always@(posedge adc_clk  or negedge sys_rst_n_c) 
        if(!sys_rst_n_c)  
        fifo_rst_0<=1'b0;
        else if(sample_nege )
         fifo_rst_0<=1'b1;
        else 
         fifo_rst_0<=1'b0;
    
     cross_clock_domain#(
        .data_width(5'd1)
      )
     cross_clock_domain_0 (
    .clk1         (     axi_aclk            ),                                               //input                          clk1,
    .clk2         (      adc_clk            ),                                               //input                          clk2,
    .rst_n        (      1'b1                    ),                                              //input                          rst_n,
    .data_in      ( start_sample_0           ),                                            //input [data_width-1'b1:0]      data_in,              //clk1
    .data_in_en   (  start_sample_0           ),                                         //input                          data_in_en,           //clk1
    .data_in_ready(                          ),           //output reg                     data_in_ready     =1,//clk1
    .data_out     (             ),           //output reg [data_width-1'b1:0] data_out          =0,
    .data_out_en  (  start_sample_axi    )            //output reg                     data_out_en         =0
         );
    
       cross_clock_domain#(
              .data_width(5'd1)
            )
           cross_clock_domain_1 (
          .clk1         (     bram_clk_a            ),                                               //input                          clk1,
          .clk2         (      adc_clk            ),                                               //input                          clk2,
          .rst_n        (      1'b1                 ),                                              //input                          rst_n,
          .data_in      ( sample_stop_posedge      ),                                            //input [data_width-1'b1:0]      data_in,              //clk1
          .data_in_en   (  sample_stop_posedge     ),                                         //input                          data_in_en,           //clk1
          .data_in_ready(                          ),           //output reg                     data_in_ready     =1,//clk1
          .data_out     (              ),           //output reg [data_width-1'b1:0] data_out          =0,
          .data_out_en  (   stop_sample           )            //output reg                     data_out_en         =0
               );
    
      cross_clock_domain#(
                           .data_width(5'd1)
                         )
                        cross_clock_domain_2 (
                       .clk1         (     bram_clk_a            ),                                               //input                          clk1,
                       .clk2         (      adc_clk            ),                                               //input                          clk2,
                       .rst_n        (      1'b1                 ),                                              //input                          rst_n,
                       .data_in      ( start_sample_pcie_reg_posedge     ),                                            //input [data_width-1'b1:0]      data_in,              //clk1
                       .data_in_en   ( start_sample_pcie_reg_posedge     ),                                         //input                          data_in_en,           //clk1
                       .data_in_ready(                          ),           //output reg                     data_in_ready     =1,//clk1
                       .data_out     (              ),           //output reg [data_width-1'b1:0] data_out          =0,
                       .data_out_en  (   start_sample_pcie           )            //output reg                     data_out_en         =0
                            );
    
     cross_clock_domain#(
            .data_width(8'd32)
          )
         cross_clock_domain_3 (
        .clk1         (     bram_clk_a            ),                                               //input                          clk1,
        .clk2         (      adc_clk            ),                                               //input                          clk2,
        .rst_n        (      1'b1                 ),                                              //input                          rst_n,
        .data_in      ( sample_rate_cfg     ),                                            //input [data_width-1'b1:0]      data_in,              //clk1
        .data_in_en   (      1'b1                 ),                                         //input                          data_in_en,           //clk1
        .data_in_ready(                          ),           //output reg                     data_in_ready     =1,//clk1
        .data_out     (              ),           //output reg [data_width-1'b1:0] data_out          =0,
        .data_out_en  ( sample_rate_cfg_clk_adc  )            //output reg                     data_out_en         =0
             );
    
      cross_clock_domain#(
                       .data_width(8'd32)
                     )
                    cross_clock_domain_4 (
                   .clk1         (     bram_clk_a            ),                                               //input                          clk1,
                   .clk2         (      adc_clk            ),                                               //input                          clk2,
                   .rst_n        (      1'b1                 ),                                              //input                          rst_n,
                   .data_in      (  ex_trig_before_cdc  ),                                            //input [data_width-1'b1:0]      data_in,              //clk1
                   .data_in_en   (  ex_trig_before_cdc        ),                                         //input                          data_in_en,           //clk1
                   .data_in_ready(                          ),           //output reg                     data_in_ready     =1,//clk1
                   .data_out     (              ),           //output reg [data_width-1'b1:0] data_out          =0,
                   .data_out_en  ( ex_trig_cdc  )            //output reg                     data_out_en         =0
                        );
    
    
    
   
    
    
    
    
    
    design_1_wrapper design_1_wrapper_0
       (
       .CLK_IN_D_0_clk_n     (  sys_clk_n                             ),
       .CLK_IN_D_0_clk_p     (  sys_clk_p                        ),
       . CLK_IN1_D_0_clk_n   (  CLK_IN1_D_0_clk_n             ),
       . CLK_IN1_D_0_clk_p   (  CLK_IN1_D_0_clk_p             ),
       
       
       .MM_2_S_data_0        (  MM_2_S_data_0                         ),
       .MM_2_S_ready_0       (  MM_2_S_ready                       ),
       .MM_2_S_valid_0       (  MM_2_S_valid                         ),
       .axi_aclk             ( axi_aclk                           ),
       .config_data_0        (     32'b0                             ),
     //  .config_ready_0       (                                        ),
       .config_valid_0       (           1'b0                         ),
   //    .data_in_0            (                                        ),
       .fan                  ( fan                                    ),
   //    .fifo_MM_2_S_empty_0  (                                        ),
   //    .fifo_rd_sel_0        (                                        ),
   //    .mem_wren_0           (                                        ),
       .pcie_7x_mgt_rtl_0_rxn(  pci_exp_rxn                           ),
       .pcie_7x_mgt_rtl_0_rxp(  pci_exp_rxp                            ),
       .pcie_7x_mgt_rtl_0_txn(  pci_exp_txn                           ),
       .pcie_7x_mgt_rtl_0_txp(  pci_exp_txp                           ),
       .sample_clk_0         (   sample_clk                     ),
       .sample_data        (   sample_data                     ),
       .sample_ready_0       (  sample_ready                    ),
       .sample_valid_0       (   sample_data_valid             ),
       .sys_rst_n_0          (     sys_rst_n_c                ),
       . BRAM_PORTA_0_addr  ( bram_addr_a                      )    ,// output [12:0] 
       .BRAM_PORTA_0_clk  ( bram_clk_a                       )    ,// output        
       .BRAM_PORTA_0_din  ( bram_wr_data_a                   )    ,// output [31:0] 
       .BRAM_PORTA_0_dout  (BRAM_DATA_OUT                  )    ,// input  [31:0] 
       .BRAM_PORTA_0_en  ( bram_en_a                        )     ,// output        
       .BRAM_PORTA_0_rst  ( bram_rst_a                       )     ,// output        
       .BRAM_PORTA_0_we  ( bram_we_a                        ),       // output [3:0]     
      . start_sample_0   (start_sample_0                   ),
      . fifo_rst_0       (  fifo_rst_0                     ),
      .DDR3_0_addr       (  DDR3_0_addr         ) ,
      .DDR3_0_ba         (  DDR3_0_ba           ) ,
      .DDR3_0_cas_n      (  DDR3_0_cas_n        ) ,
      .DDR3_0_ck_n       (  DDR3_0_ck_n         ) ,
      .DDR3_0_ck_p       (  DDR3_0_ck_p         ) ,
      .DDR3_0_cke        (  DDR3_0_cke          ) ,
      .DDR3_0_cs_n       (  DDR3_0_cs_n         ) ,
      .DDR3_0_dm         (  DDR3_0_dm           ) ,
      .DDR3_0_dq         (  DDR3_0_dq           ) ,
      .DDR3_0_dqs_n      (  DDR3_0_dqs_n        ) ,
      .DDR3_0_dqs_p      (  DDR3_0_dqs_p        ) ,
      .DDR3_0_odt        (  DDR3_0_odt          ) ,
      .DDR3_0_ras_n      (  DDR3_0_ras_n        ) ,
      .DDR3_0_reset_n    (  DDR3_0_reset_n      ) , 
      .DDR3_0_we_n       (  DDR3_0_we_n         ) ,
       . resetn_0( resetn_0    ),
       .ddr3_ui_rst_n   (ddr3_ui_rst_n                  ),
       .ddr3_user_clk   (ddr3_user_clk                  ),
       .rd_addr_0       (rd_addr_0                      ),
       .rd_data_0       (rd_data_0                      ),
       .rd_data_end_0   (rd_data_end_0                  ),
       .rd_data_valid_0 (rd_data_valid_0                ),
       .rd_len_0        (rd_len_0                       ),
       .rd_ready_0      (rd_ready_0                     ),
       .rd_valid_0      (rd_valid_0                     ),
       .wr_addr_0       (wr_addr_0                      ),
       .wr_data_0       (wr_data_0                      ),
       .wr_data_end_0   (wr_data_end_0                  ),
       .wr_data_req_0   (wr_data_req_0                  ),
       .wr_len_0        (wr_len_0                       ),
       .wr_ready_0      (wr_ready_0                     ),
       .wr_valid_0      (wr_valid_0                     ) 
     
        );
    
    
endmodule
