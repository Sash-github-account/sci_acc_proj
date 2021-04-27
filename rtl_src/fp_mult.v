`include "param.vh"
//`include "detect_pos_first_one.v"



module fp_mult (
		input [DATA_WIDTH-1:0] 	    data_1,
		input [DATA_WIDTH-1:0] 	    data_2,
		output reg [DATA_WIDTH-1:0] data_prod
		);



   // Parameter file include //
`include "param.vh"
   //_______________________//


   
   // Declarations //
   reg [47:0] 				    data_prod_full;
   wire [46:0] 				    data_prod_full_normalized;
   wire [23:0] 				    data_1_mult_in;
   wire [23:0] 				    data_2_mult_in;   
   wire 				    sign_bit;
   wire [8:0] 				    data_exp;
   wire [5:0] 				    shift_exp_by;
   wire [7:0] 				    exp_final;   
   //______________//

   
   
   // iteration variable //
   integer 				    i;
   //______________//



   // Mantissa multiplication inputs //
   assign data_1_mult_in = { 1'b1, data_1[22:0]};
   assign data_2_mult_in = { 1'b1, data_2[22:0]};
   //______________//

   
   
   // Sign bit and exponent value determination //
   assign sign_bit = data_1[31] ^ data_2[31];
   assign data_exp = data_1[30:23] + data_2[30:23];
   //______________//


   
   // Multiplier for Manitissa //
   always @( data_1_mult_in or data_2_mult_in ) begin // FULL MULTIPLICATION        
      data_prod_full = 0;
      
      for(i=0; i<24; i=i+1)
        if( data_1_mult_in[i] == 1'b1 ) data_prod_full = data_prod_full + (data_2_mult_in << i );
      
   end
   //______________//



   // detect the first 1 in the product //
   detect_pos_first_one #(.D_WIDTH(48)) shift_for_exp (.data_i(data_prod_full), .pos_o(shift_exp_by));
   assign data_prod_full_normalized = data_prod_full << shift_exp_by; 
  assign exp_final = data_exp[8:0] - shift_exp_by - 127 + 1;  
   //______________//


   
   // Final output product //
   always@(*) begin
      data_prod[31] <= sign_bit;
      data_prod[30:23] <= exp_final;
      data_prod[22:0] <= data_prod_full_normalized[45:22];      
   end
   //______________//
   

   
endmodule // fp_mult
