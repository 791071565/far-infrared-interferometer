`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/19 18:14:28
// Design Name: 
// Module Name: spi_config
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


module spi_config(
input   clk,
input   rst_n,                  
//interface
 (*mark_debug = "true"*) output reg     CSB,
 (*mark_debug = "true"*) output reg     SCLK,
inout          SDIO,
input  [5:0]   div_cnt,
//user_logic
input                   spi_write_en_i,
input       [7:0]       spi_data_write_i,
input       [12:0]      spi_data_addr_i,
input                   spi_read_en_i,
(*mark_debug = "true"*)output                  spi_write_end,
(*mark_debug = "true"*)output                  spi_read_end ,
output reg  [7:0]       spi_data_read,
output  reg  spi_write
);  


(*mark_debug = "true"*) reg  spi_work;
(*mark_debug = "true"*)  reg  spi_data_out=0;   
(*mark_debug = "true"*) wire  spi_start_work;
assign spi_start_work=spi_write_en_i||spi_read_en_i;
assign  SDIO=(!spi_write)?spi_data_out:1'bz;
reg  spi_start_work_r;
(*mark_debug = "true"*)reg [5:0] cnt_divide;
(*mark_debug = "true"*)reg   spi_work_end;
 (*mark_debug = "true"*) reg   [9:0]  cnt_half_bit;

(*mark_debug = "true"*)reg  spi_rw_state;  //0-read  1-write
reg  [7:0]       spi_data_write; 
reg  [12:0]      spi_data_addr;
assign  spi_write_end=(spi_rw_state)?spi_work_end:1'b0;
assign  spi_read_end=(!spi_rw_state)?spi_work_end:1'b0;

always@(posedge clk or negedge rst_n)
 if(rst_n == 1'b0)
spi_start_work_r<=0;
else  spi_start_work_r<=spi_start_work;







always@(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
  begin
   spi_write<=0;
  end
 else  if(spi_work_end)
  begin
   spi_write<=0;
  end 
else  if((!spi_rw_state)&&(cnt_half_bit==10'd31)&&(cnt_divide==div_cnt-1'b1))
  begin
   spi_write<=1;
  end 
else  
    begin
   spi_write<=spi_write;
    end 


always@(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
  begin
  spi_data_write<=0; 
  spi_data_addr <=0;
  end
else  if(spi_start_work)
  begin
  spi_data_write<=spi_data_write_i; 
  spi_data_addr <=spi_data_addr_i ;
  end 
else  
    begin
    spi_data_write<=spi_data_write; 
    spi_data_addr <=spi_data_addr;
    end 
   
always@(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
   spi_work<=1'd0;  
  else if(spi_work_end)
     spi_work<=1'd0; 
   else  if(spi_write_en_i||spi_read_en_i)
  spi_work<=1'd1; 
  else
  spi_work<=spi_work;

   
 always@(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
   spi_rw_state<=1'd0;  
  else  if(spi_read_en_i)
  spi_rw_state<=1'd0; 
   else  if(spi_write_en_i)
  spi_rw_state<=1'd1; 
  else
  spi_rw_state<=spi_rw_state;  
   
   
   
always@(posedge clk or negedge rst_n)
  if((rst_n == 1'b0)||(spi_work_end))
   cnt_divide<=0;
  else  if(cnt_divide==div_cnt-1)
   cnt_divide<=0;
  else  if((spi_work)||spi_start_work_r)
   cnt_divide<=cnt_divide+1'b1;
  else
   cnt_divide<=0;
  
 always@(posedge clk or negedge rst_n)
  if((rst_n == 1'b0)||(spi_work_end))
   SCLK<=0;
  else  if(cnt_divide==div_cnt-1)
   SCLK<=~SCLK;
  else
   SCLK<=SCLK;
  
 always@(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
   CSB<=1;
  else if((cnt_half_bit==10'd48)&&(cnt_divide==4'd4-1'b1)) 
   CSB<=1;
  else  if(spi_start_work)
   CSB<=0;
  else
   CSB<=CSB; 
  

  
  always@(posedge clk or negedge rst_n)
  if((rst_n == 1'b0)||(spi_work_end))
   cnt_half_bit<=10'd0;  
  else  if(cnt_divide==div_cnt-1)
   cnt_half_bit<=cnt_half_bit+1'b1;
  else
   cnt_half_bit<=cnt_half_bit;
  
  always@(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
   spi_work_end<=1'd0;  
  else  if((cnt_half_bit==10'd48)&&(cnt_divide==div_cnt-2'd2))
   spi_work_end<=1'd1;
  else
   spi_work_end<=1'd0;  
  
  always@(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
      spi_data_out<=0;
  else if(spi_start_work)
      spi_data_out<=(spi_read_en_i)?1'b1:1'b0;  //R/W
  else  if(cnt_divide==div_cnt-1)
      case(cnt_half_bit)
	  10'd1:spi_data_out<=0;  //0
      10'd3:spi_data_out<=0;  //0
      10'd5:spi_data_out<= spi_data_addr[12];   //adress13
      10'd7:spi_data_out<= spi_data_addr[11];   //adress12
      10'd9:spi_data_out<=spi_data_addr[10];   //adress11
      10'd11:spi_data_out<=spi_data_addr[9];  //adress10
      10'd13:spi_data_out<=spi_data_addr[8];  //adress9
      10'd15:spi_data_out<=spi_data_addr[7];  //adress8
      10'd17:spi_data_out<=spi_data_addr[6];  //adress7
      10'd19:spi_data_out<=spi_data_addr[5];  //adress6
	  10'd21:spi_data_out<=spi_data_addr[4];  //adress5
	  10'd23:spi_data_out<=spi_data_addr[3];  //adress4
	  10'd25:spi_data_out<=spi_data_addr[2];  //adress3
	  10'd27:spi_data_out<=spi_data_addr[1];  //adress2
	  10'd29:spi_data_out<=spi_data_addr[0];  //adress1
	  10'd31:spi_data_out<=spi_data_write[7];  //data8
      10'd33:spi_data_out<=spi_data_write[6];  //data7
      10'd35:spi_data_out<=spi_data_write[5];  //data6
	  10'd37:spi_data_out<=spi_data_write[4];  //data5
	  10'd39:spi_data_out<=spi_data_write[3];  //data4
	  10'd41:spi_data_out<=spi_data_write[2];  //data3
	  10'd43:spi_data_out<=spi_data_write[1];  //data2
	  10'd45:spi_data_out<=spi_data_write[0];  //data1	  
	  default:;
	  endcase  
	  
	  
	always@(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
      spi_data_read<=8'b0;
  else  if((cnt_divide==div_cnt-1'b1)&&(!spi_rw_state))
      case(cnt_half_bit)	 
	  10'd32:spi_data_read<={spi_data_read[6:0],SDIO};  //data8
      10'd34:spi_data_read<={spi_data_read[6:0],SDIO};  //data7
      10'd36:spi_data_read<={spi_data_read[6:0],SDIO};  //data6
	  10'd38:spi_data_read<={spi_data_read[6:0],SDIO};  //data5
	  10'd40:spi_data_read<={spi_data_read[6:0],SDIO}; //data4
	  10'd42:spi_data_read<={spi_data_read[6:0],SDIO};  //data3
	  10'd44:spi_data_read<={spi_data_read[6:0],SDIO};  //data2
	  10'd46:spi_data_read<={spi_data_read[6:0],SDIO};  //data1	  
	  default:;
	  endcase    
	  
	  
	  
  endmodule
