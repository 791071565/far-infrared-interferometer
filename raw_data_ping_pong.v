`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/31 13:23:35
// Design Name: 
// Module Name: raw_data_ping_pong
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


module raw_data_ping_pong(
input         rst_n                       ,
  input         clk                         ,
   
  input [31:0]  ffted_data_CHA_RE           ,
  input [31:0]  ffted_data_CHA_IM           ,
  input         ffted_data_CHA_en           , 
  input         ffted_data_CHA_last         ,
 //reference channel                        
  input [31:0]  ffted_data_CHB_RE           ,
  input [31:0]  ffted_data_CHB_IM           ,
  input         ffted_data_CHB_en           , 
  input         ffted_data_CHB_last         ,
   
  input         rd_en,
   input [7:0] rd_addr,
  output   reg  CHA_RE_IM_DATA_valid=0, 
  output [63:0] CHA_RE_IM_DATA,
  output   reg  CHA_RE_IM_DATA_last='d0,
  (* DONT_TOUCH= "YES" *)output   reg  CHB_RE_IM_DATA_valid=0, 
  output [63:0] CHB_RE_IM_DATA, 
  output   reg  CHB_RE_IM_DATA_last='d0, 
  output        rd_start_ready    
   );
    always@(posedge clk or negedge rst_n)
      if(!rst_n)
      begin
      CHA_RE_IM_DATA_last<='d0;
     CHB_RE_IM_DATA_last <='d0;
      end
      else if(rd_addr=='d255)
      begin
          CHA_RE_IM_DATA_last<='d1;
         CHB_RE_IM_DATA_last <='d1;
          end  
     else        
       begin
         CHA_RE_IM_DATA_last<='d0;
        CHB_RE_IM_DATA_last <='d0;
         end     
          
          
       
   always@(posedge clk)
    begin
    CHA_RE_IM_DATA_valid<=rd_en;
    CHB_RE_IM_DATA_valid<=rd_en;     
    end

   reg   wr_ping_pong_sig=0;     //0 ping 1 pong
 always@(posedge clk or negedge rst_n)
  if(!rst_n)
    wr_ping_pong_sig<='d0;
  else if(ffted_data_CHA_last)
    wr_ping_pong_sig<=~wr_ping_pong_sig;
    
   wire empty_ping_posedge; 
   
   wire empty_pong_posedge; 
   
   reg   rd_ping_pong_sig=0;     //0 ping 1 pong    
 always@(posedge clk or negedge rst_n)
  if(!rst_n)
    rd_ping_pong_sig<='d0;
  else if(empty_ping_posedge||empty_pong_posedge)
    rd_ping_pong_sig<=~rd_ping_pong_sig;    
   
   
   
   
   wire [31:0] CHA_ping_data_RE;
   wire [31:0] CHA_ping_data_IM;
   
   wire [31:0] CHA_pong_data_RE;
   wire [31:0] CHA_pong_data_IM;
   
   wire [31:0] CHB_ping_data_RE;
   wire [31:0] CHB_ping_data_IM;
   
   wire [31:0] CHB_pong_data_RE;
   wire [31:0] CHB_pong_data_IM;
   
   assign   CHA_RE_IM_DATA=(~rd_ping_pong_sig)?({CHA_ping_data_RE,CHA_ping_data_IM}):({CHA_pong_data_RE,CHA_pong_data_IM});
   assign   CHB_RE_IM_DATA=(~rd_ping_pong_sig)?({CHB_ping_data_RE,CHB_ping_data_IM}):({CHB_pong_data_RE,CHB_pong_data_IM});
   
  (*mark_debug = "true"*) wire   empty_ping;
  (*mark_debug = "true"*) wire   empty_pong;
  (*mark_debug = "true"*) wire   empty_ping_1;
  (*mark_debug = "true"*) wire   empty_pong_1;
  
  
   wire   full_ping;
   wire   full_pong;
   wire   full_ping_posedge;
   wire   full_pong_posedge;
   
   assign  rd_start_ready=full_ping_posedge||full_pong_posedge;
RE_IM_DATA_STORAGE_BUFFER RE_IM_DATA_STORAGE_BUFFER_0(
   .clk       (  clk              ), //: IN STD_LOGIC;
   .srst      (  ~rst_n              ), //: IN STD_LOGIC;
   .din       ({ffted_data_CHA_RE,ffted_data_CHA_IM}), //: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
   .wr_en     ((!wr_ping_pong_sig)?ffted_data_CHA_en:1'b0), //: IN STD_LOGIC;
   .rd_en     ((!rd_ping_pong_sig)?rd_en:1'b0  ), //: IN STD_LOGIC;
   .dout      ({CHA_ping_data_RE,CHA_ping_data_IM}), //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
   .full      (  full_ping          ), //: OUT STD_LOGIC;
   .empty     (  empty_ping          ), //: OUT STD_LOGIC;
   .data_count(                      )  //: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
   );   //this buffer stores  CHA,ping storage


RE_IM_DATA_STORAGE_BUFFER RE_IM_DATA_STORAGE_BUFFER_1(
   .clk       (  clk                 ), //: IN STD_LOGIC;
   .srst      (  ~rst_n              ), //: IN STD_LOGIC;
   .din       ({ffted_data_CHA_RE,ffted_data_CHA_IM}), //: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
   .wr_en     ((wr_ping_pong_sig)?ffted_data_CHA_en:1'b0), //: IN STD_LOGIC;
   .rd_en     ((rd_ping_pong_sig)?rd_en:1'b0 ), //: IN STD_LOGIC;
   .dout      ({CHA_pong_data_RE,CHA_pong_data_IM}), //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
   .full      ( full_pong          ), //: OUT STD_LOGIC;
   .empty     (  empty_pong          ), //: OUT STD_LOGIC;
   .data_count(                      )  //: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
   );  //this buffer stores  CHA,pong storage

RE_IM_DATA_STORAGE_BUFFER RE_IM_DATA_STORAGE_BUFFER_2(
   .clk       (  clk                 ), //: IN STD_LOGIC;
   .srst      (  ~rst_n              ), //: IN STD_LOGIC;
   .din       ({ffted_data_CHB_RE,ffted_data_CHB_IM}), //: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
   .wr_en     ((!wr_ping_pong_sig)?ffted_data_CHB_en:1'b0), //: IN STD_LOGIC;
   .rd_en     ((!rd_ping_pong_sig)?rd_en:1'b0), //: IN STD_LOGIC;
   .dout      ({CHB_ping_data_RE,CHB_ping_data_IM}), //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
   .full      (                      ), //: OUT STD_LOGIC;
   .empty     ( empty_ping_1         ), //: OUT STD_LOGIC;
   .data_count(                      )  //: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
   );   //this buffer stores  CHB,ping storage


RE_IM_DATA_STORAGE_BUFFER RE_IM_DATA_STORAGE_BUFFER_3(
   .clk       (  clk                 ), //: IN STD_LOGIC;
   .srst      (  ~rst_n              ), //: IN STD_LOGIC;
   .din       ({ffted_data_CHB_RE,ffted_data_CHB_IM}), //: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
   .wr_en     ((wr_ping_pong_sig)?ffted_data_CHB_en:1'b0), //: IN STD_LOGIC;
   .rd_en     ((rd_ping_pong_sig)?rd_en:1'b0), //: IN STD_LOGIC;
   .dout      ({CHB_pong_data_RE,CHB_pong_data_IM}), //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
   .full      (                      ), //: OUT STD_LOGIC;
   .empty     (  empty_pong_1      ), //: OUT STD_LOGIC;
   .data_count(                      )  //: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
   );  //this buffer stores  CHB,pong storage
   
   
    low_frequency_edge_detect low_frequency_edge_detect_0(
         .clk           (  clk               ),
         .signal_in     (  empty_ping            ),
         .signal_posedge( empty_ping_posedge     ),
         .signal_negedge(                        )
         );
   
   
   low_frequency_edge_detect low_frequency_edge_detect_1(
         .clk           (  clk               ),
         .signal_in     (  empty_pong            ),
         .signal_posedge( empty_pong_posedge     ),
         .signal_negedge(                        )
         );
   
   low_frequency_edge_detect low_frequency_edge_detect_2(
                .clk           (  clk               ),
                .signal_in     ( full_ping            ),
                .signal_posedge( full_ping_posedge     ),
                .signal_negedge(                        )
                );
          
          
          low_frequency_edge_detect low_frequency_edge_detect_3(
                .clk           (  clk               ),
                .signal_in     ( full_pong            ),
                .signal_posedge( full_pong_posedge     ),
                .signal_negedge(                        )
                );  
   
   
   
endmodule

