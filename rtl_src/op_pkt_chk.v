`include "param.vh"



module op_pkt_chk(
		  input 						clk,
		  input 						rst_n,
		  input 						pkt_in_valid,
		  input [(DATA_WIDTH + RES_WIDTH + NUM_MODES)-1:0] 	pkt_i,
		  output reg 						pkt_good,
		  output reg 						pkt_dropd,
		  output reg [(DATA_WIDTH + RES_WIDTH + NUM_MODES)-1:0] pkt_o
		  );



   // Parameter file include //
 `include "param.vh"
   //______________//


  
   // Declarations //
   wire [RES_WIDTH-1:0] 						res_int;
   wire [NUM_MODES-1:0] 						mode_int;  
   wire 								is_mode_onehot;
   wire 								is_res_greater_than_5;  
   //______________//


   // Check for mode and res //
   assign res_int = pkt_i[(DATA_WIDTH + RES_WIDTH + NUM_MODES)-1:(DATA_WIDTH + NUM_MODES)];
   assign mode_int = pkt_i[(DATA_WIDTH + NUM_MODES)-1:DATA_WIDTH];
   assign is_mode_onehot = (^mode_int) & ~(&mode_int);
   assign is_res_greater_than_5 = (res_int > 4'h5);
   //______________//
   
   
   
   // Checker output generation logic //
   always@(posedge clk or negedge rst_n) begin
      if(rst_n) begin
	 pkt_good <= 0;
	 pkt_dropd <= 0;
	 pkt_o <= 0;
      end
      else begin
	 if(pkt_in_valid) begin
	    if( ~is_mode_onehot | ~is_res_greater_than_5) begin
	       pkt_good <= 0;
	       pkt_dropd <= 1;
	       pkt_o <= 0;
	    end
	    else begin
	       pkt_dropd <= 0;
	       pkt_good <= 1;
	       pkt_o <= pkt_i;
	    end
	 end // if (pkt_in_valid)
	 else begin 
	    pkt_dropd <= 0;
	    pkt_good <= 0;
	    pkt_o <= 0;
	 end // else: !if(pkt_in_valid)
      end // else: !if(rst_n)
   end // always@ (posedge clk or negedge rst_n)
   //______________//

   
   
endmodule // op_pkt_chk
