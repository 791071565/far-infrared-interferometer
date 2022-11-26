`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/31 13:19:19
// Design Name: 
// Module Name: narrow_band_filter_top
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


module narrow_band_filter_top(
input          rst_n  ,
input          clk    ,
input [31:0]   ffted_data_CHA_RE  ,
input [31:0]   ffted_data_CHA_IM  ,
input          ffted_data_CHA_en  , 
input          ffted_data_CHA_last,  
input [31:0]   ffted_data_CHB_RE  ,  //reference channel
input [31:0]   ffted_data_CHB_IM  ,  //reference channel
input          ffted_data_CHB_en  ,  //reference channel
input          ffted_data_CHB_last,  //reference channel
input          PCIE_dma_engine_clk,


input  [7:0]          narrow_band_width           ,
input                 narrow_band_width_en        ,  
input  [1:0]          filter_mode                 ,
input                 filter_mode_en              ,  
input  [7:0]          start_cmp_position           ,
input                 start_cmp_position_en        ,



(*mark_debug = "true"*)output    wire          CHA_RE_IM_DATA_valid_f1,
(*mark_debug = "true"*)output    wire  [63:0]  CHA_RE_IM_DATA_filtered_f1, 
(*mark_debug = "true"*)output    wire          CHA_RE_IM_DATA_last_f1  , 

(*mark_debug = "true"*)output    wire          CHB_RE_IM_DATA_valid_f1,
(*mark_debug = "true"*)output    wire  [63:0]  CHB_RE_IM_DATA_filtered_f1,
(*mark_debug = "true"*)output    wire          CHB_RE_IM_DATA_last_f1  , 



(*mark_debug = "true"*)output    wire  [63:0]  CHA_RE_IM_DATA_filtered_f2, 
(*mark_debug = "true"*)output    wire          CHA_RE_IM_DATA_valid_f2 ,
(*mark_debug = "true"*)output    wire          CHA_RE_IM_DATA_last_f2 ,

(*mark_debug = "true"*)output    wire  [63:0]  CHB_RE_IM_DATA_filtered_f2,
(*mark_debug = "true"*)output    wire          CHB_RE_IM_DATA_last_f2 ,
(*mark_debug = "true"*)output    wire          CHB_RE_IM_DATA_valid_f2 ,



(*mark_debug = "true"*)output    wire          CHA_RE_IM_DATA_valid_f3,
(*mark_debug = "true"*)output    wire  [63:0]  CHA_RE_IM_DATA_filtered_f3, 
(*mark_debug = "true"*)output    wire          CHA_RE_IM_DATA_last_f3  , 

(*mark_debug = "true"*)output    wire          CHB_RE_IM_DATA_valid_f3,
(*mark_debug = "true"*)output    wire  [63:0]  CHB_RE_IM_DATA_filtered_f3,
(*mark_debug = "true"*)output    wire          CHB_RE_IM_DATA_last_f3 ,

 
(*mark_debug = "true"*)output  [23:0]         mea_frequency,
 
(*mark_debug = "true"*)output  [23:0]          ref_frequency 
 
 
);








(*mark_debug = "true"*)wire  [31:0] floating_IM_square_add_RE_suqare         ;
(*mark_debug = "true"*)wire         floating_IM_square_add_RE_suqare_en      ;
(*mark_debug = "true"*)wire         floating_IM_square_add_RE_suqare_last    ;

(*mark_debug = "true"*)wire  [31:0] floating_IM_square_add_RE_suqare_1         ;
(*mark_debug = "true"*)wire         floating_IM_square_add_RE_suqare_en_1      ;
(*mark_debug = "true"*)wire         floating_IM_square_add_RE_suqare_last_1    ;






wire [31:0] floating_IM_square_add_RE_suqare_selected           ;
wire        floating_IM_square_add_RE_suqare_selected_en            ;
wire [7:0]  floating_IM_square_add_RE_suqare_selected_position   ;
wire [31:0] floating_IM_square_add_RE_suqare_o_r                ;
wire        floating_IM_square_add_RE_suqare_en_o_r                 ;
wire [7:0]  floating_IM_square_add_RE_suqare_o_position_r      ;
wire [31:0] floating_IM_square_add_RE_suqare_o_rr             ;
wire        floating_IM_square_add_RE_suqare_en_o_rr                ;
wire [7:0]  floating_IM_square_add_RE_suqare_o_position_rr     ;
wire        floating_IM_square_add_RE_suqare_last_r                 ;
                                                      

wire [31:0] floating_IM_square_add_RE_suqare_selected_1           ;
wire        floating_IM_square_add_RE_suqare_selected_en_1            ;
wire [7:0]  floating_IM_square_add_RE_suqare_selected_position_1   ;
wire [31:0] floating_IM_square_add_RE_suqare_o_r_1                ;
wire        floating_IM_square_add_RE_suqare_en_o_r_1                 ;
wire [7:0]  floating_IM_square_add_RE_suqare_o_position_r_1      ;
wire [31:0] floating_IM_square_add_RE_suqare_o_rr_1             ;
wire        floating_IM_square_add_RE_suqare_en_o_rr_1                ;
wire [7:0]  floating_IM_square_add_RE_suqare_o_position_rr_1     ;
wire        floating_IM_square_add_RE_suqare_last_r_1                 ;













(*mark_debug = "true"*)wire   [7:0] start_position_1       ; 
(*mark_debug = "true"*)wire   [7:0] end_position_1         ;
 wire         position_1_error_sig 	;												  
(*mark_debug = "true"*)wire   [7:0] start_position_2     	;												  
(*mark_debug = "true"*)wire   [7:0] end_position_2       	;												  
 wire         position_2_error_sig 	;												  
(*mark_debug = "true"*)wire   [7:0] start_position_3     	;												  
 wire   [7:0] end_position_3       	;												  
wire         position_3_error_sig 	;												  
(*mark_debug = "true"*)wire         position_gen_en 		;											  
													  

wire         select_ram_out_1   ;
wire         select_ram_out_1_en;
wire         select_ram_out_2   ;													  
wire         select_ram_out_2_en;													  
wire         select_ram_out_3   ;													  
wire         select_ram_out_3_en;	



wire   [7:0]  rd_addr;
			

wire [7:0] narrow_band_width_o ;
wire [1:0] filter_mode_o       ;
wire [7:0] start_cmp_position_o;
			
		
wire       CHA_RE_IM_DATA_valid	;	
wire [63:0] CHA_RE_IM_DATA      	;	
wire       CHA_RE_IM_DATA_last 	;	
wire       CHB_RE_IM_DATA_valid	;	
wire [63:0] CHB_RE_IM_DATA      	;	
wire       CHB_RE_IM_DATA_last 	;	
		
(*mark_debug = "true"*)wire  [7:0]  max_position_1_cmp_r ;
(*mark_debug = "true"*)wire  [7:0]  max_position_2_cmp_r ;
(*mark_debug = "true"*)wire  [7:0]  max_position_3_cmp_r ;	
		
		
//reference channel
floating_multipler_adder floating_multipler_adder_0(
  .rst_n                                ( rst_n                             ), // input          rst_n                                     ,// async reset_all
  .clk                                  ( clk                               ), // input          clk                                       ,  //                                                       
  .floating_data_RE                     ( ffted_data_CHB_RE                 ), // input [31:0]   floating_data_RE                         ,
  .floating_data_IM                     ( ffted_data_CHB_IM                 ), // input [31:0]   floating_data_IM                         ,
  .floating_data_en                     ( ffted_data_CHB_en                 ), // input          floating_data_en                         , 
  .floating_data_last                   ( ffted_data_CHB_last               ), // input          floating_data_last                       ,
  .floating_IM_square_add_RE_suqare     (floating_IM_square_add_RE_suqare      ), // output  [31:0] floating_IM_square_add_RE_suqare         ,
  .floating_IM_square_add_RE_suqare_en  (floating_IM_square_add_RE_suqare_en   ), // output         floating_IM_square_add_RE_suqare_en      ,
  .floating_IM_square_add_RE_suqare_last(floating_IM_square_add_RE_suqare_last )  // output         floating_IM_square_add_RE_suqare_last  
  );


//reference channel
floating_multipler_adder floating_multipler_adder_1(
  .rst_n                                ( rst_n                             ), // input          rst_n                                     ,// async reset_all
  .clk                                  ( clk                               ), // input          clk                                       ,  //                                                       
  .floating_data_RE                     ( ffted_data_CHA_RE                 ), // input [31:0]   floating_data_RE                         ,
  .floating_data_IM                     ( ffted_data_CHA_IM                 ), // input [31:0]   floating_data_IM                         ,
  .floating_data_en                     ( ffted_data_CHA_en                 ), // input          floating_data_en                         , 
  .floating_data_last                   ( ffted_data_CHA_last               ), // input          floating_data_last                       ,
  .floating_IM_square_add_RE_suqare     (floating_IM_square_add_RE_suqare_1       ), // output  [31:0] floating_IM_square_add_RE_suqare         ,
  .floating_IM_square_add_RE_suqare_en  (floating_IM_square_add_RE_suqare_en_1    ), // output         floating_IM_square_add_RE_suqare_en      ,
  .floating_IM_square_add_RE_suqare_last(floating_IM_square_add_RE_suqare_last_1  )  // output         floating_IM_square_add_RE_suqare_last  
  );


// //reference channel
// floating_multipler_adder floating_multipler_adder_0(
//   .rst_n                                ( rst_n                             ), // input          rst_n                                     ,// async reset_all
//   .clk                                  ( clk                               ), // input          clk                                       ,  //                                                       
//   .floating_data_RE                     ( ffted_data_CHB_RE                 ), // input [31:0]   floating_data_RE                         ,
//   .floating_data_IM                     ( ffted_data_CHB_IM                 ), // input [31:0]   floating_data_IM                         ,
//   .floating_data_en                     ( ffted_data_CHB_en                 ), // input          floating_data_en                         , 
//   .floating_data_last                   ( ffted_data_CHB_last               ), // input          floating_data_last                       ,
//   .floating_IM_square_add_RE_suqare     (floating_IM_square_add_RE_suqare_1      ), // output  [31:0] floating_IM_square_add_RE_suqare         ,
//   .floating_IM_square_add_RE_suqare_en  (floating_IM_square_add_RE_suqare_en_1   ), // output         floating_IM_square_add_RE_suqare_en      ,
//   .floating_IM_square_add_RE_suqare_last(floating_IM_square_add_RE_suqare_last_1 )  // output         floating_IM_square_add_RE_suqare_last  
//   );
 
 
// //reference channel
// floating_multipler_adder floating_multipler_adder_1(
//   .rst_n                                ( rst_n                             ), // input          rst_n                                     ,// async reset_all
//   .clk                                  ( clk                               ), // input          clk                                       ,  //                                                       
//   .floating_data_RE                     ( ffted_data_CHA_RE                 ), // input [31:0]   floating_data_RE                         ,
//   .floating_data_IM                     ( ffted_data_CHA_IM                 ), // input [31:0]   floating_data_IM                         ,
//   .floating_data_en                     ( ffted_data_CHA_en                 ), // input          floating_data_en                         , 
//   .floating_data_last                   ( ffted_data_CHA_last               ), // input          floating_data_last                       ,
//   .floating_IM_square_add_RE_suqare     (floating_IM_square_add_RE_suqare        ), // output  [31:0] floating_IM_square_add_RE_suqare         ,
//   .floating_IM_square_add_RE_suqare_en  (floating_IM_square_add_RE_suqare_en     ), // output         floating_IM_square_add_RE_suqare_en      ,
//   .floating_IM_square_add_RE_suqare_last(floating_IM_square_add_RE_suqare_last  )  // output         floating_IM_square_add_RE_suqare_last  
//   );






















   wire rd_en;
 
raw_data_ping_pong raw_data_ping_pong_0(
      .rst_n                (   rst_n                             ) ,    //input         rst_n                       ,
      .clk                  ( clk                            ) ,    //input         clk                         ,
      .ffted_data_CHA_RE    ( ffted_data_CHA_RE              ) ,       //input [31:0]  ffted_data_CHA_RE           ,
      .ffted_data_CHA_IM    ( ffted_data_CHA_IM              ) ,       //input [31:0]  ffted_data_CHA_IM           ,
      .ffted_data_CHA_en    ( ffted_data_CHA_en              ) ,       //input         ffted_data_CHA_en           , 
      .ffted_data_CHA_last  ( ffted_data_CHA_last            ) ,       //input         ffted_data_CHA_last         ,              
      .ffted_data_CHB_RE    ( ffted_data_CHB_RE              ) ,       //input [31:0]  ffted_data_CHB_RE           ,
      .ffted_data_CHB_IM    ( ffted_data_CHB_IM              ) ,       //input [31:0]  ffted_data_CHB_IM           ,
      .ffted_data_CHB_en    ( ffted_data_CHB_en              ) ,       //input         ffted_data_CHB_en           , 
      .ffted_data_CHB_last  ( ffted_data_CHB_last            ) ,       //input         ffted_data_CHB_last         ,                                           
      .rd_en                (  rd_en                                    ) ,                          //input         rd_en,
	  .rd_addr              (  rd_addr                                  ),
      .CHA_RE_IM_DATA_valid (CHA_RE_IM_DATA_valid                      ) ,         //output   reg  CHA_RE_IM_DATA_valid=0, 
      .CHA_RE_IM_DATA       (CHA_RE_IM_DATA                            ) ,                 //output [63:0] CHA_RE_IM_DATA,
	  .CHA_RE_IM_DATA_last  (CHA_RE_IM_DATA_last                       ) ,
      .CHB_RE_IM_DATA_valid (CHB_RE_IM_DATA_valid                      ) ,         //output   reg  CHB_RE_IM_DATA_valid=0, 
      .CHB_RE_IM_DATA       (CHB_RE_IM_DATA                            ) ,                 //output [63:0] CHB_RE_IM_DATA,  
	  .CHB_RE_IM_DATA_last  (CHB_RE_IM_DATA_last                       ) ,  
      .rd_start_ready       (                                     )            //output        rd_start_ready    
       );



comparator_tree comparator_tree_0(
   .rst_n                                              (    rst_n                              ),  //input               rst_n                                                    ,
   .clk                                                (    clk                                ),  //input               clk                                                      ,
   .floating_IM_square_add_RE_suqare_selected          ( floating_IM_square_add_RE_suqare_selected          ),  //input   [31:0]      floating_IM_square_add_RE_suqare_selected                ,
   .floating_IM_square_add_RE_suqare_selected_en       ( floating_IM_square_add_RE_suqare_selected_en       ),  //input               floating_IM_square_add_RE_suqare_selected_en             ,  
   .floating_IM_square_add_RE_suqare_selected_position ( floating_IM_square_add_RE_suqare_selected_position ),  //input    [7:0]      floating_IM_square_add_RE_suqare_selected_position       ,                     
   .floating_IM_square_add_RE_suqare_o_r               ( floating_IM_square_add_RE_suqare_o_r               ),  //input   [31:0]      floating_IM_square_add_RE_suqare_o_r                     ,
   .floating_IM_square_add_RE_suqare_en_o_r            ( floating_IM_square_add_RE_suqare_en_o_r            ),  //input               floating_IM_square_add_RE_suqare_en_o_r                  ,    
   .floating_IM_square_add_RE_suqare_o_position_r      ( floating_IM_square_add_RE_suqare_o_position_r      ),  //input   [7:0]       floating_IM_square_add_RE_suqare_o_position_r            ,                      
   .floating_IM_square_add_RE_suqare_o_rr              ( floating_IM_square_add_RE_suqare_o_rr              ),  //input  [31:0]       floating_IM_square_add_RE_suqare_o_rr                    ,
   .floating_IM_square_add_RE_suqare_en_o_rr           ( floating_IM_square_add_RE_suqare_en_o_rr           ),  //input               floating_IM_square_add_RE_suqare_en_o_rr                 ,
   .floating_IM_square_add_RE_suqare_o_position_rr     ( floating_IM_square_add_RE_suqare_o_position_rr     ),  //input   [7:0]       floating_IM_square_add_RE_suqare_o_position_rr           , //='d128 position finish sig 
   .spectrum_cmp_finish_sig                            ( floating_IM_square_add_RE_suqare_last_r            ),  //input               spectrum_cmp_finish_sig                                  ,            
   .narrow_band_width_r                                (       (filter_mode[0])?8'd4:8'd10            ),  //input   [7:0]       narrow_band_width_r                                      ,
   .start_position_1                                   (   start_position_1                ),          //output  reg   [7:0] start_position_1                                         ,
   .end_position_1                                     (   end_position_1                  ),          //output  reg   [7:0] end_position_1                                           ,
   .position_1_error_sig                               (   position_1_error_sig                   ),          //output  reg         position_1_error_sig                                     ,  
   .start_position_2                                   (   start_position_2                     ),          //output  reg   [7:0] start_position_2                                         ,
   .end_position_2                                     (   end_position_2                       ),          //output  reg   [7:0] end_position_2                                           ,
   .position_2_error_sig                               (   position_2_error_sig                 ),          //output  reg         position_2_error_sig                                     , 
   .start_position_3                                   (   start_position_3                     ),          //output  reg   [7:0] start_position_3                                         ,
   .end_position_3                                     (   end_position_3                       ),          //output  reg   [7:0] end_position_3                                           ,     
   .position_3_error_sig                               (   position_3_error_sig                 ),          //output reg          position_3_error_sig                                     ,  
   .position_gen_en                                    (   position_gen_en                      ) ,          //output reg          position_gen_en 
   . max_position_1_cmp_r                              ( max_position_1_cmp_r                     ), 
   . max_position_2_cmp_r                              ( max_position_2_cmp_r                     ), 
   . max_position_3_cmp_r                              ( max_position_3_cmp_r                     )

  );
  
  
 (*mark_debug = "true"*) wire   [7:0] start_position_1_1       ; 
 (*mark_debug = "true"*) wire   [7:0] end_position_1_1         ;
  wire         position_1_error_sig_1     ;                                                  
 (*mark_debug = "true"*) wire   [7:0] start_position_2_1         ;                                                  
 (*mark_debug = "true"*) wire   [7:0] end_position_2_1           ;                                                  
  wire         position_2_error_sig_1     ;                                                  
 (*mark_debug = "true"*) wire   [7:0] start_position_3_1         ;                                                  
 (*mark_debug = "true"*) wire   [7:0] end_position_3_1           ;                                                  
  wire         position_3_error_sig_1     ;                                                  
  (*mark_debug = "true"*)wire         position_gen_en_1         ;    
(*mark_debug = "true"*) wire  [7:0]  max_position_1_cmp_r_1   ;
(*mark_debug = "true"*) wire  [7:0]  max_position_2_cmp_r_1   ;
(*mark_debug = "true"*) wire  [7:0]  max_position_3_cmp_r_1   ;
comparator_tree comparator_tree_1(
   .rst_n                                              (    rst_n                              ),  //input               rst_n                                                    ,
   .clk                                                (    clk                                ),  //input               clk                                                      ,
   .floating_IM_square_add_RE_suqare_selected          ( floating_IM_square_add_RE_suqare_selected_1          ),  //input   [31:0]      floating_IM_square_add_RE_suqare_selected                ,
   .floating_IM_square_add_RE_suqare_selected_en       ( floating_IM_square_add_RE_suqare_selected_en_1       ),  //input               floating_IM_square_add_RE_suqare_selected_en             ,  
   .floating_IM_square_add_RE_suqare_selected_position ( floating_IM_square_add_RE_suqare_selected_position_1 ),  //input    [7:0]      floating_IM_square_add_RE_suqare_selected_position       ,                     
   .floating_IM_square_add_RE_suqare_o_r               ( floating_IM_square_add_RE_suqare_o_r_1               ),  //input   [31:0]      floating_IM_square_add_RE_suqare_o_r                     ,
   .floating_IM_square_add_RE_suqare_en_o_r            ( floating_IM_square_add_RE_suqare_en_o_r_1            ),  //input               floating_IM_square_add_RE_suqare_en_o_r                  ,    
   .floating_IM_square_add_RE_suqare_o_position_r      ( floating_IM_square_add_RE_suqare_o_position_r_1      ),  //input   [7:0]       floating_IM_square_add_RE_suqare_o_position_r            ,                      
   .floating_IM_square_add_RE_suqare_o_rr              ( floating_IM_square_add_RE_suqare_o_rr_1              ),  //input  [31:0]       floating_IM_square_add_RE_suqare_o_rr                    ,
   .floating_IM_square_add_RE_suqare_en_o_rr           ( floating_IM_square_add_RE_suqare_en_o_rr_1           ),  //input               floating_IM_square_add_RE_suqare_en_o_rr                 ,
   .floating_IM_square_add_RE_suqare_o_position_rr     ( floating_IM_square_add_RE_suqare_o_position_rr_1     ),  //input   [7:0]       floating_IM_square_add_RE_suqare_o_position_rr           , //='d128 position finish sig 
   .spectrum_cmp_finish_sig                            ( floating_IM_square_add_RE_suqare_last_r_1            ),  //input               spectrum_cmp_finish_sig                                  ,            
   .narrow_band_width_r                                (       (filter_mode[0])?8'd3:8'd10            ),  //input   [7:0]       narrow_band_width_r                                      ,
   .start_position_1                                   (   start_position_1_1                ),          //output  reg   [7:0] start_position_1                                         ,
   .end_position_1                                     (   end_position_1_1                  ),          //output  reg   [7:0] end_position_1                                           ,
   .position_1_error_sig                               (   position_1_error_sig_1                   ),          //output  reg         position_1_error_sig                                     ,  
   .start_position_2                                   (   start_position_2_1                     ),          //output  reg   [7:0] start_position_2                                         ,
   .end_position_2                                     (   end_position_2_1                       ),          //output  reg   [7:0] end_position_2                                           ,
   .position_2_error_sig                               (   position_2_error_sig_1                ),          //output  reg         position_2_error_sig                                     , 
   .start_position_3                                   (   start_position_3_1                     ),          //output  reg   [7:0] start_position_3                                         ,
   .end_position_3                                     (   end_position_3_1                       ),          //output  reg   [7:0] end_position_3                                           ,     
   .position_3_error_sig                               (   position_3_error_sig_1                 ),          //output reg          position_3_error_sig                                     ,  
   .position_gen_en                                    (   position_gen_en_1                      ) ,          //output reg          position_gen_en 
   . max_position_1_cmp_r                              ( max_position_1_cmp_r_1                     ), 
   . max_position_2_cmp_r                              ( max_position_2_cmp_r_1                     ), 
   . max_position_3_cmp_r                              ( max_position_3_cmp_r_1                     ) 
   
   
   
   

  );


 position_reorder position_reorder_1(
 .start_position_1        ( start_position_1_1    ) ,
 .end_position_1          ( end_position_1_1      ) ,
 .start_position_2        ( start_position_2_1    ) ,
 .end_position_2          ( end_position_2_1      ) ,
 .start_position_3        ( start_position_3_1    ) ,
 .end_position_3          ( end_position_3_1      ) ,     
 .max_position_1_cmp_r    ( max_position_1_cmp_r_1   ) ,
 .max_position_2_cmp_r    ( max_position_2_cmp_r_1   ) ,
 .max_position_3_cmp_r    ( max_position_3_cmp_r_1   ) ,
 .frequency_mode         (filter_mode[0]), 
 .start_position_1_o      (   ),
 .end_position_1_o        (   ),
 .start_position_2_o      (   ),
 .end_position_2_o        (   ),
 .start_position_3_o      (   ),
 .end_position_3_o        (   ) ,
 .max_position_1_cmp_reorder(mea_frequency [23:16]             ),
 .max_position_2_cmp_reorder(mea_frequency  [15:8]             ),
 .max_position_3_cmp_reorder(mea_frequency [7:0]      ) 
 
 
  
 
); 
















(*mark_debug = "true"*)wire  [7:0]   start_position_1_reorder; 
(*mark_debug = "true"*)wire  [7:0]   end_position_1_reorder  ; 
(*mark_debug = "true"*)wire  [7:0]   start_position_2_reorder; 
(*mark_debug = "true"*)wire  [7:0]   end_position_2_reorder  ; 
(*mark_debug = "true"*)wire  [7:0]   start_position_3_reorder; 
(*mark_debug = "true"*)wire  [7:0]   end_position_3_reorder  ; 



 position_reorder position_reorder_0(
 .start_position_1        ( start_position_1    ) ,
 .end_position_1          ( end_position_1      ) ,
 .start_position_2        ( start_position_2    ) ,
 .end_position_2          ( end_position_2      ) ,
 .start_position_3        ( start_position_3    ) ,
 .end_position_3          ( end_position_3      ) ,     
 .max_position_1_cmp_r    ( max_position_1_cmp_r   ) ,
 .max_position_2_cmp_r    ( max_position_2_cmp_r   ) ,
 .max_position_3_cmp_r    ( max_position_3_cmp_r   ) ,
 .frequency_mode         (filter_mode[0]), 
 .start_position_1_o      ( start_position_1_reorder ),
 .end_position_1_o        ( end_position_1_reorder   ),
 .start_position_2_o      ( start_position_2_reorder ),
 .end_position_2_o        ( end_position_2_reorder   ),
 .start_position_3_o      ( start_position_3_reorder ),
 .end_position_3_o        ( end_position_3_reorder   )  ,
 .max_position_1_cmp_reorder(   ref_frequency [23:16]            ),
  .max_position_2_cmp_reorder(  ref_frequency  [15:8]             ),
  .max_position_3_cmp_reorder(  ref_frequency [7:0]               ) 
 
 
 
); 
 

selectram_group selectram_group_0(
  .rst_n                 (rst_n                                 ),       //input                 rst_n                                      ,
  .clk                   (clk                                   ),       //input                 clk                                        ,
  .start_position_1      (start_position_1_reorder                    ),       //input   [7:0]         start_position_1                           ,
  .end_position_1        (end_position_1_reorder                      ),       //input   [7:0]         end_position_1                             ,
  .start_position_2      (start_position_2_reorder                    ),       //input   [7:0]         start_position_2                           ,
  .end_position_2        (end_position_2_reorder                      ),       //input   [7:0]         end_position_2                             ,
  .start_position_3      (start_position_3_reorder                    ),       //input   [7:0]         start_position_3                           ,
  .end_position_3        (end_position_3_reorder                      ),       //input   [7:0]         end_position_3                             ,     
                      
  .position_gen_en       (position_gen_en                    ),       //input                 position_gen_en                            , 
  .select_ram_out_1      (select_ram_out_1                      ),       //output     wire       select_ram_out_1                           ,        
  .select_ram_out_1_en   (select_ram_out_1_en                   ),       //output     wire       select_ram_out_1_en                        ,
  .select_ram_out_2      (select_ram_out_2                      ),       //output     wire       select_ram_out_2                           ,
  .select_ram_out_2_en   (select_ram_out_2_en                   ),       //output     wire       select_ram_out_2_en                        ,
  .select_ram_out_3      (select_ram_out_3                      ),       //output     wire       select_ram_out_3                           ,
  .select_ram_out_3_en   (select_ram_out_3_en                   ),       //output     wire       select_ram_out_3_en                        ,
  .rd_en                 (    rd_en                               ) ,      //output     reg        rd_en                                      
  .rd_addr               (  rd_addr                            )
  );
  
  
  compare_data_select compare_data_select_0       (
    .rst_n                                          (      rst_n                                                   )    ,                                                          //input              rst_n                       ,              // async reset_all
    .clk                                            (       clk                                           )    ,                                                          //input              clk                         ,               // 
    .floating_IM_square_add_RE_suqare               (floating_IM_square_add_RE_suqare                                )    ,                                                       //input    [31:0]   floating_IM_square_add_RE_suqare,
    .floating_IM_square_add_RE_suqare_en            (floating_IM_square_add_RE_suqare_en                           )    ,   
    . floating_IM_square_add_RE_suqare_last         (floating_IM_square_add_RE_suqare_last                          )    ,                                                 //input             floating_IM_square_add_RE_suqare_en, 
    .start_cmp_position_r                           (    8'd3                                                  )    ,                                                                   //input      [7:0]  start_cmp_position_r,
    .floating_IM_square_add_RE_suqare_selected         ( floating_IM_square_add_RE_suqare_selected            )    ,                                                     //output reg [31:0] floating_IM_square_add_RE_suqare_o,
    .floating_IM_square_add_RE_suqare_selected_en      ( floating_IM_square_add_RE_suqare_selected_en         )    ,   
    .floating_IM_square_add_RE_suqare_selected_position( floating_IM_square_add_RE_suqare_selected_position   ),                                               //output reg        floating_IM_square_add_RE_suqare_en_o, 
    .floating_IM_square_add_RE_suqare_o_r              ( floating_IM_square_add_RE_suqare_o_r                )    ,                                                  //output reg [31:0] floating_IM_square_add_RE_suqare_o_r ,
    .floating_IM_square_add_RE_suqare_en_o_r           ( floating_IM_square_add_RE_suqare_en_o_r             )    ,
    .floating_IM_square_add_RE_suqare_o_position_r     ( floating_IM_square_add_RE_suqare_o_position_r       ),                                                //output reg        floating_IM_square_add_RE_suqare_en_o_r,    
    .floating_IM_square_add_RE_suqare_o_rr             ( floating_IM_square_add_RE_suqare_o_rr               )    ,                                                  //output reg [31:0] floating_IM_square_add_RE_suqare_o_rr,
    .floating_IM_square_add_RE_suqare_en_o_rr          ( floating_IM_square_add_RE_suqare_en_o_rr            ) ,
    .floating_IM_square_add_RE_suqare_o_position_rr    ( floating_IM_square_add_RE_suqare_o_position_rr       ),
   . floating_IM_square_add_RE_suqare_last_r           ( floating_IM_square_add_RE_suqare_last_r             )                       //output reg        floating_IM_square_add_RE_suqare_en_o_rr
                         );
  
  
  
  compare_data_select compare_data_select_1       (
    .rst_n                                          (      rst_n                                                   )    ,                                     
    .clk                                            (       clk                                           )    ,                                              
    .floating_IM_square_add_RE_suqare               (floating_IM_square_add_RE_suqare_1                                )    ,                                 
    .floating_IM_square_add_RE_suqare_en            (floating_IM_square_add_RE_suqare_en_1                           )    ,   
    . floating_IM_square_add_RE_suqare_last         (floating_IM_square_add_RE_suqare_last_1                          )    ,                                  
    .start_cmp_position_r                           (    8'd3                                                  )    ,                                         
    .floating_IM_square_add_RE_suqare_selected         ( floating_IM_square_add_RE_suqare_selected_1            )    ,                                        
    .floating_IM_square_add_RE_suqare_selected_en      ( floating_IM_square_add_RE_suqare_selected_en_1         )    ,   
    .floating_IM_square_add_RE_suqare_selected_position( floating_IM_square_add_RE_suqare_selected_position_1   ),                                            
    .floating_IM_square_add_RE_suqare_o_r              ( floating_IM_square_add_RE_suqare_o_r_1                )    ,                                         
    .floating_IM_square_add_RE_suqare_en_o_r           ( floating_IM_square_add_RE_suqare_en_o_r_1             )    ,
    .floating_IM_square_add_RE_suqare_o_position_r     ( floating_IM_square_add_RE_suqare_o_position_r_1       ),                                             
    .floating_IM_square_add_RE_suqare_o_rr             ( floating_IM_square_add_RE_suqare_o_rr_1               )    ,                                         
    .floating_IM_square_add_RE_suqare_en_o_rr          ( floating_IM_square_add_RE_suqare_en_o_rr_1            ) ,
    .floating_IM_square_add_RE_suqare_o_position_rr    ( floating_IM_square_add_RE_suqare_o_position_rr_1       ),
    .floating_IM_square_add_RE_suqare_last_r           (  floating_IM_square_add_RE_suqare_last_r_1            )           
             );
  
  
  
 config_register_file config_register_file_0(
  .rst_n                   (  rst_n                            ),     //  input                 rst_n                       ,// async reset_all
  .PCIE_dma_engine_clk     (  PCIE_dma_engine_clk                   ),     //  input                 PCIE_dma_engine_clk         ,
  .narrow_band_width       (narrow_band_width       ),     //  input  [7:0]          narrow_band_width           ,
  .narrow_band_width_en    (narrow_band_width_en    ),     //  input                 narrow_band_width_en        ,                                                                                  
  .filter_mode             (filter_mode             ),     //  input  [1:0]          filter_mode                 ,
  .filter_mode_en          (filter_mode_en          ),     //  input                 filter_mode_en              ,                     
  .start_cmp_position      (start_cmp_position      ),     //  input  [7:0]          start_cmp_position           ,
  .start_cmp_position_en   (start_cmp_position_en   ),     //  input                 start_cmp_position_en        ,
  .narrow_band_width_r     ( narrow_band_width_o              ),     //  output   reg   [7:0]  narrow_band_width_r          ,
  .filter_mode_r           ( filter_mode_o                      ),     //  output   reg   [1:0]  filter_mode_r                ,        //'b00 single frequency                                                            //'b01 three frequency   
  .start_cmp_position_r    ( start_cmp_position_o                  )      //  output   reg   [7:0]  start_cmp_position_r                     ='d25 ='b00 ='d25 
 ); 
  
  
assign CHA_RE_IM_DATA_filtered_f1=(CHA_RE_IM_DATA_valid&&select_ram_out_1)?CHA_RE_IM_DATA:64'b0; 
 assign CHB_RE_IM_DATA_filtered_f1=(CHB_RE_IM_DATA_valid&&select_ram_out_1)?CHB_RE_IM_DATA:64'b0; 
 
 assign CHA_RE_IM_DATA_filtered_f2=(CHA_RE_IM_DATA_valid&&select_ram_out_2)?CHA_RE_IM_DATA:64'b0; 
 assign CHB_RE_IM_DATA_filtered_f2=(CHB_RE_IM_DATA_valid&&select_ram_out_2)?CHB_RE_IM_DATA:64'b0; 
 
 assign CHA_RE_IM_DATA_filtered_f3=(CHA_RE_IM_DATA_valid&&select_ram_out_3)?CHA_RE_IM_DATA:64'b0; 
 assign CHB_RE_IM_DATA_filtered_f3=(CHB_RE_IM_DATA_valid&&select_ram_out_3)?CHB_RE_IM_DATA:64'b0; 
 
 
 assign          CHA_RE_IM_DATA_valid_f1=(filter_mode[0] )?CHA_RE_IM_DATA_valid:1'b0;
 assign          CHA_RE_IM_DATA_last_f1 =(filter_mode[0] )?CHA_RE_IM_DATA_last :1'b0;

 assign          CHB_RE_IM_DATA_valid_f1=(filter_mode[0])?CHB_RE_IM_DATA_valid:1'b0;
 assign          CHB_RE_IM_DATA_last_f1 =(filter_mode[0])?CHB_RE_IM_DATA_last :1'b0;
 
 assign          CHA_RE_IM_DATA_valid_f2 = CHA_RE_IM_DATA_valid ;
 assign          CHA_RE_IM_DATA_last_f2  = CHA_RE_IM_DATA_last  ;
 
 assign          CHB_RE_IM_DATA_valid_f2= CHB_RE_IM_DATA_valid ;
 assign          CHB_RE_IM_DATA_last_f2 = CHB_RE_IM_DATA_last  ;
 
 assign          CHA_RE_IM_DATA_valid_f3 =(filter_mode[0])?CHA_RE_IM_DATA_valid:1'b0;
 assign          CHA_RE_IM_DATA_last_f3  =(filter_mode[0])?CHA_RE_IM_DATA_last:1'b0; 
 
 assign          CHB_RE_IM_DATA_valid_f3 =(filter_mode[0])?CHB_RE_IM_DATA_valid:1'b0;
 assign          CHB_RE_IM_DATA_last_f3  =(filter_mode[0])?CHB_RE_IM_DATA_last:1'b0;   
  
  endmodule

