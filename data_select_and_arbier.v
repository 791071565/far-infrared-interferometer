`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/31 21:07:50
// Design Name: 
// Module Name: data_select_and_arbier
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


module data_select_and_arbier(
 input		wire		   clk,
 input        wire           rst_n,
 input        [2:0]    ferquency_mode,
 input        wire[31:0]     PHASE_out_f1,
 input        wire           PHASE_out_EN_f1,
 input        wire[31:0]     PHASE_out_f2,
 input        wire           PHASE_out_EN_f2,
 input        wire[31:0]     PHASE_out_f3,
 input        wire           PHASE_out_EN_f3, 
 output       reg [127:0]     PHASE_out_to_PCIE=0,
 output       reg             PHASE_out_to_PCIE_en=0
);





  reg  mode_control=0;
  
  reg  fifo_rd_en_0=0;
  reg  fifo_rd_en_1=0;    
  reg  fifo_rd_en_2=0;    
  wire [6:0] rd_data_count;
  wire [127:0] dout_0;
  reg  dout_0_en=0;  
  wire [127:0] dout_1;
  reg  dout_1_en=0; 
  wire [127:0] dout_2;
  reg  dout_2_en=0; 
  
  
  
  
  
always@(posedge clk or negedge rst_n)
    if(!rst_n)
    begin   
    mode_control<='d0;
    end
    else if(ferquency_mode=='d00)
    begin   
     mode_control<='d0;
    end    
    else if(ferquency_mode=='d01)
    begin   
     mode_control<='d1;
    end   
    reg [1:0] rd_sel='b00;
    reg  [1:0] shift_cnt='d0;//0 1 2 3
    always@(posedge clk or negedge rst_n)
      if(!rst_n)
        shift_cnt<='d0;
        
      else if(PHASE_out_EN_f1)
        shift_cnt<=shift_cnt+'d1;
    
always@(posedge clk or negedge rst_n)
    if(!rst_n)
    begin   
    PHASE_out_to_PCIE<='d0;
    PHASE_out_to_PCIE_en<='d0;
    end
    else if(~mode_control)
    if(PHASE_out_EN_f1)
    begin
      PHASE_out_to_PCIE<={PHASE_out_to_PCIE[95:0],PHASE_out_f1};
      PHASE_out_to_PCIE_en<=(&shift_cnt)?1'b1:1'b0;
      end
     else
      begin   
       PHASE_out_to_PCIE<=PHASE_out_to_PCIE;
       PHASE_out_to_PCIE_en<='d0;
       end 
    else if(mode_control)  
     begin  
 case( rd_sel )
     2'b01:begin
     PHASE_out_to_PCIE<=dout_0;
     PHASE_out_to_PCIE_en<=dout_0_en;
           end
     
     2'b10:begin
        PHASE_out_to_PCIE<=dout_1;    
        PHASE_out_to_PCIE_en<=dout_1_en;    
           end
     
     
     2'b00:begin
          PHASE_out_to_PCIE<=dout_2;  
          PHASE_out_to_PCIE_en<=dout_2_en;  
           end
     
     
     default:;
     endcase
   
       end 
       
  else  begin

       PHASE_out_to_PCIE<=PHASE_out_to_PCIE;
       PHASE_out_to_PCIE_en<='d0;

end    
       
       
  wire     fifo_rd_en_0_posedge;
   

  wire  empty;
  always@(posedge clk or negedge rst_n)
    if(!rst_n)
    rd_sel<='b00;
    else if(fifo_rd_en_0_posedge)
    rd_sel<='b01;
    else if(fifo_rd_en_1)
    rd_sel<='b10;
    else if(fifo_rd_en_2)
    rd_sel<='b00;
   always@(posedge clk or negedge rst_n)
    if(!rst_n)
      fifo_rd_en_0<='d0;
  else if((!empty)&&(rd_sel=='b00)&&mode_control )
      fifo_rd_en_0<='d1;
  else  
      fifo_rd_en_0<='d0;
   always@(posedge clk or negedge rst_n)
    if(!rst_n)
      fifo_rd_en_1<='d0;
  else if(fifo_rd_en_0_posedge&&(rd_sel=='b00))
      fifo_rd_en_1<='d1;
  else  
      fifo_rd_en_1<='d0;    
   always@(posedge clk or negedge rst_n)
    if(!rst_n)
      fifo_rd_en_2<='d0;
  else if(fifo_rd_en_1&&(rd_sel=='b01))
      fifo_rd_en_2<='d1;
  else  
      fifo_rd_en_2<='d0;    
   always@(posedge clk)
 begin
   dout_0_en<=fifo_rd_en_0_posedge;
   dout_1_en<=fifo_rd_en_1;
   dout_2_en<=fifo_rd_en_2;
  end   
      
      
      
  
data_reshape_fifo data_reshape_fifo_0(
  .clk           (     clk                          ),     //: IN STD_LOGIC;
  .srst          (     ~rst_n                       ),     //: IN STD_LOGIC;
  .din           (   PHASE_out_f1                   ),     //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  .wr_en         (  PHASE_out_EN_f1&&mode_control              ),     //: IN STD_LOGIC;
  .rd_en         (   fifo_rd_en_0_posedge                   ),     //: IN STD_LOGIC;
  .dout          (    dout_0                      ),     //: OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
  .full          (                                  ),     //: OUT STD_LOGIC;
  .empty         (  empty                    ),     // : OUT STD_LOGIC;
  .rd_data_count (  rd_data_count               )     //   : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
);
data_reshape_fifo data_reshape_fifo_1(
  .clk           (     clk                          ),     //: IN STD_LOGIC;
  .srst          (     ~rst_n                       ),     //: IN STD_LOGIC;
  .din           (   PHASE_out_f2                   ),     //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  .wr_en         (   PHASE_out_EN_f2 &&mode_control              ),     //: IN STD_LOGIC;
  .rd_en         (   fifo_rd_en_1                    ),     //: IN STD_LOGIC;
  .dout          (    dout_1                       ),     //: OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
  .full          (                                  ),     //: OUT STD_LOGIC;
  .empty         (                                  ),     // : OUT STD_LOGIC;
  .rd_data_count (                 )     //   : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
);
data_reshape_fifo data_reshape_fifo_2(
  .clk           (     clk                          ),     //: IN STD_LOGIC;
  .srst          (     ~rst_n                       ),     //: IN STD_LOGIC;
  .din           (   PHASE_out_f3                   ),     //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  .wr_en         (   PHASE_out_EN_f3 &&mode_control     ),     //: IN STD_LOGIC;
  .rd_en         (   fifo_rd_en_2                   ),     //: IN STD_LOGIC;
  .dout          (    dout_2                     ),     //: OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
  .full          (                                  ),     //: OUT STD_LOGIC;
  .empty         (                                  ),     // : OUT STD_LOGIC;
  .rd_data_count (                 )     //   : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
);

low_frequency_edge_detect low_frequency_edge_detect_0(
         .clk           (  clk                 ),
         .signal_in     (  fifo_rd_en_0            ),
         .signal_posedge( fifo_rd_en_0_posedge                         ),
         .signal_negedge(      )
         );





endmodule