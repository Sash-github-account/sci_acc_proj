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
logic 		           				  			req_vld;
logic [NUM_MODE_BITS-1:0]     				req_mode;
logic [NUM_RES_BITS-1:0]  						req_res;
logic [IEEE_32BIT-1:0]  			  			req_data;
logic [SCIACC_RESP_FIFO_DATA_WIDTH-1:0]	final_value;
logic  												result_fifo_ready;
//-------------------------------------//





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
 								.batch_dma_done (batch_dma_done)
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
