`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/19 17:37:02
// Design Name: 
// Module Name: spi_config_top
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


module spi_config_top(
 input   clk,
input   rst_n,                  
//interface
output     CSB,
output     SCLK,
inout          SDIO,
output  reg      adc_initial_finish,
output          spi_write,
input     trig
);

parameter  div_cnt=6'd8;
//user_logic
wire                  spi_write_en_i   ;
(*mark_debug = "true"*)wire       [7:0]      spi_data_write_i ;
(*mark_debug = "true"*)wire       [12:0]     spi_data_addr_i  ;
//same time
wire                  spi_read_en_i    ;
(*mark_debug = "true"*)wire                  spi_write_end    ;
(*mark_debug = "true"*)wire                  spi_read_end     ;

 (*mark_debug = "true"*)wire  [7:0]           spi_data_read    ;

(*mark_debug = "true"*)reg  [7:0] sp;
 (*mark_debug = "true"*)reg        sp_valid;
 (*mark_debug = "true"*)wire       sp_ready;
 (*mark_debug = "true"*)wire       data_out_vld;
 (*mark_debug = "true"*)wire       rd_write_sig;
always@(posedge clk or negedge rst_n)
 if(rst_n == 1'b0)
   sp_valid<=0;
  //else  if((sp_ready)&&(trig))
 else  if(sp_ready)
   sp_valid<=1;
 else
   sp_valid<=0;

always@(posedge clk or negedge rst_n)
 if(rst_n == 1'b0)
   sp<=0;
 else  if(sp_valid&&sp_ready)
   sp<=sp+1;
 else
   sp<=sp;

   
always@(posedge clk or negedge rst_n)
 if(rst_n == 1'b0)
   adc_initial_finish<=0;
 else  if((spi_write_end||spi_read_end)&&(sp==7'd7))
   adc_initial_finish<=1;
   
   
config_rom config_rom_0(
   .clk          (clk          ),                       //input             
   .rst_n        (rst_n        ),                     //input             
   .spi_write_end(spi_write_end),             //input             
   .spi_read_end (spi_read_end ),               //input             
   .sp           (sp           ),                        //input [7:0]       
   .sp_valid     (sp_valid),                  //input             
   .sp_ready     (sp_ready),                  //output reg        
   .data_out     ({rd_write_sig,spi_data_addr_i,spi_data_write_i}),                  //output reg [21:0] 
   .data_out_vld ( data_out_vld)                   //output reg        
  );    
   
   
   
  assign spi_write_en_i= (data_out_vld)?rd_write_sig:1'b0; 
   
   assign spi_read_en_i= (data_out_vld)?(~rd_write_sig):1'b0; 
   
   
   
spi_config spi_config_0(
.  clk              ( clk              ),
.  rst_n            ( rst_n            ),                  
.  CSB              ( CSB              ),
.  SCLK             ( SCLK             ),
.  SDIO             ( SDIO             ),
.  div_cnt          ( div_cnt          ),
.  spi_write_en_i   ( spi_write_en_i   ),
.  spi_data_write_i ( spi_data_write_i ),
.  spi_data_addr_i  ( spi_data_addr_i  ),
.  spi_read_en_i    ( spi_read_en_i    ),
.  spi_write_end    ( spi_write_end    ),
.  spi_read_end     ( spi_read_end     ),
.  spi_data_read    ( spi_data_read    ) ,
   .spi_write     (spi_write     )                        
);  

endmodule

