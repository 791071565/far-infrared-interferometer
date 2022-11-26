`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/31 13:12:24
// Design Name: 
// Module Name: fft_module
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


module fft_module(
input         aclk,
input         rst_n,
input  [31:0] data_in_re,
input  [31:0] data_in_im,
input         data_in_en,
input         data_in_last,
input         FFT_mode,
output [31:0] data_out_re,
output [31:0] data_out_im,
output        data_out_en,
output        data_out_last
    );
   
   wire  s_axis_config_tready; 
   reg   s_axis_config_tvalid=0;
  wire  [15:0]  s_axis_config_tdata;

   reg  m_axis_data_tready=0;
   wire  m_axis_data_tvalid;
   wire  m_axis_data_tlast;   
   reg   config_done='d0;
   wire [7:0] SACLE_SCH_0;
   wire   FWD_INV_0;
   assign  FWD_INV_0=FFT_mode;//FFT
   assign SACLE_SCH_0=8'b00000000;//avoid overflow
    assign  s_axis_config_tdata={7'b0,SACLE_SCH_0,FWD_INV_0};
   always@(posedge  aclk or negedge rst_n)
    if(!rst_n)
    m_axis_data_tready<='d0;
   else if(m_axis_data_tvalid)
     m_axis_data_tready<='d1;
    else    m_axis_data_tready<='d0;
   always@(posedge  aclk or negedge rst_n)
       if(!rst_n)
        s_axis_config_tvalid<='d0;
      else if(config_done)
        s_axis_config_tvalid<='d0;
      else if(s_axis_config_tready&&(!config_done))
        s_axis_config_tvalid<='d1;
      else   
        s_axis_config_tvalid<='d0;
    
     always@(posedge  aclk or negedge rst_n)
     if(!rst_n)
     config_done<='d0;
     else if(s_axis_config_tready&&s_axis_config_tvalid)
     config_done<='d1;
    assign  data_out_en=m_axis_data_tvalid&&m_axis_data_tready;
    assign  data_out_last=m_axis_data_tlast;
 
    xfft_0  xfft_0_1
        (
         . aclk                        (    aclk                                 ),  //=> aclk,
         . aresetn                    (  rst_n                              ),
         . s_axis_config_tvalid        (  s_axis_config_tvalid                   ),  //=> s_axis_config_tvalid,
         . s_axis_config_tready        (  s_axis_config_tready                    ),  //=> s_axis_config_tready,
         . s_axis_config_tdata         (  s_axis_config_tdata                     ),  //=> s_axis_config_tdata,
         . s_axis_data_tvalid          (     data_in_en                           ),  //=> s_axis_data_tvalid,
         . s_axis_data_tready          (                                          ),  //=> s_axis_data_tready,
         . s_axis_data_tdata           ( {data_in_im,data_in_re}                  ),  //=> s_axis_data_tdata,
         . s_axis_data_tlast           (  data_in_last                            ),  //=> s_axis_data_tlast,
         . m_axis_data_tvalid          (m_axis_data_tvalid                ),  //=> m_axis_data_tvalid,
         . m_axis_data_tready          (m_axis_data_tready                        ),  //=> m_axis_data_tready,
         . m_axis_data_tdata           ({data_out_im,data_out_re}                     ),  //=> m_axis_data_tdata,
         . m_axis_data_tlast           ( m_axis_data_tlast                   ),  //=> m_axis_data_tlast,
         . event_frame_started         (                                          ),  //=> event_frame_started,
         . event_tlast_unexpected      (                                          ),  //=> event_tlast_unexpected,
         . event_tlast_missing         (                                          ),  //=> event_tlast_missing,
         . event_status_channel_halt   (                                          ),  //=> event_status_channel_halt,
         . event_data_in_channel_halt  (                                          ),  //=> event_data_in_channel_halt,
         . event_data_out_channel_halt (                                          )  //=> event_data_out_channel_halt
   
          );
    
endmodule
