`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/31 13:08:52
// Design Name: 
// Module Name: ping_pong_storage
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


module ping_pong_storage(
 input         clk,
 input         rst_n,
 input [15:0]  data_in,
 input         data_in_valid,
 input         start,
 output [15:0] data_out,
 output        data_out_valid,
 output        memory_rd_en,
 output   reg     stream_last
 );
 localparam [7:0]  data_compose=8'd52;
// localparam [7:0]  data_compose=8'd26;
  localparam [15:0] fft_point=16'd256;
  localparam [15:0] waiting_points=fft_point-data_compose;
  localparam [15:0] waiting_points_1=fft_point-2*data_compose;
  
  reg [7:0] wr_cnt=0;
  reg [7:0] rd_cnt=0;
  reg [15:0] data_in_r=0;
  
  //fifo interface       
  reg fifo_ping_wr_en=0 ;
  wire fifo_ping_rd_en ;
  
  reg fifo_pong_wr_en=0;
  wire fifo_pong_rd_en;
  
  wire frame_compose_ping_wr_en;
  wire  frame_compose_ping_rd_en;
      
  wire frame_compose_pong_wr_en;
  wire frame_compose_pong_rd_en;
  
 wire        fifo_ping_full      ; 
   wire        fifo_ping_empty     ;
   wire [7:0]  fifo_ping_rd_count  ;
  
  wire        fifo_pong_full      ; 
   wire        fifo_pong_empty     ;
   wire [7:0]  fifo_pong_rd_count  ;
  
  wire        frame_compose_ping_full    ;
  wire        frame_compose_ping_empty   ;
  wire [5:0]  frame_compose_ping_rd_count;
      
 wire        frame_compose_pong_full     ;
   wire        frame_compose_pong_empty    ;
   wire [5:0]  frame_compose_pong_rd_count ;
  
  wire [15:0] fifo_ping_dout;
  wire [15:0] fifo_pong_dout;
  
  wire [15:0] frame_compose_ping_dout;
  wire [15:0] frame_compose_pong_dout;
  
  always@(posedge clk or negedge rst_n)
  if(!rst_n)
  stream_last<='d0;
  else if(&rd_cnt[7:0]) //rd_cnt=='d255
    stream_last<='d1;
    else  
     stream_last<='d0;
  assign   memory_rd_en=fifo_ping_rd_en||fifo_pong_rd_en||frame_compose_ping_rd_en||frame_compose_pong_rd_en;
  always@(posedge clk)
    data_in_r<=data_in;
    
  reg [3:0] wr_state='d0;
  localparam IDLE=4'b0000;
  localparam WR_FIRST_PING=4'b0001;
  localparam WR_PONG      =4'b0010;
  localparam WR_PING      =4'b0100;
  
  always@(posedge clk or negedge rst_n)
   if(!rst_n)
      wr_state<=IDLE;
  else begin 
      case(wr_state)
       IDLE:
        if(start)
           wr_state<=WR_FIRST_PING;
        else 
           wr_state<=wr_state;
      WR_FIRST_PING:
        if(fifo_ping_wr_en&&(wr_cnt== fft_point-'d1))
           wr_state<=WR_PONG;
        else 
           wr_state<=wr_state;
      WR_PONG:
        if(fifo_pong_wr_en&&(wr_cnt==waiting_points-'d1))
           wr_state<=WR_PING;
         else 
           wr_state<=wr_state;
      WR_PING:
        if(fifo_ping_wr_en&&(wr_cnt==waiting_points-'d1))
           wr_state<=WR_PONG;        
         else 
           wr_state<=wr_state;
      default:;
      endcase
      end
  
  always@(posedge clk or negedge rst_n)
   if(!rst_n)
   wr_cnt<=0;
  else if((wr_state==WR_FIRST_PING)&&fifo_ping_wr_en&&(wr_cnt==fft_point-'d1))
   wr_cnt<='d0;
  else if((wr_state==WR_PONG)&&fifo_pong_wr_en&&(wr_cnt== waiting_points-'d1))
   wr_cnt<='d0;
  else if((wr_state==WR_PING)&&fifo_ping_wr_en&&(wr_cnt== waiting_points-'d1))
   wr_cnt<='d0;
  else if(fifo_ping_wr_en||fifo_pong_wr_en)
   wr_cnt<=wr_cnt+'d1; 
   
  always@(posedge clk or negedge rst_n)
   if(!rst_n)
     fifo_ping_wr_en<='d0;
   else if((data_in_valid)&&(wr_state==WR_FIRST_PING)&&(wr_cnt== fft_point-'d1)&&fifo_ping_wr_en)
     fifo_ping_wr_en<='d0;
   else if((data_in_valid)&&(wr_state==WR_PING)&&(wr_cnt== waiting_points-'d1)&&fifo_ping_wr_en)
     fifo_ping_wr_en<='d0;       
   else if((data_in_valid&&(wr_state==WR_FIRST_PING))||(data_in_valid&&(wr_state==WR_PING)))
     fifo_ping_wr_en<='d1;     
   else if((data_in_valid)&&(wr_state==WR_PONG)&&(wr_cnt== waiting_points-'d1)&&fifo_pong_wr_en)
     fifo_ping_wr_en<='d1;      
   else       
     fifo_ping_wr_en<='d0;
  

  always@(posedge clk or negedge rst_n)
   if(!rst_n)
     fifo_pong_wr_en<='d0;
   else if((data_in_valid)&&(wr_state==WR_FIRST_PING)&&(wr_cnt==fft_point-'d1)&&fifo_ping_wr_en)
     fifo_pong_wr_en<='d1;   
   else if((data_in_valid)&&(wr_state==WR_PONG)&&(wr_cnt==waiting_points-'d1)&&fifo_pong_wr_en)
     fifo_pong_wr_en<='d0;       
   else if(data_in_valid&&(wr_state==WR_PONG))
     fifo_pong_wr_en<='d1;  
   else if(data_in_valid&&(wr_state==WR_PING)&&(wr_cnt== waiting_points-'d1)&&fifo_ping_wr_en)
     fifo_pong_wr_en<='d1;       
   else       
     fifo_pong_wr_en<='d0;
     
  reg   wr_frame_compose_sig_ping=0;

  always@(posedge clk or negedge rst_n)
     if(!rst_n)
      wr_frame_compose_sig_ping<=0;
   else if((wr_state==WR_FIRST_PING)&&(wr_cnt==waiting_points-'d1)&&fifo_ping_wr_en)
      wr_frame_compose_sig_ping<=1;
   else if((wr_state==WR_FIRST_PING)&&(wr_cnt==fft_point-'d1)&&fifo_ping_wr_en)
      wr_frame_compose_sig_ping<=0;
   else if((wr_state==WR_PING)&&fifo_ping_wr_en&&(wr_cnt==waiting_points_1-'d1))
      wr_frame_compose_sig_ping<=1;
   else if((wr_state==WR_PING)&&fifo_ping_wr_en&&(wr_cnt==waiting_points-'d1))
      wr_frame_compose_sig_ping<=0;
   
  reg   wr_frame_compose_sig_pong=0;

  always@(posedge clk or negedge rst_n)
     if(!rst_n)
      wr_frame_compose_sig_pong<=0;
   else if((wr_state==WR_PONG)&&(wr_cnt==waiting_points_1-'d1)&&fifo_pong_wr_en)
      wr_frame_compose_sig_pong<=1;
   else if((wr_state==WR_PONG)&&(wr_cnt==waiting_points-'d1)&&fifo_pong_wr_en)
      wr_frame_compose_sig_pong<=0;
  
  
  assign  frame_compose_ping_wr_en=(wr_frame_compose_sig_ping)&&(fifo_ping_wr_en);
  assign  frame_compose_pong_wr_en=(wr_frame_compose_sig_pong)&&(fifo_pong_wr_en);    
  
  reg [3:0] rd_state='d0;
  localparam RD_IDLE=4'b0000;
  localparam RD_FIRST_PING=4'b0001;
  localparam RD_PONG      =4'b0010;
  localparam RD_PING      =4'b0100;
  
       reg   ping_rd_en=0;
       reg   pong_rd_en=0;
      reg  rd_first_ping_done;
      reg  rd_ping_done;
      reg  rd_pong_done;
   
   
   
   
  
   always@(posedge clk or negedge rst_n)
     if(!rst_n)
      rd_state<=RD_IDLE;
   else  begin 
    case(rd_state)
	   RD_IDLE:
	     if(fifo_ping_full)
		 rd_state<= RD_FIRST_PING;
        else 		 
          rd_state<=rd_state;
	   RD_FIRST_PING:
        if((fifo_pong_rd_count==waiting_points)&&rd_first_ping_done)	  
		  rd_state<= RD_PONG;
        else 		 
          rd_state<=rd_state;
       RD_PONG:
	    if((fifo_ping_rd_count==waiting_points)&&rd_pong_done)
          rd_state<= RD_PING;
        else 		 
          rd_state<=rd_state;
       RD_PING:
	    if((fifo_pong_rd_count==waiting_points)&&rd_ping_done)
          rd_state<= RD_PONG;
        else 		 
          rd_state<=rd_state;
  default:;
    endcase
	end
	

	  always@(posedge clk or negedge rst_n) 	   
     	 if(!rst_n)
	      rd_cnt<=0;
	   else if((rd_state==RD_FIRST_PING)&&(rd_cnt==fft_point-'d1)&&ping_rd_en)
	      rd_cnt<=0;
	   else if((rd_state==RD_PONG)&&(rd_cnt==fft_point-'d1)&&pong_rd_en)
	      rd_cnt<=0;
	   else if((rd_state==RD_PING)&&(rd_cnt==fft_point-'d1)&&ping_rd_en)
	      rd_cnt<=0;
	   else if(ping_rd_en||pong_rd_en)
	      rd_cnt<=rd_cnt+'d1;
	
	 always@(posedge clk or negedge rst_n) 
	  if(!rst_n)
	     ping_rd_en<=0;
	  else if(fifo_ping_full)
	     ping_rd_en<=1;
	  else if((rd_state==RD_FIRST_PING)&&(rd_cnt==fft_point-'d1)&&ping_rd_en)
	     ping_rd_en<=0;
	  else if((fifo_ping_rd_count==waiting_points)&&rd_pong_done)
         ping_rd_en<=1;
      else if((rd_state==RD_PING)&&(rd_cnt==fft_point-'d1)&&ping_rd_en)
         ping_rd_en<=0;
  
   always@(posedge clk or negedge rst_n) 
	  if(!rst_n)
	     pong_rd_en<=0;
      else if((fifo_pong_rd_count==waiting_points)&&rd_first_ping_done)
	     pong_rd_en<=1; 
	  else if((fifo_pong_rd_count==waiting_points)&&rd_ping_done)	 
		 pong_rd_en<=1; 		 
     else if((rd_state==RD_PONG)&&(rd_cnt==fft_point-'d1)&&pong_rd_en)
         pong_rd_en<=0; 
 
  
   always@(posedge clk or negedge rst_n)
  if(!rst_n)
  rd_first_ping_done<=0;
  else if((rd_state==RD_FIRST_PING)&&(rd_cnt==fft_point-'d1)&&ping_rd_en)
  rd_first_ping_done<=1;
  else  if((fifo_pong_rd_count==waiting_points)&&rd_first_ping_done)
   rd_first_ping_done<=0;
   
  always@(posedge clk or negedge rst_n)  
    if(!rst_n)
     rd_ping_done<=0;
    else if((rd_state==RD_PING)&&(rd_cnt==fft_point-'d1)&&ping_rd_en)  
     rd_ping_done<=1;
    else if((fifo_pong_rd_count==waiting_points)&&rd_ping_done)
     rd_ping_done<=0;
   
   
   always@(posedge clk or negedge rst_n)  
    if(!rst_n) 
    rd_pong_done<=0;
    else if((rd_state==RD_PONG)&&(rd_cnt==fft_point-'d1)&&pong_rd_en)  
    rd_pong_done<=1; 
    else if((fifo_ping_rd_count==waiting_points)&&rd_pong_done)
    rd_pong_done<=0;
   
   reg fifo_sel_ping=0;
   reg fifo_sel_pong=0;
   
   always@(posedge clk or negedge rst_n)  
   if(!rst_n)
      fifo_sel_ping<=0;
 
   else if((fifo_ping_rd_count==waiting_points)&&rd_pong_done)
      fifo_sel_ping<=1;
   else if((rd_state==RD_PING)&&(rd_cnt==data_compose-'d1)&&ping_rd_en)
      fifo_sel_ping<=0;
   
   always@(posedge clk or negedge rst_n)  
   if(!rst_n)
      fifo_sel_pong<=0;
   else if((fifo_pong_rd_count==waiting_points)&&rd_first_ping_done)  
      fifo_sel_pong<=1;         
   else if((fifo_pong_rd_count==waiting_points)&&rd_ping_done)
      fifo_sel_pong<=1;
   else if((rd_state==RD_PONG)&&(rd_cnt==data_compose-'d1)&&pong_rd_en)
      fifo_sel_pong<=0;
   
    assign fifo_ping_rd_en         =(!fifo_sel_ping)&&ping_rd_en ; 
    assign fifo_pong_rd_en         =(!fifo_sel_pong)&&pong_rd_en ; 
    assign frame_compose_ping_rd_en=(fifo_sel_pong)&&pong_rd_en ;
    assign frame_compose_pong_rd_en=(fifo_sel_ping)&&ping_rd_en ;
    
    
     
    reg  fifo_ping_rd_en_r;         
    reg  fifo_pong_rd_en_r;         
    reg  frame_compose_ping_rd_en_r;
    reg  frame_compose_pong_rd_en_r;
   
    assign data_out_valid=fifo_ping_rd_en_r||fifo_pong_rd_en_r||frame_compose_ping_rd_en_r||frame_compose_pong_rd_en_r;
    
    always@(posedge clk)
	begin
	fifo_ping_rd_en_r         <=fifo_ping_rd_en         ;         
	fifo_pong_rd_en_r         <=fifo_pong_rd_en         ;         
	frame_compose_ping_rd_en_r<=frame_compose_ping_rd_en;
	frame_compose_pong_rd_en_r<=frame_compose_pong_rd_en;
   end
   
   assign data_out=((fifo_ping_rd_en_r)?fifo_ping_dout:'d0)|((fifo_pong_rd_en_r)?fifo_pong_dout:'d0)|((frame_compose_ping_rd_en_r)?frame_compose_ping_dout:'d0)|((frame_compose_pong_rd_en_r)?frame_compose_pong_dout:'d0);
   
 
   
   
   
  fifo_ping_0  fifo_ping_0_1
  (
  .clk        (     clk                 ),    //: IN STD_LOGIC;
  .srst       (     ~rst_n              ),
  .din        (   data_in_r             ),    //: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
  .wr_en      (       fifo_ping_wr_en   ),    //: IN STD_LOGIC;
  .rd_en      (       fifo_ping_rd_en   ),    //: IN STD_LOGIC;
  .dout       (     fifo_ping_dout      ),    //: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
  .full       (     fifo_ping_full      ),    //: OUT STD_LOGIC;
  .empty      (     fifo_ping_empty     ),    //: OUT STD_LOGIC;
  .data_count (    fifo_ping_rd_count   )     //: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
);
  
  fifo_pong_0 fifo_pong_0_1
  (
  .clk        (       clk             ),    //: IN STD_LOGIC;
  .srst       (      ~rst_n           ),
  .din        (  data_in_r            ),    //: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
  .wr_en      (     fifo_pong_wr_en   ),    //: IN STD_LOGIC;
  .rd_en      (     fifo_pong_rd_en   ),    //: IN STD_LOGIC;
  .dout       (    fifo_pong_dout     ),    //: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
  .full       (    fifo_pong_full     ),    //: OUT STD_LOGIC;
  .empty      (    fifo_pong_empty    ),    //: OUT STD_LOGIC;
  .data_count (    fifo_pong_rd_count )     //: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
);
  
  
  
frame_compose_ping    frame_compose_ping_0
   (
  .clk         (       clk                 ),      //: IN STD_LOGIC;
  .srst        (~rst_n                     ),
  .din         (  data_in_r                ),      //: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
  .wr_en       (frame_compose_ping_wr_en   ),      //: IN STD_LOGIC;
  .rd_en       (frame_compose_ping_rd_en   ) ,      //: IN STD_LOGIC;
  .dout        (frame_compose_ping_dout    ),      //: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
  .full        (frame_compose_ping_full    ),      //: OUT STD_LOGIC;
  .empty       (frame_compose_ping_empty   ),      //: OUT STD_LOGIC;
  .data_count  (frame_compose_ping_rd_count)      //: OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
);    
  
  
  
 frame_compose_pong    frame_compose_pong_0
   (
  .clk         (       clk                      ),      //: IN STD_LOGIC;
  .srst        (     ~rst_n                     ),
  .din         (       data_in_r                ),      //: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
  .wr_en       (    frame_compose_pong_wr_en    ),      //: IN STD_LOGIC;
  .rd_en       (    frame_compose_pong_rd_en    ),      //: IN STD_LOGIC;
  .dout        (    frame_compose_pong_dout     ),      //: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
  .full        (    frame_compose_pong_full     ),      //: OUT STD_LOGIC;
  .empty       (    frame_compose_pong_empty    ),      //: OUT STD_LOGIC;
  .data_count  (    frame_compose_pong_rd_count )      //: OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
);    
  
  endmodule