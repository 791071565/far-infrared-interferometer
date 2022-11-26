`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/31 13:41:36
// Design Name: 
// Module Name: comparator_tree
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


module comparator_tree#(
   parameter   start_cmp_position=8'd3
)

(
 input               rst_n                       ,
 input               clk                         ,
 input   [31:0]      floating_IM_square_add_RE_suqare_selected,
 input               floating_IM_square_add_RE_suqare_selected_en,  
 input    [7:0]      floating_IM_square_add_RE_suqare_selected_position,
                     
 input   [31:0]      floating_IM_square_add_RE_suqare_o_r ,
 input               floating_IM_square_add_RE_suqare_en_o_r,    
 input   [7:0]       floating_IM_square_add_RE_suqare_o_position_r,
                     
 input  [31:0]       floating_IM_square_add_RE_suqare_o_rr,
 input               floating_IM_square_add_RE_suqare_en_o_rr,
 input   [7:0]       floating_IM_square_add_RE_suqare_o_position_rr , //='d128 position finish sig
 
 (*mark_debug = "true"*) input                spectrum_cmp_finish_sig, 
           
 input   [7:0]       narrow_band_width_r,
 
(*mark_debug = "true"*)  output  reg   [7:0] start_position_1='d0,
(*mark_debug = "true"*)  output  reg   [7:0] end_position_1='d0,
(*mark_debug = "true"*)  output  reg         position_1_error_sig=0,
   
 output  reg   [7:0] start_position_2='d0,
 output  reg   [7:0] end_position_2='d0,
 output  reg         position_2_error_sig=0,
 
 output  reg   [7:0] start_position_3='d0,
 output  reg   [7:0] end_position_3='d0,     
 output reg          position_3_error_sig='d0,
 
(*mark_debug = "true"*)  output reg          position_gen_en='d0 ,

 output  reg   [7:0]    max_position_1_cmp_r='d0,

 output  reg   [7:0]    max_position_2_cmp_r='d0,

 output  reg   [7:0]    max_position_3_cmp_r='d0 

 );
localparam filter_points='d128;
      wire  equal_stage1_0;
      wire  larger_stage1_0;
      wire  smaller_stage1_0;
      wire  comparator_out_stage1_0;
      wire [31:0]    comparator_result_larger_data_stage1_0     ;
      wire [7:0]     comparator_result_larger_position_stage1_0 ;
      wire [31:0]    comparator_result_smaller_data_stage1_0    ;
      wire [7:0]     comparator_result_smaller_position_stage1_0;

 floating_point_comparator floating_point_comparator_0(
        .clk                               (     clk                                           ) ,
        .rst_n                             (     1'b1                                          ) ,
        .floating_point_1                  (floating_IM_square_add_RE_suqare_selected          ) ,//1 bit sign  8bit  exp      23 bit float
        .floating_point_1_en               (floating_IM_square_add_RE_suqare_en_o_rr           ) ,
        .floating_point_1_position         (floating_IM_square_add_RE_suqare_selected_position ),
        .floating_point_2                  (floating_IM_square_add_RE_suqare_o_r               ) ,
        .floating_point_2_en               (floating_IM_square_add_RE_suqare_en_o_rr           ) , 
        .floating_point_2_position         (floating_IM_square_add_RE_suqare_o_position_r      ),
        .equal                             ( equal_stage1_0                                    ) ,
        .larger_en                         (larger_stage1_0                                    ) ,
        .smaller_en                        (smaller_stage1_0                                   ) ,
        .comparator_out                    (comparator_out_stage1_0                            ),
        .comparator_result_larger_data     (comparator_result_larger_data_stage1_0             ),          //output [31:0]    comparator_result_larger_data,
        .comparator_result_larger_position (comparator_result_larger_position_stage1_0         ),          //output [7:0]     comparator_result_larger_position,
        .comparator_result_smaller_data    (comparator_result_smaller_data_stage1_0            ),          //output [31:0]    comparator_result_smaller_data,
        .comparator_result_smaller_position(comparator_result_smaller_position_stage1_0        )           //output [7:0]     comparator_result_smaller_position            
); 

     wire           equal_stage1_1         ;
     wire           larger_stage1_1        ;
     wire           smaller_stage1_1       ;
     wire           comparator_out_stage1_1;
     wire [31:0]    comparator_result_larger_data_stage1_1     ;
     wire [7:0]     comparator_result_larger_position_stage1_1 ;
     wire [31:0]    comparator_result_smaller_data_stage1_1    ;
     wire [7:0]     comparator_result_smaller_position_stage1_1;

floating_point_comparator floating_point_comparator_1(
        .clk                               (     clk                                       ),
        .rst_n                             (     1'b1                                      ),
        .floating_point_1                  (floating_IM_square_add_RE_suqare_o_r           ),    //1 bit sign  8bit  exp      23 bit float
        .floating_point_1_en               (floating_IM_square_add_RE_suqare_en_o_rr       ),
        .floating_point_1_position         (floating_IM_square_add_RE_suqare_o_position_r  ),
        .floating_point_2                  (floating_IM_square_add_RE_suqare_o_rr          ),
        .floating_point_2_en               (floating_IM_square_add_RE_suqare_en_o_rr       ), 
        .floating_point_2_position         (floating_IM_square_add_RE_suqare_o_position_rr ),
        .equal                             (equal_stage1_1                                 ),
        .larger_en                         (larger_stage1_1                                ),
        .smaller_en                        (smaller_stage1_1                               ),
        .comparator_out                    (comparator_out_stage1_1                        ),
        .comparator_result_larger_data     (comparator_result_larger_data_stage1_1         ), //output [31:0]    comparator_result_larger_data,
        .comparator_result_larger_position (comparator_result_larger_position_stage1_1     ), //output [7:0]     comparator_result_larger_position,
        .comparator_result_smaller_data    (comparator_result_smaller_data_stage1_1        ), //output [31:0]    comparator_result_smaller_data,
        .comparator_result_smaller_position(comparator_result_smaller_position_stage1_1    )  //output [7:0]     comparator_result_smaller_position            
);  

 reg [31:0]  spectrum_peak_cmp=0;
 reg [7:0]   spectrum_peak_position_cmp=0;
 reg         spectrum_peak_cmp_en=0;

  always@(posedge clk or negedge rst_n)
    if(!rst_n)
    begin
       spectrum_peak_cmp         <='d0;
       spectrum_peak_position_cmp<='d0;
       spectrum_peak_cmp_en      <='d0;
       end
   else if(larger_stage1_1&&smaller_stage1_0&&comparator_out_stage1_0)    
    begin     
       spectrum_peak_cmp         <=comparator_result_larger_data_stage1_0;
       spectrum_peak_position_cmp<=comparator_result_larger_position_stage1_0;
       spectrum_peak_cmp_en      <=1;
       end
   else 
     begin
       spectrum_peak_cmp_en      <=0; 
       spectrum_peak_cmp         <=spectrum_peak_cmp;
       spectrum_peak_position_cmp<=spectrum_peak_position_cmp;
     end

 (*mark_debug = "true"*) reg  [31:0]    max_data_1_cmp    ='d0;
(*mark_debug = "true"*)  reg   [7:0]    max_position_1_cmp='d0;
(*mark_debug = "true"*)  reg  [31:0]    max_data_2_cmp    ='d0; 
(*mark_debug = "true"*)  reg   [7:0]    max_position_2_cmp='d0;
(*mark_debug = "true"*)  reg  [31:0]    max_data_3_cmp    ='d0; 
(*mark_debug = "true"*)  reg   [7:0]    max_position_3_cmp='d0;

 wire           equal_stage2_0         ; 
 wire           larger_stage2_0        ;
 wire           smaller_stage2_0       ;
 wire           comparator_out_stage2_0;
 
 wire [31:0]    comparator_result_larger_data_stage2_0     ;
 wire [7:0]     comparator_result_larger_position_stage2_0 ;
 wire [31:0]    comparator_result_smaller_data_stage2_0    ;
 wire [7:0]     comparator_result_smaller_position_stage2_0;


  floating_point_comparator floating_point_comparator_2(
        .clk                               (     clk                                    ),
        .rst_n                             (     1'b1                                   ),
        .floating_point_1                  (spectrum_peak_cmp                           ),//1 bit sign  8bit  exp      23 bit float
        .floating_point_1_en               (spectrum_peak_cmp_en                        ),
        .floating_point_1_position         (spectrum_peak_position_cmp                  ),
        .floating_point_2                  (max_data_1_cmp                              ),
        .floating_point_2_en               (spectrum_peak_cmp_en                        ), 
        .floating_point_2_position         (max_position_1_cmp                          ),
        .equal                             (equal_stage2_0                              ),
        .larger_en                         (larger_stage2_0                             ),
        .smaller_en                        (smaller_stage2_0                            ),
        .comparator_out                    (comparator_out_stage2_0                     ),
        .comparator_result_larger_data     (comparator_result_larger_data_stage2_0      ),     //output [31:0]    comparator_result_larger_data,
        .comparator_result_larger_position (comparator_result_larger_position_stage2_0  ),     //output [7:0]     comparator_result_larger_position,
        .comparator_result_smaller_data    (comparator_result_smaller_data_stage2_0     ),     //output [31:0]    comparator_result_smaller_data,
        .comparator_result_smaller_position(comparator_result_smaller_position_stage2_0 )      //output [7:0]     comparator_result_smaller_position      
  );
  

  always@(posedge clk or negedge rst_n)  
    if(!rst_n)
      begin
       max_data_1_cmp<='d0;
       max_position_1_cmp<='d0;
      end
   else if(spectrum_cmp_finish_sig)
     begin
       max_data_1_cmp<='d0;
       max_position_1_cmp<='d0;
     end   
  else if(larger_stage2_0&&comparator_out_stage2_0)
     begin
       max_data_1_cmp<=comparator_result_larger_data_stage2_0;
       max_position_1_cmp<=comparator_result_larger_position_stage2_0;
     end
 

 wire           equal_stage3_0         ; 
 wire           larger_stage3_0        ;
 wire           smaller_stage3_0       ;
 wire           comparator_out_stage3_0;
 
 wire [31:0]    comparator_result_larger_data_stage3_0     ;
 wire [7:0]     comparator_result_larger_position_stage3_0 ;
 wire [31:0]    comparator_result_smaller_data_stage3_0    ;
 wire [7:0]     comparator_result_smaller_position_stage3_0;


 floating_point_comparator floating_point_comparator_3(
        .clk                               (     clk                                    ),
        .rst_n                             (     1'b1                                   ),
        .floating_point_1                  (comparator_result_smaller_data_stage2_0      ),//1 bit sign  8bit  exp      23 bit float
        .floating_point_1_en               ((smaller_stage2_0&&comparator_out_stage2_0  ) ||(larger_stage2_0&&comparator_out_stage2_0)   ),
        .floating_point_1_position         (comparator_result_smaller_position_stage2_0  ),
        .floating_point_2                  (max_data_2_cmp                              ),
        .floating_point_2_en               ((smaller_stage2_0&&comparator_out_stage2_0 ) ||(larger_stage2_0&&comparator_out_stage2_0)   ), 
        .floating_point_2_position         (max_position_2_cmp                          ),
        .equal                             (equal_stage3_0                              ),
        .larger_en                         (larger_stage3_0                             ),
        .smaller_en                        (smaller_stage3_0                            ),
        .comparator_out                    (comparator_out_stage3_0                     ),
        .comparator_result_larger_data     (comparator_result_larger_data_stage3_0     ),     //output [31:0]    comparator_result_larger_data,
        .comparator_result_larger_position (comparator_result_larger_position_stage3_0 ),     //output [7:0]     comparator_result_larger_position,
        .comparator_result_smaller_data    (comparator_result_smaller_data_stage3_0    ),     //output [31:0]    comparator_result_smaller_data,
        .comparator_result_smaller_position(comparator_result_smaller_position_stage3_0)      //output [7:0]     comparator_result_smaller_position      
  );

    always@(posedge clk or negedge rst_n)  
        if(!rst_n)
           begin
            max_data_2_cmp<='d0;
            max_position_2_cmp<='d0;
           end
   else if(spectrum_cmp_finish_sig)
           begin
             max_data_2_cmp<='d0;
             max_position_2_cmp<='d0;
           end   
  else if(larger_stage3_0&&comparator_out_stage3_0)
           begin
             max_data_2_cmp<=comparator_result_larger_data_stage3_0;
             max_position_2_cmp<=comparator_result_larger_position_stage3_0;
           end



 wire           equal_stage4_0         ; 
 wire           larger_stage4_0        ;
 wire           smaller_stage4_0       ;
 wire           comparator_out_stage4_0;
 
 wire [31:0]    comparator_result_larger_data_stage4_0     ;
 wire [7:0]     comparator_result_larger_position_stage4_0 ;
 wire [31:0]    comparator_result_smaller_data_stage4_0    ;
 wire [7:0]     comparator_result_smaller_position_stage4_0;

floating_point_comparator floating_point_comparator_4(
        .clk                               (     clk                                    ),
        .rst_n                             (     1'b1                                   ),
        .floating_point_1                  (comparator_result_smaller_data_stage3_0      ),//1 bit sign  8bit  exp      23 bit float
        .floating_point_1_en               ((smaller_stage3_0&&comparator_out_stage3_0) ||(larger_stage3_0&&comparator_out_stage3_0)  ),
        .floating_point_1_position         (comparator_result_smaller_position_stage3_0),
        .floating_point_2                  (max_data_3_cmp                              ),
        .floating_point_2_en               ((smaller_stage3_0&&comparator_out_stage3_0)||(larger_stage3_0&&comparator_out_stage3_0) ), 
        .floating_point_2_position         (max_position_3_cmp                          ),
        .equal                             (equal_stage4_0                              ),
        .larger_en                         (larger_stage4_0                             ),
        .smaller_en                        (smaller_stage4_0                            ),
        .comparator_out                    (comparator_out_stage4_0                     ),
        .comparator_result_larger_data     (comparator_result_larger_data_stage4_0     ),     //output [31:0]    comparator_result_larger_data,
        .comparator_result_larger_position (comparator_result_larger_position_stage4_0 ),     //output [7:0]     comparator_result_larger_position,
        .comparator_result_smaller_data    (comparator_result_smaller_data_stage4_0    ),     //output [31:0]    comparator_result_smaller_data,
        .comparator_result_smaller_position(comparator_result_smaller_position_stage4_0)      //output [7:0]     comparator_result_smaller_position      
  );

  always@(posedge clk or negedge rst_n)  
        if(!rst_n)
           begin
            max_data_3_cmp<='d0;
            max_position_3_cmp<='d0;
           end
   else if(spectrum_cmp_finish_sig)
           begin
             max_data_3_cmp<='d0;
             max_position_3_cmp<='d0;
           end   
  else if(larger_stage4_0&&comparator_out_stage4_0)
           begin
             max_data_3_cmp<=comparator_result_larger_data_stage4_0;
             max_position_3_cmp<=comparator_result_larger_position_stage4_0;
           end

always@(posedge clk or negedge rst_n)
  if(!rst_n)
    begin
    start_position_1<='d0;
    
    end_position_1  <='d0;
               
    start_position_2<='d0;
    
    end_position_2  <='d0;
          
    start_position_3<='d0;
    
    end_position_3  <='d0; 
     
     position_gen_en<='d0;       
    end
  else if(spectrum_cmp_finish_sig)
   begin
    start_position_1<=(max_position_1_cmp>(narrow_band_width_r+8'd3))?(max_position_1_cmp-narrow_band_width_r):8'd3;//if the  window_width is too large   
            
    //end_position_1  <=((filter_points-max_position_1_cmp)>narrow_band_width_r)?(max_position_1_cmp+narrow_band_width_r):(filter_points-'d1);
   end_position_1  <=(max_position_1_cmp+narrow_band_width_r);   
    start_position_2<=(max_position_2_cmp>(narrow_band_width_r+8'd3))?(max_position_2_cmp-narrow_band_width_r):8'd3;  
    
   // end_position_2  <=((filter_points-max_position_2_cmp)>narrow_band_width_r)?(max_position_2_cmp+narrow_band_width_r):(filter_points-'d1);    
    end_position_2  <=(max_position_2_cmp+narrow_band_width_r); 
    start_position_3<=(max_position_3_cmp>(narrow_band_width_r+8'd3))?(max_position_3_cmp-narrow_band_width_r):8'd3;
      
   // end_position_3  <=((filter_points-max_position_3_cmp)>narrow_band_width_r)?(max_position_3_cmp+narrow_band_width_r):(filter_points-'d1);    
    end_position_3  <=(max_position_3_cmp+narrow_band_width_r); 
    
    position_gen_en <=1;
    end
  else
   begin  
       start_position_1<=start_position_1;       
       end_position_1  <=end_position_1;                  
       start_position_2<=start_position_2;       
       end_position_2  <=end_position_2;            
       start_position_3<=start_position_3;       
       end_position_3  <=end_position_3;     
       position_gen_en<=0;       
  end   
     
  always@(posedge clk or negedge rst_n)
      if(!rst_n) 
    begin
         position_1_error_sig<='d0;
         
         position_2_error_sig<='d0;
         
         position_3_error_sig<='d0;      
    end
   else if(spectrum_cmp_finish_sig)
    begin
         position_1_error_sig<=(max_position_1_cmp<narrow_band_width_r)||((filter_points-max_position_1_cmp)<narrow_band_width_r);
                                                  
         position_2_error_sig<=(max_position_2_cmp<narrow_band_width_r)||((filter_points-max_position_2_cmp)<narrow_band_width_r);
                                                  
         position_3_error_sig<=(max_position_3_cmp<narrow_band_width_r)||((filter_points-max_position_3_cmp)<narrow_band_width_r);      
    end       
     
  always@(posedge clk or negedge rst_n)
        if(!rst_n)   
     begin
     max_position_1_cmp_r<='d0;                            
     max_position_2_cmp_r<='d0;                          
     max_position_3_cmp_r<='d0;
     end
     else 
     begin
       max_position_1_cmp_r<=max_position_1_cmp;                            
       max_position_2_cmp_r<=max_position_2_cmp;                          
       max_position_3_cmp_r<=max_position_3_cmp;
       end
     
     
     
     
     
     
     
     
 endmodule
