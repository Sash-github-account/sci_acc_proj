`include "param.vh"
`include "accumulator.v"
`include "coeff_rom.v"
`include "control_fsm.v"
`include "fp_arith.v"
`include "fp_mult.v"
`include "term_counter.v"



module sci_compute_core(
			input 			clk,
			input 			rst_n,
			input 			op_pkt_available,
			input [RES_WIDTH-1:0] 	res,
			input [NUM_MODES-1:0] 	mode,
			input [DATA_WIDTH-1:0] 	data_x,

			output [DATA_WIDTH-1:0] final_value,
			output 			fifo_pop,
			output 			op_done
			);



   // Parameter file include //
`include "param.vh"
   //___________________//


   
   // Declarations //
   wire [DATA_WIDTH-1:0] 			x_power_term;
   wire [DATA_WIDTH-1:0] 			stg1_dout;   
   wire [DATA_WIDTH-1:0] 			coeff_value;
   wire [DATA_WIDTH-1:0] 			coeff_prod;
  wire  [DATA_WIDTH-1:0] arith_out;
   wire 					stg1_en;
   wire 					stg2_en;
   wire 					op_sel;
   wire [RES_WIDTH-1:0] 			term_cnt;
   wire 					start_cntr;
   wire 					rd;   
   //______________//

   
   
   // Control FSM instance //
   control_fsm control_fsm(
			   // Inputs
			   .clk(clk),
			   .rst_n(rst_n),
			   .op_pkt_available(op_pkt_available),
			   .mode(mode),
			   .res(res),
			   .term_cnt(term_cnt),
			   // Outputs
			   .done(op_done),
			   .rd_fifo(fifo_pop),
			   .op(op_sel),
			   .stg1_en(stg1_en),
			   .stg2_en(stg2_en),
			   .start_cnt(start_cntr),
			   .rd_coeff()
			   );
   //______________//



   // Coefficient ROM instance //
     coeff_rom coeff_rom(
			 .clk(clk),
			 .rst_n(rst_n),
			 .rd(rd),
			 .rd_addr(term_cnt),
			 .coeff_out(coeff_value)
			 );



   // Term counter instance //
     term_counter term_counter(
			       .clk(clk),
			       .rst_n(rst_n),
			       .start_cntr(start_cntr),
       .coeff_rd_en(rd),
			       .done(op_done),
			       .term_cnt(term_cnt)
			       );
   //______________//

   


   // Multiplier stage 1 instance //
     fp_mult x_power_fp_mult(
			     .data_1(x_power_term),
			     .data_2(data_x),
			     .data_prod(stg1_dout)
			     );
   //______________//



   // Accumulate stage 1 product instance //
     accumulator x_power_accum(
			       .clk(clk),
			       .rst_n(rst_n),
			       .data_in(stg1_dout),
			       .stg_en(stg1_en),
			       .accum_data_out(x_power_term)
			       );
   //______________//

   
   
   // Multiplier stage 2 instance //
     fp_mult coeff_mult(
			     .data_1(coeff_value),
			     .data_2(x_power_term),
			     .data_prod(coeff_prod)
			     );
   //______________//



   // Arithmetic unit instance //
     fp_arith fp_arith(
		       .data_1(final_value),
		       .data_2(coeff_prod),
       .en(stg2_en),
		       .op_sel(op_sel),
		       .data_o(arith_out)
		       );
   //______________//
      


   // Accumulate stage 2 product instance //
     accumulator value_accum(
			     .clk(clk),
			     .rst_n(rst_n),
			     .data_in(arith_out),
			     .stg_en(stg2_en),
			     .accum_data_out(final_value)
			     );
   //______________//



endmodule // sci_compute_core
