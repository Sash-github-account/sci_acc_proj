module sci_acc_sce_mclrn_comp_core(
				input logic 								clk,
				input logic 								reset_n,
				// operation input interface //
  output logic core_ready,
		      input logic [DATA_WIDTH-1:0] 			in_fifo_data_o,
		      input logic [NUM_MODES-1:0]  			in_fifo_mode_o,
		      input logic [RES_WIDTH-1:0]  			in_fifo_res_o,
		      input logic				 		   		op_pkt_available,
				// output interface //
				input logic 								result_fifo_ready,
				output logic [DATA_WIDTH-1:0] 		final_value,
				output logic								fifo_pop,
				output logic								op_done				
);

//-------------------- Decalarations -------------------------//
logic    					 rd;
logic [ADDR_WIDTH-1:0]   rd_addr;
logic [DATA_WIDTH-1:0]   coeff_out;
logic    					 coeff_o_vld;
logic [DATA_WIDTH-1:0]   fp_arith_data_1;
logic [DATA_WIDTH-1:0]   fp_arith_data_2;
logic    					 op_sel;
logic    					 arith_en;
logic [DATA_WIDTH-1:0]   data_accum_o;
logic    					 data_accum_o_vld;
logic    					 mult_en;
logic [DATA_WIDTH-1:0]   fp_mult_data_1;
logic [DATA_WIDTH-1:0]   fp_mult_data_2;
logic [DATA_WIDTH-1:0]   data_prod;
logic [DATA_WIDTH-1:0]   data_prod_accum;
logic   						 data_prod_accum_vld;
logic [DATA_WIDTH-1:0]   data_o;


//------------------------------------------------------------//

//---------Gen by Python Script: integration_script.py ---------------//


 sci_acc_maclauren_exp_ctrl i_sci_acc_maclauren_exp_ctrl(
								.clk (clk),
 								.reset_n (reset_n),
   .core_ready(core_ready),
 								.rd (rd),
 								.rd_addr (rd_addr),
 								.coeff_out (coeff_out),
 								.coeff_o_vld (coeff_o_vld),
 								.in_fifo_data_o (in_fifo_data_o),
 								.in_fifo_mode_o (in_fifo_mode_o),
 								.in_fifo_res_o (in_fifo_res_o),
 								.op_pkt_available (op_pkt_available),
 								.fp_arith_data_1 (fp_arith_data_1),
 								.fp_arith_data_2 (fp_arith_data_2),
 								.op_sel (op_sel),
 								.arith_en (arith_en),
 								.data_accum_o (data_accum_o),
 								.data_accum_o_vld (data_accum_o_vld),
 								.mult_en (mult_en),
 								.fp_mult_data_1 (fp_mult_data_1),
 								.fp_mult_data_2 (fp_mult_data_2),
 								.data_prod (data_prod),
 								.data_prod_accum (data_prod_accum),
 								.data_prod_accum_vld (data_prod_accum_vld),
 								.result_fifo_ready (result_fifo_ready),
 								.final_value (final_value),
 								.fifo_pop (fifo_pop),
 								.op_done (op_done)
								);



 fp_arith  i_fp_arith(
								.clk (clk),
 								.rst_n (reset_n),
 								.data_1 (fp_arith_data_1),
 								.data_2 (fp_arith_data_2),
 								.op_sel (op_sel),
 								.en (arith_en),
 								.data_accum_o (data_accum_o),
 								.data_o_vld (data_accum_o_vld)
								);



 fp_mult  i_fp_mult(
								.clk (clk),
 								.rst_n (reset_n),
 								.mult_en (mult_en),
 								.data_1 (fp_mult_data_1),
 								.data_2 (fp_mult_data_2),
 								.data_prod (data_prod),
 								.data_prod_o (data_prod_accum),
 								.data_prod_o_vld (data_prod_accum_vld)
								);



 coeff_rom i_coeff_rom(
								.clk (clk),
 								.rst_n (reset_n),
 								.rd (rd),
 								.rd_addr (rd_addr),
 								.coeff_o_vld (coeff_o_vld),
 								.coeff_out (coeff_out)
								);


endmodule //sci_acc_sce_mclrn_comp_core.sv

//---------Gen by Python Script: integration_script.py ---------------//
