`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/19 18:13:52
// Design Name: 
// Module Name: config_rom
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


module config_rom(
input   clk,
   input   rst_n,
   input   spi_write_end,
   input   spi_read_end,  
   input [7:0] sp,
   input  sp_valid,
   output reg sp_ready=1'b1,
   output reg [21:0]  data_out,
   output reg         data_out_vld
   );
   reg  [21:0] config_dat [0:20];
 //  initial  begin
 //  //power_on_rst
 //  config_dat[0]={1'b1,13'h000,8'h18};
 //  config_dat[1]={1'b0,13'h000,8'h18}; 
 //  //channel setting
 //  config_dat[2]={1'b1,13'h005,8'h03};
 //  config_dat[3]={1'b0,13'h005,8'h03};    
 // // config_dat[4]={1'b1,13'h0FF,8'h01};  
 // // config_dat[5]={1'b0,13'h0FF,8'h01};  
 // //duty cycle stable 
 //  config_dat[4]={1'b1,13'h009,8'h01};
 // // config_dat[7]={1'b0,13'h009,8'h01};  
 // //output mode£ºbinary complement cmos1.8v
 //  config_dat[5]={1'b1,13'h014,8'h81};
 //  
 ////  config_dat[9]={1'b0,13'h014,8'h80};  
 ////output delay set
 //  config_dat[6]={1'b1,13'h017,8'h00};
 //  //config_dat[11]={1'b0,13'h017,8'h00};
 // //chip work mode set   
 //  config_dat[7]={1'b1,13'h008,8'h80};
 // // config_dat[13]={1'b0,13'h008,8'h00};   
 //  config_dat[8]={1'b1,13'h0FF,8'h01};  
 //  config_dat[9]={1'b0,13'h0FF,8'h01};   
 //  config_dat[10]={1'b0,13'h009,8'h01};   
 //  config_dat[11]={1'b0,13'h014,8'h80};    
 //  config_dat[12]={1'b0,13'h017,8'h00};   
 //  config_dat[13]={1'b0,13'h008,8'h00};   
 // //BIST_test
 //  config_dat[14]={1'b1,13'h00E,8'h05};   
 //  config_dat[15]={1'b1,13'h0FF,8'h01}; 
 //  //scan bist_test result
 //  config_dat[16]={1'b0,13'h024,8'h01}; 
 //   // 
 //  end
 
  initial  begin
   //power_on_rst
   config_dat[0]={1'b1,13'h000,8'h18};
   config_dat[1]={1'b0,13'h000,8'h18}; 
   //channel setting
   config_dat[2]={1'b1,13'h005,8'h03};
   config_dat[3]={1'b0,13'h005,8'h03};    
  // config_dat[4]={1'b1,13'h0FF,8'h01};  
  // config_dat[5]={1'b0,13'h0FF,8'h01};  
  //duty cycle stable 
   config_dat[4]={1'b1,13'h009,8'h01};
   config_dat[5]={1'b1,13'h0FF,8'h01};  
  // config_dat[7]={1'b0,13'h009,8'h01};  
  //output mode£ºbinary complement cmos1.8v
   config_dat[6]={1'b1,13'h014,8'h81};
   config_dat[7]={1'b1,13'h0FF,8'h01};  
 //  config_dat[9]={1'b0,13'h014,8'h80};  
 //output delay set
   config_dat[8]={1'b1,13'h017,8'h00};
   config_dat[9]={1'b1,13'h0FF,8'h01};  
   //config_dat[11]={1'b0,13'h017,8'h00};
  //chip work mode set   
   config_dat[10]={1'b1,13'h008,8'h80};
  // config_dat[13]={1'b0,13'h008,8'h00};   
   config_dat[11]= {1'b1,13'h0FF,8'h01};  
   config_dat[12]= {1'b0,13'h0FF,8'h01};   
   config_dat[13]={1'b0,13'h009,8'h01};  
   config_dat[14]={1'b0,13'h014,8'h80};    
   config_dat[15]={1'b0,13'h017,8'h00};   
   config_dat[16]={1'b0,13'h008,8'h00};   
  //BIST_test
   config_dat[17]={1'b1,13'h00E,8'h05};   
   config_dat[18]={1'b1,13'h0FF,8'h01}; 
   //scan bist_test result
   config_dat[19]={1'b0,13'h024,8'h01}; 
    // 
   end
 
 always@(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
    sp_ready<=1;
 else  if((spi_write_end||spi_read_end)&&(sp==7'd20))
    sp_ready<=0;
 else  if(spi_write_end||spi_read_end)
    sp_ready<=1;		
  else  if(sp_valid)
    sp_ready<=0;
  else
    sp_ready<=sp_ready;
	
	
  always@(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
  begin
  data_out_vld<=0;
  end
  else  if(sp_ready&&sp_valid)
    data_out_vld<=1;		
  else
     data_out_vld<=0;
	 
  always@(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
  data_out<=0;
  else  if(sp_ready&&sp_valid)
  data_out<=config_dat[sp];		
  else
   data_out<=data_out;	 
	 
	 endmodule