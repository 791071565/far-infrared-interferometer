`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/31 13:11:13
// Design Name: 
// Module Name: ping_pong_storage_double
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


module ping_pong_storage_double(
input          clk,	  
 input          rst_n,     
 input          start,
 
 input   [15:0] data_in_A_channel,
 input          data_in_A_channel_en,
 
 input   [15:0] data_in_B_channel,
 input          data_in_B_channel_en,
 
 input          PCIE_dma_engine_clk,
 input          RAM_wr_en,
 input [63:0]   RAM_wr_data,
 input [7:0]    RAM_wr_addr,
 input          RAM_SEL,
 input          ROM_SEL,

 output [31:0]  data_to_CHA_FFT   ,   //floating point
 output         data_to_CHA_FFT_en,

 output    reg      stream_last_CHA,     
 
 output [31:0]  data_to_CHB_FFT   ,   //floating point  
 output         data_to_CHB_FFT_en,   
 
 output    reg     stream_last_CHB    
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
wire [63:0] blackman_data;
wire [63:0] any_window_data;    
wire  memory_rd_en; 
reg   memory_rd_en_r1   =1'b0;
reg   memory_rd_en_r2   =1'b0;
reg   memory_rd_en_r3   =1'b0;
reg   memory_rd_en_r4   =1'b0;
reg   memory_rd_en_r5   =1'b0; 
reg   memory_rd_en_delay=1'b0;
assign ROM_rd_en=(!RAM_sel)?memory_rd_en_delay:1'd0;
assign RAM_rd_en=( RAM_sel)?memory_rd_en_delay:1'd0;
always@(posedge clk)
begin
 memory_rd_en_r1   <=memory_rd_en;
 memory_rd_en_r2   <=memory_rd_en_r1;
 memory_rd_en_r3   <=memory_rd_en_r2;
 memory_rd_en_r4   <=memory_rd_en_r3;
 memory_rd_en_r5   <=memory_rd_en_r4; 
 memory_rd_en_delay<=memory_rd_en_r5;
end

wire  [63:0] CHA_double_data   ;
wire         CHA_double_data_en;
wire  [63:0] CHB_double_data   ;
wire         CHB_double_data_en;

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

reg  ROM_rd_en_r=0;
always@(posedge clk)
ROM_rd_en_r<=ROM_rd_en;

reg  RAM_rd_en_r=0;
always@(posedge clk)
RAM_rd_en_r<=RAM_rd_en; 

blackman_floating_point blackman_floating_point_1(
.clka (   clk       ), //: IN STD_LOGIC;
.ena  ( ROM_rd_en   ), //: IN STD_LOGIC;
.addra(ROM_rd_addr  ), //: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
.douta(blackman_data) //: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
);

wire        windowed_CHA_double_data_en;
wire [63:0] windowed_CHA_double_data   ;

wire  windowed_CHB_double_data_en;
wire [63:0] windowed_CHB_double_data   ;

double_multiplier double_multiplier_0(
 .  aclk                (     clk               ), //: IN STD_LOGIC;
 .  s_axis_a_tvalid     (CHA_double_data_en     ), //: IN STD_LOGIC;
 .  s_axis_a_tdata      (CHA_double_data        ), //: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
 .  s_axis_b_tvalid     ((!RAM_sel)?ROM_rd_en_r:RAM_rd_en_r), //: IN STD_LOGIC;
 .  s_axis_b_tdata      ((!RAM_sel)?blackman_data:any_window_data), //: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
 .  m_axis_result_tvalid(windowed_CHA_double_data_en ), //: OUT STD_LOGIC;
 .  m_axis_result_tdata (windowed_CHA_double_data    )  //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
 );

double_multiplier double_multiplier_1(
 .  aclk                (     clk               ), //: IN STD_LOGIC;
 .  s_axis_a_tvalid     (CHB_double_data_en     ), //: IN STD_LOGIC;
 .  s_axis_a_tdata      (CHB_double_data        ), //: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
 .  s_axis_b_tvalid     ((!RAM_sel)?ROM_rd_en_r:RAM_rd_en_r), //: IN STD_LOGIC;
 .  s_axis_b_tdata      ((!RAM_sel)?blackman_data:any_window_data ), //: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
 .  m_axis_result_tvalid(windowed_CHB_double_data_en), //: OUT STD_LOGIC;
 .  m_axis_result_tdata (windowed_CHB_double_data   )  //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
 );



 reserved_window reserved_window_1(
   .clka  ( PCIE_dma_engine_clk   ),//   : IN STD_LOGIC;
   .ena   (  RAM_wr_en            ),//   : IN STD_LOGIC;
   .wea   (  RAM_wr_en            ),//     IN STD_LOGIC_VECTOR(0 DOWNTO 0);
   .addra (  RAM_wr_addr          ),//   : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
   .dina  ( RAM_wr_data           ),//   : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
   .clkb  (   clk                 ),//   : IN STD_LOGIC;
   .enb   ( RAM_rd_en             ),//   : IN STD_LOGIC;
   .addrb ( RAM_rd_addr           ),//   : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
   .doutb ( any_window_data       )//   : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
 );

double_to_single double_to_single_0(
   .aclk                (     clk                    ),   // : IN STD_LOGIC;
   .s_axis_a_tvalid     (windowed_CHA_double_data_en),   // : IN STD_LOGIC;
   .s_axis_a_tdata      (windowed_CHA_double_data   ),   // : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
   .m_axis_result_tvalid( data_to_CHA_FFT_en           ),   // : OUT STD_LOGIC;
   .m_axis_result_tdata ( data_to_CHA_FFT        )    // : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
 );

double_to_single double_to_single_1(
   .aclk                (      clk                   ),   // : IN STD_LOGIC;
   .s_axis_a_tvalid     ( windowed_CHB_double_data_en ),   // : IN STD_LOGIC;
   .s_axis_a_tdata      ( windowed_CHB_double_data    ),   // : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
   .m_axis_result_tvalid( data_to_CHB_FFT_en           ),   // : OUT STD_LOGIC;
   .m_axis_result_tdata ( data_to_CHB_FFT        )    // : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
 );


 signed_int16_to_double signed_int16_to_double_0(
   .aclk                 (      clk                   ),     //: IN STD_LOGIC;
   .s_axis_a_tvalid      (  channel_A_serial_data_valid),     //: IN STD_LOGIC;
   .s_axis_a_tdata       (  channel_A_serial_data      ),     //: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
   .m_axis_result_tvalid (  CHA_double_data_en        ),     //: OUT STD_LOGIC;
   .m_axis_result_tdata  (  CHA_double_data     )      //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
 );


 signed_int16_to_double signed_int16_to_double_1 (
   .aclk                  (      clk                   ),      //: IN STD_LOGIC;
   .s_axis_a_tvalid       ( channel_B_serial_data_valid),      //: IN STD_LOGIC;
   .s_axis_a_tdata        ( channel_B_serial_data      ),      //: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
   .m_axis_result_tvalid  ( CHB_double_data_en          ),      //: OUT STD_LOGIC;
   .m_axis_result_tdata   ( CHB_double_data       )       //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
 );


reg [8:0]  last_delay_cnt='d0;
reg        last_dalay_cnt_add_en=0;
always@(posedge clk or negedge rst_n)
   if(!rst_n)
   last_dalay_cnt_add_en<='d0;
   else if(last_delay_cnt==8'd22)
   last_dalay_cnt_add_en<='d0;
   else if(stream_last_sig_CHA)
   last_dalay_cnt_add_en<='d1;

always@(posedge clk or negedge rst_n)
   if(!rst_n)
   last_delay_cnt<=8'd0;
   else if(last_delay_cnt==8'd22)
   last_delay_cnt<=8'd0;
   else if(last_dalay_cnt_add_en)
   last_delay_cnt<=last_delay_cnt+1'd1; 

always@(posedge clk or negedge rst_n)
   if(!rst_n)
   stream_last_CHA<='d0;
   else if(last_delay_cnt==8'd22)
   stream_last_CHA<='d1;
   else 
   stream_last_CHA<='d0; 

always@(posedge clk or negedge rst_n)
   if(!rst_n)
   stream_last_CHB<='d0;
   else if(last_delay_cnt==8'd22)
   stream_last_CHB<='d1;
   else 
   stream_last_CHB<='d0;


endmodule 