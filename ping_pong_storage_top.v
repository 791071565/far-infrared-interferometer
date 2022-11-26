`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/31 13:06:52
// Design Name: 
// Module Name: ping_pong_storage_top
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


module ping_pong_storage_top(
  input          clk,	  
input          rst_n,     
input          start,

input   [15:0] data_in_A_channel,
input          data_in_A_channel_en,

input   [15:0] data_in_B_channel,
input          data_in_B_channel_en,

input          PCIE_dma_engine_clk,
input          RAM_wr_en,
input [31:0]   RAM_wr_data,
input [7:0]    RAM_wr_addr,
input          RAM_SEL,
input          ROM_SEL,

output [31:0]  data_to_CHA_FFT,   //floating point

output         data_to_CHA_FFT_en,

output          stream_last_CHA,     

output [31:0]  data_to_CHB_FFT,   //floating point

output         data_to_CHB_FFT_en,   

output         stream_last_CHB    
);
wire  [15:0] channel_A_serial_data;
wire         channel_A_serial_data_valid;

wire  [15:0] channel_B_serial_data;
wire         channel_B_serial_data_valid;

reg  RAM_sel='d0;
always@(posedge clk or negedge rst_n) 
   if(!rst_n)
    RAM_sel<='d0;
   else if(RAM_SEL)
    RAM_sel<='d1;
   else if(ROM_SEL) 
    RAM_sel<='d0; 

wire  ROM_rd_en; 
wire  RAM_rd_en;
reg  [7:0] ROM_rd_addr='d0;
reg  [7:0] RAM_rd_addr='d0;
wire [31:0] blackman_data;
wire [31:0] any_window_data;    
wire  memory_rd_en;
assign ROM_rd_en=(!RAM_sel)?memory_rd_en:1'd0;
assign RAM_rd_en=( RAM_sel)?memory_rd_en:1'd0;
always@(posedge clk or negedge rst_n)  
if(!rst_n)
ROM_rd_addr<='d0;
else if(ROM_rd_en)
ROM_rd_addr<=ROM_rd_addr+'d1;
//else if(channel_A_serial_data_valid&&(!RAM_sel))//reset the addr
//ROM_rd_addr<=ROM_rd_addr+'d1;

always@(posedge clk or negedge rst_n)  
if(!rst_n)
RAM_rd_addr<='d0;
else if(RAM_rd_en)
RAM_rd_addr<=RAM_rd_addr+'d1;
//else if(channel_A_serial_data_valid&&(RAM_sel))//reset the addr
//RAM_rd_addr<=RAM_rd_addr+'d1;

//CHA CHB are sync data
wire  stream_last_sig_CHA;

wire  stream_last_sig_CHB;

ping_pong_storage ping_pong_storage_0(
.clk           (    clk                    ),   //input         clk             ,
.rst_n         (  rst_n                    ),   //input         rst_n           , 
.data_in       ( data_in_A_channel         ),   //input [15:0]  data_in         ,
.data_in_valid (data_in_A_channel_en       ),   //input         data_in_valid   ,
.start         (   start                   ),   //input         start           ,
.data_out      (channel_A_serial_data      ),   //output [15:0] data_out        ,
.data_out_valid(channel_A_serial_data_valid),   //output        data_out_valid
.memory_rd_en  (memory_rd_en               ),
.stream_last   ( stream_last_sig_CHA       )
); 


ping_pong_storage ping_pong_storage_1(
.clk           (    clk                    ),   //input         clk             ,
.rst_n         (  rst_n                    ),   //input         rst_n           , 
.data_in       ( data_in_B_channel         ),   //input [15:0]  data_in         ,
.data_in_valid (data_in_B_channel_en       ),   //input         data_in_valid   ,
.start         (  start                    ),   //input         start           ,
.data_out      (channel_B_serial_data      ),   //output [15:0] data_out        ,
.data_out_valid(channel_B_serial_data_valid),  //output        data_out_valid
.memory_rd_en  (                           ),
.stream_last   ( stream_last_sig_CHB       )
); 


blackman_rom_0 blackman_rom_0_1(
.clka (   clk       ), //: IN STD_LOGIC;
.ena  ( ROM_rd_en   ), //: IN STD_LOGIC;
.addra(ROM_rd_addr  ), //: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
.douta(blackman_data) //: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
);

reserved_window_rom_0 reserved_window_rom_0_1(
.clka ( PCIE_dma_engine_clk      ), //: IN STD_LOGIC;
.ena  (  RAM_wr_en               ), //: IN STD_LOGIC;
.wea  (  RAM_wr_en               ), //: IN STD_LOGIC_VECTOR(0 DOWNTO 0);
.addra(  RAM_wr_addr             ), //: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
.dina ( RAM_wr_data              ), //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
.clkb (   clk                    ), //: IN STD_LOGIC;
.enb  ( RAM_rd_en                ), //: IN STD_LOGIC;
.addrb(RAM_rd_addr               ), //: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
.doutb( any_window_data          ) //: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
);

wire [47:0] windowed_data_CHA;
multiplier_48_out_pipeline_4 multiplier_48_out_pipeline_4_1(
.CLK(   clk                                  ),  //: IN STD_LOGIC;
.A  (  channel_A_serial_data                 ),  //: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
.B  ((!RAM_sel)?blackman_data:any_window_data),  //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
.P  ( windowed_data_CHA                      )  //: OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
);    
wire [47:0] windowed_data_CHB;
multiplier_48_out_pipeline_4 multiplier_48_out_pipeline_4_0(
.CLK(   clk                                  ),  //: IN STD_LOGIC;
.A  (  channel_B_serial_data                 ),  //: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
.B  ((!RAM_sel)?blackman_data:any_window_data),  //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
.P  ( windowed_data_CHB                      )  //: OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
);        
reg  serial_data_valid_r;
reg  serial_data_valid_rr;
reg  serial_data_valid_rrr;
reg  serial_data_valid_rrrr;
always@(posedge clk)
begin 
 serial_data_valid_r<=channel_A_serial_data_valid;
 serial_data_valid_rr<=serial_data_valid_r;
 serial_data_valid_rrr<=serial_data_valid_rr;
 serial_data_valid_rrrr<=serial_data_valid_rrr;
end


floating_point_0 floating_point_0_0 (    //pipeline stages £º4
.aclk                (    clk                   ),        //: IN STD_LOGIC;
.s_axis_a_tvalid     (serial_data_valid_rrrr           ),        //: IN STD_LOGIC;
.s_axis_a_tdata      ( windowed_data_CHA            ),        //: IN STD_LOGIC_VECTOR(47 DOWNTO 0);
.m_axis_result_tvalid( data_to_CHA_FFT_en           ),        //: OUT STD_LOGIC;
.m_axis_result_tdata (  data_to_CHA_FFT              )       //: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
);

floating_point_0 floating_point_0_1 (    //pipeline stages £º4
.aclk                (    clk                   ),        //: IN STD_LOGIC;
.s_axis_a_tvalid     (serial_data_valid_rrrr        ),        //: IN STD_LOGIC;
.s_axis_a_tdata      ( windowed_data_CHB            ),        //: IN STD_LOGIC_VECTOR(47 DOWNTO 0);
.m_axis_result_tvalid( data_to_CHB_FFT_en           ),        //: OUT STD_LOGIC;
.m_axis_result_tdata ( data_to_CHB_FFT              )       //: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
);
reg [3:0] delay_cnt='d0;
reg       delay_cnt_add_en='d0;
always@(posedge clk or negedge rst_n)
if(!rst_n)
delay_cnt_add_en<='d0;
else if(&delay_cnt[2:0])
delay_cnt_add_en<='d0; 
else if(stream_last_sig_CHA)
delay_cnt_add_en<='d1; 

always@(posedge clk or negedge rst_n)
   if(!rst_n)
     delay_cnt<='d0;
    else if(&delay_cnt[2:0])
    delay_cnt<='d0;
    else if(delay_cnt_add_en)
    delay_cnt<=delay_cnt+'d1;
    else  
    delay_cnt<='d0;

assign  stream_last_CHA=&delay_cnt[2:0];

assign  stream_last_CHB=&delay_cnt[2:0]; 




endmodule 
