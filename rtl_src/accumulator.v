`include "param.vh"



module accumulator (
		    input 			 clk,
		    input 			 rst_n,
		    input [DATA_WIDTH-1:0] 	 data_in,
		    input 			 stg_en,
		    output reg [DATA_WIDTH-1:0 ] accum_data_out
		    );


   
   // Parameter file include //  
`include "param.vh"
      //______________//



   // Accumulator sequential logic //
  always@(posedge clk) begin
     if(rst_n) begin
	 accum_data_out <= ACCUM_INIT;
      end
      else begin
	 if(stg_en) begin
	    accum_data_out <= data_in;
	 end
	 else begin
	    accum_data_out <=  ACCUM_INIT;
	 end
      end // else: !if(rsn_n)
   end // always@ (posedge clk or negedge rst_n)
   //______________//


   
endmodule // accumulator
