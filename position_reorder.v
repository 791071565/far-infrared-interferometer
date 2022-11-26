`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/30 10:56:07
// Design Name: 
// Module Name: position_reorder
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


module position_reorder(
input   [7:0]       start_position_1            ,
 input   [7:0]       end_position_1              ,
 input   [7:0]       start_position_2            ,
 input   [7:0]       end_position_2              ,
 input   [7:0]       start_position_3            ,
 input   [7:0]       end_position_3              ,     
 input   [7:0]       max_position_1_cmp_r        ,
 input   [7:0]       max_position_2_cmp_r        ,
 input   [7:0]       max_position_3_cmp_r        ,
 
 input               frequency_mode,
 
 
 output   [7:0]       start_position_1_o            ,
 output   [7:0]       end_position_1_o              ,
 output   [7:0]       start_position_2_o            ,
 output   [7:0]       end_position_2_o              ,
 output   [7:0]       start_position_3_o            ,
 output   [7:0]       end_position_3_o              ,      
 
 
 output   [7:0]   max_position_1_cmp_reorder,
 output   [7:0]   max_position_2_cmp_reorder,
 output   [7:0]   max_position_3_cmp_reorder 
 
 
 
 
); 
 
 
 wire   cmp1;
 wire   cmp2;
 wire   cmp3;
 assign cmp1=(max_position_1_cmp_r<max_position_2_cmp_r);
 assign cmp2=(max_position_2_cmp_r<max_position_3_cmp_r); 
 assign cmp3=(max_position_1_cmp_r<max_position_3_cmp_r);
 
 
   reg [7:0]       start_position_1_reorder     ;
   reg [7:0]       end_position_1_reorder       ;
   reg [7:0]       start_position_2_reorder     ;
   reg [7:0]       end_position_2_reorder       ;
   reg [7:0]       start_position_3_reorder     ;
   reg [7:0]       end_position_3_reorder       ;
 
 
(*mark_debug = "true"*) reg [7:0]    max_position_1_cmp_reorder_r;
(*mark_debug = "true"*) reg  [7:0]   max_position_2_cmp_reorder_r;
(*mark_debug = "true"*) reg  [7:0]   max_position_3_cmp_reorder_r;
 
 
 
 
 
 always@*
   begin
    case({cmp1,cmp2,cmp3})
	3'b000:
	begin
	start_position_1_reorder =  start_position_3   ; 
	end_position_1_reorder   =  end_position_3     ; 
	start_position_2_reorder =  start_position_2   ; 
	end_position_2_reorder   =  end_position_2     ; 
	start_position_3_reorder =  start_position_1   ; 
	end_position_3_reorder   =  end_position_1     ; 
	max_position_1_cmp_reorder_r =   max_position_3_cmp_r              ;    	
	max_position_2_cmp_reorder_r =   max_position_2_cmp_r              ;    	
	max_position_3_cmp_reorder_r =   max_position_1_cmp_r              ;    	
		
	end
 //no
   3'b001:
	begin
	start_position_1_reorder =  start_position_1   ; 
	end_position_1_reorder   =  end_position_1     ; 
	start_position_2_reorder =  start_position_2   ; 
	end_position_2_reorder   =  end_position_2     ; 
	start_position_3_reorder =  start_position_3   ; 
	end_position_3_reorder   =  end_position_3     ; 
	max_position_1_cmp_reorder_r =   max_position_1_cmp_r              ;    	
    max_position_2_cmp_reorder_r =   max_position_2_cmp_r              ;        
    max_position_3_cmp_reorder_r =   max_position_3_cmp_r              ;  
	
	
	

	end
  3'b010:
	begin
	start_position_1_reorder = start_position_2   ; 
	end_position_1_reorder   = end_position_2     ; 
	start_position_2_reorder = start_position_3   ; 
	end_position_2_reorder   = end_position_3     ; 
	start_position_3_reorder = start_position_1   ; 
	end_position_3_reorder   = end_position_1     ; 
	max_position_1_cmp_reorder_r =   max_position_2_cmp_r              ;    	
    max_position_2_cmp_reorder_r =   max_position_3_cmp_r              ;        
    max_position_3_cmp_reorder_r =   max_position_1_cmp_r              ;  

	end
	 
 3'b011:
	begin
	start_position_1_reorder =  start_position_2  ; 
	end_position_1_reorder   =  end_position_2    ; 
	start_position_2_reorder =  start_position_1  ; 
	end_position_2_reorder   =  end_position_1    ; 
	start_position_3_reorder =  start_position_3  ; 
	end_position_3_reorder   =  end_position_3    ; 
    max_position_1_cmp_reorder_r = max_position_2_cmp_r              ;    	
    max_position_2_cmp_reorder_r = max_position_1_cmp_r              ;        
    max_position_3_cmp_reorder_r = max_position_3_cmp_r              ;  



	end
 3'b100:
	begin
	start_position_1_reorder =  start_position_3  ; 
	end_position_1_reorder   =  end_position_3    ; 
	start_position_2_reorder =  start_position_1  ; 
	end_position_2_reorder   =  end_position_1    ; 
	start_position_3_reorder =  start_position_2  ; 
	end_position_3_reorder   =  end_position_2    ; 
	max_position_1_cmp_reorder_r =   max_position_3_cmp_r              ;    	
	max_position_2_cmp_reorder_r =   max_position_1_cmp_r              ;        
	max_position_3_cmp_reorder_r =   max_position_2_cmp_r              ;  

	end
 3'b101:
	begin
	start_position_1_reorder =    start_position_1                 ; 
	end_position_1_reorder   =    end_position_1                   ; 
	start_position_2_reorder =    start_position_3                 ; 
	end_position_2_reorder   =    end_position_3                   ; 
	start_position_3_reorder =    start_position_2                 ; 
	end_position_3_reorder   =    end_position_2                   ; 
    max_position_1_cmp_reorder_r =   max_position_1_cmp_r              ;    	
    max_position_2_cmp_reorder_r =   max_position_3_cmp_r              ;        
    max_position_3_cmp_reorder_r =   max_position_2_cmp_r              ;  




	end
	//no
 3'b110:
	begin
	start_position_1_reorder =  start_position_1 ; 
	end_position_1_reorder   =  end_position_1   ; 
	start_position_2_reorder =  start_position_2 ; 
	end_position_2_reorder   =  end_position_2   ; 
	start_position_3_reorder =  start_position_3 ; 
	end_position_3_reorder   =  end_position_3   ; 
    max_position_1_cmp_reorder_r =   max_position_1_cmp_r              ;    	
    max_position_2_cmp_reorder_r =   max_position_2_cmp_r              ;        
    max_position_3_cmp_reorder_r =   max_position_3_cmp_r              ;  



	end
	
	3'b111:
	begin
	start_position_1_reorder = start_position_1   ; 
	end_position_1_reorder   = end_position_1     ; 
	start_position_2_reorder = start_position_2   ; 
	end_position_2_reorder   = end_position_2     ; 
	start_position_3_reorder = start_position_3   ; 
	end_position_3_reorder   = end_position_3     ; 
max_position_1_cmp_reorder_r =   max_position_1_cmp_r              ;    	
        max_position_2_cmp_reorder_r =   max_position_2_cmp_r              ;        
        max_position_3_cmp_reorder_r =   max_position_3_cmp_r              ;  



	end
	
	
	default:;
	endcase
	
	end
	
	
	assign     start_position_1_o = (!frequency_mode)?start_position_2:start_position_1_reorder ;
	assign     end_position_1_o   = (!frequency_mode)?end_position_2  :end_position_1_reorder   ;
	assign     start_position_2_o = (!frequency_mode)?start_position_1:start_position_2_reorder ;
	assign     end_position_2_o   = (!frequency_mode)?end_position_1  :end_position_2_reorder   ;
	assign     start_position_3_o = (!frequency_mode)?start_position_3:start_position_3_reorder ;
	assign     end_position_3_o   = (!frequency_mode)?end_position_3  :end_position_3_reorder   ;
	
	assign  max_position_1_cmp_reorder =(!frequency_mode)?   max_position_2_cmp_r    : max_position_1_cmp_reorder_r ;
    assign  max_position_2_cmp_reorder =(!frequency_mode)?   max_position_1_cmp_r    : max_position_2_cmp_reorder_r ;
    assign  max_position_3_cmp_reorder =(!frequency_mode)?   max_position_3_cmp_r    : max_position_3_cmp_reorder_r ;
	
	
	
	
	
	
 endmodule