
module term_counter(
		    input 			clk,
		    input 			rst_n,
		    input 			start_cntr,
		    input 			done,
  output reg coeff_rd_en,
		    output reg [CNTR_DEPTH-1:0] term_cnt
		    );


   // Declarations //
   reg 						cntr_en;   
   //______________//

  
  //read enable for coeff ROM//
  assign coeff_rd_en = cntr_en;
  //_______________//
  

   
   // Capture start and done edges //
   always@(posedge clk) begin
      if(!rst_n) begin
	 cntr_en <= 0;
      end
      else begin
	 if(start_cntr) cntr_en <= 1'b1;
	 if(done) cntr_en <= 1'b0;	 
      end      
   end
   //______________//

   

   // Counter logic //
   always@(posedge clk ) begin
      if(!rst_n) begin
	 term_cnt <= 0;
      end
      else begin
     if(start_cntr ) begin
	    term_cnt <= 0;
	 end
	 else if(cntr_en & ~done) begin
	    term_cnt <= term_cnt + 1;
	 end
	 else begin
	    term_cnt <= 0;
	 end
      end // else: !if(rst_n)
   end // always@ (posedge clk or negedge rst_n)
   //______________//


   
endmodule // term_counter

