module sci_acc_maclauren_exp_ctrl(
				input logic 								clk,
				input logic 								reset_n,
  output logic core_ready,
				// coeff rom intf //
				output logic			     				rd,
				output logic [ADDR_WIDTH-1:0]    	rd_addr,
				input  logic [DATA_WIDTH-1:0] 		coeff_out,
				input  logic								coeff_o_vld,
				// operation input interface //
		      input logic [DATA_WIDTH-1:0] 			in_fifo_data_o,
		      input logic [NUM_MODES-1:0]  			in_fifo_mode_o,
		      input logic [RES_WIDTH-1:0]  			in_fifo_res_o,
		      input logic				 		   		op_pkt_available,
				// interface with fp_arith //
				output logic [DATA_WIDTH-1:0]     	fp_arith_data_1,
				output logic [DATA_WIDTH-1:0]     	fp_arith_data_2,
				output logic						    	op_sel,
				output logic						   	arith_en,
				input  logic [DATA_WIDTH-1:0] 	 	data_accum_o,
				input logic							  		data_accum_o_vld,
				// interface with fp_mult //
				output logic 								mult_en,
				output logic [DATA_WIDTH-1:0] 	 	fp_mult_data_1,
				output logic [DATA_WIDTH-1:0] 		fp_mult_data_2,
				input logic [DATA_WIDTH-1:0] 	 	 	data_prod,
				input logic [DATA_WIDTH-1:0] 	 	 	data_prod_accum,
				input logic							 	data_prod_accum_vld,
				// output interface //
				input logic 								result_fifo_ready,
				output logic [DATA_WIDTH-1:0] 		final_value,
				output logic								fifo_pop,
				output logic								op_done
				);
				
//---------- Declarations ------------//
localparam SIN_INIT_DATA = 0;
localparam COS_INIT_DATA = 1;
localparam EXP_INIT_DATA = 1;

typedef enum logic[MLRN_FSM_WD-1:0]{
	IDLE,
	COMP_X_SQURD,
	RD_COEFF_MEM,
  WAIT,
	TERM_MULT,
	TERM_COEFF_MULT,
	ACCUM,
	SEND_DATA_OUT
} t_mclrn_ctrl_fsm_state;

t_mclrn_ctrl_fsm_state 			mclrn_ctrl_fsm_cur_state;
t_mclrn_ctrl_fsm_state 			mclrn_ctrl_fsm_nxt_state;
logic [TERM_CNTR_WD-1:0] 		sin_coeff_cntr;
logic [TERM_CNTR_WD-1:0] 		cos_coeff_cntr;
logic [TERM_CNTR_WD-1:0] 		exp_coeff_cntr;
logic [TERM_CNTR_WD-1:0] 		sin_coeff_cntr_plus2;
logic [TERM_CNTR_WD-1:0] 		cos_coeff_cntr_plus2;
logic [TERM_CNTR_WD-1:0] 		exp_coeff_cntr_plus1;
logic  								sin_op_flag;
logic  								cos_op_flag;
logic  								exp_op_flag;
logic  								sin_op_done;
logic  								cos_op_done;
logic  								exp_op_done;
logic  								comp_done;
logic  								sin_op_flag_reg;
logic  								cos_op_flag_reg;
logic  								exp_op_flag_reg;
logic									exp_op_first_term_not_done;
logic									cos_op_first_term_not_done;
logic									sin_op_first_term_not_done;
logic									exp_op_first_term_not_done_reg;
logic									cos_op_first_term_not_done_reg;
logic									sin_op_first_term_not_done_reg;
logic [DATA_WIDTH-1:0] 			coeff_out_reg;
logic [DATA_WIDTH-1:0] 	 	 	data_term_prod_accum_reg;
logic [DATA_WIDTH-1:0] 	 	 	data_coeff_prod_accum_reg;
logic									term_prod_data_vld;
logic [DATA_WIDTH-1:0]			data_x;
logic [DATA_WIDTH-1:0]			data_x_squared;
logic [DATA_WIDTH-1:0]			prim_accumulator;
logic									update_accum;
logic									clear_accum;
logic									clear_reg;
logic									caputre_x_sqrd;
logic									sign_bit;
logic									update_sign_bit;
logic 								coeff_prod_data_vld;
logic 								coeff_o_vld_pulse;
logic 								coeff_o_vld_prev;  
logic									upd_sgn_prev;
logic 								upd_sgn_puls;
//-------------------------------------//



//----------- operation complete comb logic ------------//
assign sin_op_done = (sin_coeff_cntr >= in_fifo_res_o << 1) & sin_op_flag_reg;
assign cos_op_done = (cos_coeff_cntr >= in_fifo_res_o << 1) & cos_op_flag_reg;
  assign exp_op_done = (exp_coeff_cntr > in_fifo_res_o);
assign comp_done = sin_op_done | cos_op_done | exp_op_done;
assign clear_accum = (mclrn_ctrl_fsm_cur_state == IDLE) & (exp_op_flag_reg | sin_op_flag_reg | cos_op_flag_reg );
assign clear_reg = clear_accum;
//-----------------------------------------------------//



//--------------- x-value squared -------------------------//
always_ff@(posedge clk) begin
	if(!reset_n) begin
		data_x_squared <= 0;
	end
	else begin
		if(caputre_x_sqrd & data_prod_accum_vld)   data_x_squared <= data_prod_accum;
        else if(clear_accum)					data_x_squared <= 0;
		else 												 data_x_squared <= data_x_squared;
	end
end
//---------------------------------------------------------//



//------------- Primary accumulator ------------//
assign update_accum = (mclrn_ctrl_fsm_cur_state == ACCUM) & data_accum_o_vld;

always_ff@(posedge clk) begin
	if(!reset_n) begin
		prim_accumulator <= 0;
	end
	else begin
		if(update_accum)  		prim_accumulator <= data_accum_o;
		else if(clear_accum) 	prim_accumulator <= 0;
		else							prim_accumulator <= prim_accumulator;
	end
end
//----------------------------------------------//



//----------- internal reg for req X-value storage ----------//
always_ff@(posedge clk) begin
	if(!reset_n) begin
		data_x <= 0;
	end
	else begin
		if(op_pkt_available)    data_x <= in_fifo_data_o;
		else if(clear_reg)		data_x <= 0;
		else 							data_x <= data_x;
	end
end
//----------------------------------------------------------//



//----------- internal reg for coeff multiplcation ----------//
assign coeff_prod_data_vld = data_prod_accum_vld & (mclrn_ctrl_fsm_cur_state == TERM_COEFF_MULT);

always_ff@(posedge clk) begin
	if(!reset_n) begin
		data_coeff_prod_accum_reg <= 32'h3f800000;
	end
	else begin
		if(coeff_prod_data_vld)  	data_coeff_prod_accum_reg <= data_prod_accum;
		else 								data_coeff_prod_accum_reg <= data_coeff_prod_accum_reg;
	end
end
//----------------------------------------------------------//





//----------- internal reg for term multiplcation ----------//
assign term_prod_data_vld = data_prod_accum_vld & (mclrn_ctrl_fsm_cur_state == TERM_MULT);

always_ff@(posedge clk) begin
	if(!reset_n) begin
		data_term_prod_accum_reg <= 32'h3f800000;
	end
	else begin
		if(term_prod_data_vld)  data_term_prod_accum_reg <= data_prod_accum;
		else 							data_term_prod_accum_reg <= data_term_prod_accum_reg;
	end
end
//----------------------------------------------------------//




//------------ internal coeff reg -------------//
always_ff@(posedge clk) begin
	if(!reset_n) begin
		coeff_out_reg <= 0;
	end
	else begin
		if(coeff_o_vld) coeff_out_reg <= coeff_out;
		else 				 coeff_out_reg <= coeff_out_reg;
	end
end
//---------------------------------------------//




//--------------- sign bit generation for arith --------------//
assign update_sign_bit = coeff_o_vld & (sin_op_flag_reg | cos_op_flag_reg);
assign upd_sgn_puls = update_sign_bit & ~upd_sgn_prev;

always_ff@(posedge clk) begin
 if(!reset_n) begin
	upd_sgn_prev <= 0;
 end
 else begin
	upd_sgn_prev <= update_sign_bit;
 end
end
  
always_ff@(posedge clk) begin
	if(!reset_n) begin
		sign_bit <= 1;
	end
	else begin
      if(upd_sgn_puls) 				sign_bit <= ~sign_bit;
      else if(clear_accum)			sign_bit <= 1;
		else				 		sign_bit <= sign_bit;
	end
end
//------------------------------------------------------------//





//---------- Coeff addr gen/term counters ---------------//  
assign sin_coeff_cntr_plus2 = sin_coeff_cntr + 2;
assign coeff_o_vld_pulse = ~coeff_o_vld_prev & coeff_o_vld;

always_ff@(posedge clk) begin
 if(!reset_n) begin
	coeff_o_vld_prev <= 0;
 end
 else begin
	coeff_o_vld_prev <= coeff_o_vld;
 end
end
  
  
always_ff@(posedge clk) begin
	if(!reset_n) begin
		sin_coeff_cntr <= 1;
	end
	else begin
		if(coeff_o_vld_pulse & sin_op_flag_reg)  			sin_coeff_cntr <= sin_coeff_cntr_plus2;
		else if(clear_reg) 								sin_coeff_cntr <= 1;
		else 													sin_coeff_cntr <= sin_coeff_cntr;
	end
end

assign cos_coeff_cntr_plus2 = cos_coeff_cntr + 2;

always_ff@(posedge clk) begin
	if(!reset_n) begin
		cos_coeff_cntr <= 0;	
	end
	else begin
		if(coeff_o_vld_pulse & cos_op_flag_reg)  			cos_coeff_cntr <= cos_coeff_cntr_plus2;
		else if(clear_reg) 								cos_coeff_cntr <= 0;
		else 													cos_coeff_cntr <= cos_coeff_cntr;	
	end
end

assign exp_coeff_cntr_plus1 = exp_coeff_cntr + 1;

always_ff@(posedge clk) begin
	if(!reset_n) begin
		exp_coeff_cntr <= 0;
	end
	else begin
		if(coeff_o_vld_pulse & exp_op_flag_reg)  			exp_coeff_cntr <= exp_coeff_cntr_plus1;
		else if(clear_reg) 								exp_coeff_cntr <= 0;
		else 													exp_coeff_cntr <= exp_coeff_cntr;		
	end
end
//-----------------------------------------//



//---------- internal operation flags ---------------//
always_ff@(posedge clk) begin
	if(!reset_n) begin
		exp_op_flag_reg <= 1;
	end
	else begin
		if(exp_op_flag)  		exp_op_flag_reg <= 1;
		else if(clear_reg) 	exp_op_flag_reg <= 0;
		else 						exp_op_flag_reg <= exp_op_flag_reg;
	end
end


always_ff@(posedge clk) begin
	if(!reset_n) begin
		sin_op_flag_reg <= 0;	
	end
	else begin
		if(sin_op_flag)  			sin_op_flag_reg <= 1;
		else if(clear_reg) 		sin_op_flag_reg <= 0;
		else 							sin_op_flag_reg <= sin_op_flag_reg;	
	end
end


always_ff@(posedge clk) begin
	if(!reset_n) begin
		cos_op_flag_reg <= 0;
	end
	else begin
		if(cos_op_flag)  		cos_op_flag_reg <= 1;
		else if(clear_reg) 	cos_op_flag_reg <= 0;
		else 						cos_op_flag_reg <= cos_op_flag_reg;		
	end
end
//-----------------------------------------//




//---------- fisrt term compute indicator ---------------//
always_ff@(posedge clk) begin
	if(!reset_n) begin
		exp_op_first_term_not_done_reg <= 0;
	end
	else begin
		if(exp_op_first_term_not_done)  		exp_op_first_term_not_done_reg <= 1;
		else if(data_accum_o_vld) 					exp_op_first_term_not_done_reg <= 0;
		else 											exp_op_first_term_not_done_reg <= exp_op_first_term_not_done_reg;
	end
end


always_ff@(posedge clk) begin
	if(!reset_n) begin
		sin_op_first_term_not_done_reg <= 0;	
	end
	else begin
		if(sin_op_first_term_not_done)  		sin_op_first_term_not_done_reg <= 1;
		else if(data_accum_o_vld) 					sin_op_first_term_not_done_reg <= 0;
		else 											sin_op_first_term_not_done_reg <= sin_op_first_term_not_done_reg;	
	end
end


always_ff@(posedge clk) begin
	if(!reset_n) begin
		cos_op_first_term_not_done_reg <= 0;
	end
	else begin
		if(cos_op_first_term_not_done)  		cos_op_first_term_not_done_reg <= 1;
		else if(data_accum_o_vld) 					cos_op_first_term_not_done_reg <= 0;
		else 											cos_op_first_term_not_done_reg <= cos_op_first_term_not_done_reg;		
	end
end
//-----------------------------------------//




//--------- MCLRN OP CTRL FSM -------------//
always_ff@(posedge clk) begin
	if(!reset_n) begin
		 mclrn_ctrl_fsm_cur_state <=  IDLE;
	end
	else begin
		 mclrn_ctrl_fsm_cur_state <=  mclrn_ctrl_fsm_nxt_state;
	end
end
//-----------------------------------------//




//----------------- FSM Transitions ------------//
always@(*) begin

	// Defaults //
	mclrn_ctrl_fsm_nxt_state = mclrn_ctrl_fsm_cur_state;
  core_ready = 0;
	rd = 0;
	rd_addr = 0;
	sin_op_flag = 0;
	cos_op_flag = 0;
	exp_op_flag = 0;
	exp_op_first_term_not_done = 0;
	sin_op_first_term_not_done = 0;
	cos_op_first_term_not_done = 0;
	fp_arith_data_1 = 0;
	fp_arith_data_2 = 0;
	op_sel = 0;
	arith_en = 0;
	mult_en = 0;
	fp_mult_data_1 = 32'h3f800000;
	fp_mult_data_2 = 32'h3f800000;
	final_value = 0;
	fifo_pop = 0;
	op_done = 0;
	caputre_x_sqrd = 0;
	//----------//
	
	
	//--------------- Transitions ---------------------//
	case(mclrn_ctrl_fsm_cur_state)
	
		//--------------- state ---------------------//
		IDLE: begin
          core_ready = 1;
			if(op_pkt_available) begin
				case(in_fifo_mode_o)
					0: begin
						exp_op_flag = 1;
						exp_op_first_term_not_done = 1;
						mclrn_ctrl_fsm_nxt_state = RD_COEFF_MEM;
					end
					
					1: begin
						sin_op_flag = 1;
						sin_op_first_term_not_done = 1;	
						mclrn_ctrl_fsm_nxt_state = COMP_X_SQURD;					
					end
					
					2: begin
						cos_op_flag = 1;
						cos_op_first_term_not_done = 1;
						mclrn_ctrl_fsm_nxt_state = COMP_X_SQURD;
					end
					
					default: begin
						mclrn_ctrl_fsm_nxt_state = IDLE;
						exp_op_flag = 0;
						sin_op_flag = 0;
						cos_op_flag = 0;
					end
				endcase
			end
			else begin
				mclrn_ctrl_fsm_nxt_state = IDLE;
				exp_op_flag = 0;
				sin_op_flag = 0;
				cos_op_flag = 0;
			end
		end
		//--------------- IDLE ---------------------//
		
		
		
		
		//--------------- state ---------------------//
		COMP_X_SQURD: begin
			mult_en = 1;
			caputre_x_sqrd = 1;	
			fp_mult_data_1 = data_x;
			fp_mult_data_2 = data_x;
			
			if(data_prod_accum_vld) mclrn_ctrl_fsm_nxt_state = RD_COEFF_MEM;
			else 							mclrn_ctrl_fsm_nxt_state = COMP_X_SQURD;
		end
		//--------------- COMP_X_SQURD ---------------------//
		
		
		
		
		//--------------- state ---------------------//
		RD_COEFF_MEM: begin
			rd = 1;
			case ({exp_op_flag_reg, cos_op_flag_reg, sin_op_flag_reg})
				3'b100: rd_addr = exp_coeff_cntr;
				3'b010: rd_addr = cos_coeff_cntr;
				3'b001: rd_addr = sin_coeff_cntr;
				default: begin
					rd_addr = 0;
					rd = 0;
				end
			endcase
			
			if(coeff_o_vld) 	mclrn_ctrl_fsm_nxt_state = TERM_MULT;
			else 					mclrn_ctrl_fsm_nxt_state = RD_COEFF_MEM;
		end
		//--------------- RD_COEFF_MEM ---------------------//
		
		
		
		
		//--------------- state ---------------------//
		TERM_MULT: begin
			case ({exp_op_flag_reg, cos_op_flag_reg, sin_op_flag_reg})
				3'b100: begin
					mult_en = 1;
					if(exp_op_first_term_not_done_reg) begin
						fp_mult_data_1 = 32'h3f800000;
						fp_mult_data_2 = 32'h3f800000;
					end
					else begin
						fp_mult_data_1 = data_term_prod_accum_reg;
						fp_mult_data_2 = data_x;
					end
				end
				3'b010: begin
					mult_en = 1;
					if(cos_op_first_term_not_done_reg) begin
						fp_mult_data_1 = 32'h3f800000;
						fp_mult_data_2 = 32'h3f800000;
					end
					else begin
						fp_mult_data_1 = data_term_prod_accum_reg;
						fp_mult_data_2 = data_x_squared;
					end
				end
				3'b001: begin
					mult_en = 1;
					if(sin_op_first_term_not_done_reg) begin
						fp_mult_data_1 = 32'h3f800000;
						fp_mult_data_2 = data_x;
					end
					else begin
						fp_mult_data_1 = data_term_prod_accum_reg;
						fp_mult_data_2 = data_x_squared;
					end
				end
				default: begin
					mclrn_ctrl_fsm_nxt_state = TERM_MULT;
				end
			endcase
		
          if(data_prod_accum_vld) mclrn_ctrl_fsm_nxt_state = WAIT;//TERM_COEFF_MULT;
			else 							mclrn_ctrl_fsm_nxt_state = TERM_MULT;
		end
		//--------------- TERM_MULT ---------------------//
		

      
      
      
		//--------------- state ---------------------//
		WAIT: begin
			mclrn_ctrl_fsm_nxt_state = TERM_COEFF_MULT;
		end
		//--------------- WAIT ---------------------//
      
      
      
		
		
		//--------------- state ---------------------//
		TERM_COEFF_MULT: begin
			fp_mult_data_1 = data_term_prod_accum_reg;
			fp_mult_data_2 = coeff_out_reg;
			mult_en = 1;
			
			if(data_prod_accum_vld) mclrn_ctrl_fsm_nxt_state = ACCUM;
			else 							mclrn_ctrl_fsm_nxt_state = TERM_COEFF_MULT;
		end
		//--------------- TERM_COEFF_MULT ---------------------//
		
		
		
		
		//--------------- state ---------------------//
		ACCUM: begin
			fp_arith_data_1 = prim_accumulator;
			fp_arith_data_2 = data_coeff_prod_accum_reg;
			arith_en = 1;
			
			case ({exp_op_flag_reg, cos_op_flag_reg, sin_op_flag_reg})
				3'b100: begin
					op_sel = 0;
				end
				3'b010: begin
					op_sel = sign_bit;
				end
				3'b001: begin
					op_sel = sign_bit;
				end
				default: begin
					mclrn_ctrl_fsm_nxt_state = ACCUM;
				end
			endcase
			
			if(data_accum_o_vld)  		mclrn_ctrl_fsm_nxt_state = RD_COEFF_MEM;
			else if(comp_done)			mclrn_ctrl_fsm_nxt_state = SEND_DATA_OUT;
			else								mclrn_ctrl_fsm_nxt_state = ACCUM;
		end
		//--------------- ACCUM ---------------------//
		
		
		
		
		//--------------- state ---------------------//
		SEND_DATA_OUT: begin
			if(result_fifo_ready) begin
				final_value = prim_accumulator;
				fifo_pop = 1;
				op_done = 1;
				mclrn_ctrl_fsm_nxt_state = IDLE;
			end
			else begin
				mclrn_ctrl_fsm_nxt_state = SEND_DATA_OUT;
			end
		end
		//--------------- SNED_DATA_OUT ---------------------//
		
		
		
		
		//--------------- state ---------------------//
		default: begin
			mclrn_ctrl_fsm_nxt_state = IDLE;
		end
		//--------------- default ---------------------//
	endcase
end
//--------------------------------------------//
//-----------------------------------------//

endmodule // sci_acc_maclauren_exp_ctrl //