module sci_acc_sce_top(
							input logic clk,
							input logic reset_n,
							// interface with ROM //
							output logic [ROM_ADDR_WIDTH-1:0]	rom_rd_addr,
							output logic 								CE_bar,
							output logic								OE_bar,
							output logic								WE_bar,
							input logic [ROM_DATA_WIDTH-1:0]		rom_rd_data,
							output logic								batch_dma_done,
							// RAM interface //
							output logic [RAM_ADDR_WIDTH-1:0]					ram_wr_addr_l,
							output logic 												CE_bar_l,
							output logic												RW_bar_l,
							output logic												OE_bar_l,
							input logic													BUSY_bar_l,
							input	logic													INTR_bar_l,
							output logic [RAM_DATA_WIDTH-1:0]					ram_wr_data
							);


							
//---------- Declarations ------------//
parameter FINAL_VAL = 32'h3f7f978d;
logic 		           				  			req_vld;
logic [NUM_MODE_BITS-1:0]     				req_mode;
logic [NUM_RES_BITS-1:0]  						req_res;
logic [IEEE_32BIT-1:0]  			  			req_data;
logic [SCIACC_RESP_FIFO_DATA_WIDTH-1:0]	final_value;
logic  												result_fifo_ready;
logic [31:0]										final_val_reg;
logic													batch_dma_done_int;
logic													sciacc_top_hb;
logic													sciacc_top_hb_prev;
logic													sciacc_top_hb_pls;
logic [31:0]										serilaizer_cntr;
logic													op_done;
logic 												trig;
//-------------------------------------//



//--------- Heart beat Inst --------------//
heart_beat i_sciacc_top_hb(
						  .clk(clk),
						  .reset_n(reset_n),
						// to top //
						  .hb_pulse(sciacc_top_hb)
						);
//----------------------------------------//						



//---------- Serilaizer logic ------------//
assign sciacc_top_hb_pls = ~sciacc_top_hb_prev & sciacc_top_hb;
always_ff@(posedge clk) begin
	if(!reset_n) begin
		sciacc_top_hb_prev <= 0;
	end
	else begin
		sciacc_top_hb_prev <= sciacc_top_hb;
	end
end 

assign trig = batch_dma_done_int & (final_val_reg == FINAL_VAL) & (serilaizer_cntr <= 31) & sciacc_top_hb_pls;
always_ff@(posedge clk) begin
	if(!reset_n) begin
		serilaizer_cntr <= 0;
	end
	else begin
		if(trig) serilaizer_cntr <= serilaizer_cntr + 1;
	end
end

//----------------------------------------//



//------- Register ----------//
assign batch_dma_done = batch_dma_done_int; // & (final_val_reg == FINAL_VAL) & final_val_reg[serilaizer_cntr];
always_ff@(posedge clk) begin
	if(!reset_n) begin
		final_val_reg <= 0;
	end
	else begin
		if(op_done) final_val_reg <= final_value;
	end
end

//---------------------------//



//---------Gen by Python Script: integration_script.py ---------------//


 rom_dma_top i_rom_dma_top(
								.clk (clk),
 								.reset_n (reset_n),
 								.rom_rd_addr (rom_rd_addr),
 								.CE_bar (CE_bar),
 								.OE_bar (OE_bar),
 								.WE_bar (WE_bar),
 								.rom_rd_data (rom_rd_data),
 								.req_vld (req_vld),
 								.req_mode (req_mode),
 								.req_res (req_res),
 								.req_data (req_data),
 								.intf_ready (intf_ready),
 								.resp_gen_cmpltd (op_done),
 								.batch_dma_done (batch_dma_done_int)
								);



 sci_acc_sce_mclrn_comp_core i_sci_acc_sce_mclrn_comp_core(
								.clk (clk),
 								.reset_n (reset_n),
   .core_ready(intf_ready),
 								.in_fifo_data_o (req_data),
 								.in_fifo_mode_o (req_mode),
 								.in_fifo_res_o (req_res),
 								.op_pkt_available (req_vld),
 								.result_fifo_ready (result_fifo_ready),
 								.final_value (final_value),
 								.fifo_pop (fifo_pop),
 								.op_done (op_done)
								);






//---------Gen by Python Script: integration_script.py ---------------//


 ram_wr_dma_top i_ram_wr_dma_top(
								.clk (clk),
 								.reset_n (reset_n),
 								.fifo_data_in (final_value),
 								.fifo_data_in_push (op_done),
 								.fifo_ready (result_fifo_ready),
 								.ram_wr_addr_l (ram_wr_addr_l),
 								.CE_bar_l (CE_bar_l),
 								.RW_bar_l (RW_bar_l),
 								.OE_bar_l (OE_bar_l),
 								.BUSY_bar_l (BUSY_bar_l),
 								.INTR_bar_l (INTR_bar_l),
 								.ram_wr_data (ram_wr_data)
								);


endmodule //sci_acc_sce_top.sv

//---------Gen by Python Script: integration_script.py ---------------//
