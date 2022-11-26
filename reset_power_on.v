`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/19 17:25:22
// Design Name: 
// Module Name: reset_power_on
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


module reset_power_on(
	input              clk,
input              user_rst,          //user reset, high active
output             power_on_rst       //power on reset,high active     
);
//// ---------------- internal constants --------------
parameter N = 32 ;             // debounce timer bitwidth
parameter FREQ = 50;           //model clock :Mhz
parameter MAX_TIME = 200;      //ms
localparam TIMER_MAX_VAL =   MAX_TIME * 1000 * FREQ;

reg[N - 1:0] cnt = 0;
reg rst_reg;
assign power_on_rst = rst_reg;
always@(posedge clk or posedge user_rst)
begin
if(user_rst == 1'b1)
    cnt <= 0;
else if(cnt < TIMER_MAX_VAL)
    cnt <= cnt + 1;
else
    cnt <= cnt;
end
always@(posedge clk)
rst_reg <= (cnt < TIMER_MAX_VAL) ? 1'b0 : 1'b1;
endmodule 
