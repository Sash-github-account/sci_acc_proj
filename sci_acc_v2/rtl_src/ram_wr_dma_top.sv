module ram_wr_dma_top(
							input logic 												clk,
							input logic 												reset_n,
							// interface for response data fifo //
							input logic [SCIACC_RESP_FIFO_DATA_WIDTH-1:0] 	fifo_data_in,
							input logic 												fifo_data_in_push,
							output logic 												fifo_ready,
							// RAM interface ///
							output logic [RAM_ADDR_WIDTH-1:0]					ram_wr_addr_l,
							output logic 												CE_bar_l,
							output logic												RW_bar_l,
							output logic												OE_bar_l,
							input logic													BUSY_bar_l,
							input	logic													INTR_bar_l,
							output logic [RAM_DATA_WIDTH-1:0]					ram_wr_data
);



//------ Declarations ---------//
logic [SCIACC_RESP_FIFO_DATA_WIDTH-1:0]		sciacc_resp_data_fifo_fifo_data_in;
logic [SCIACC_RESP_FIFO_DATA_WIDTH-1:0]		fifo_data_out;
logic														fifo_data_out_vld;
logic 													sciacc_resp_data_fifo_fifo_data_push;
logic 													sciacc_resp_data_fifo_fifo_data_pop;
logic [SCIACC_RESP_FIFO_DATA_WIDTH-1:0]		sciacc_resp_data_fifo_fifo_data_out;
logic														sciacc_resp_data_fifo_fifo_data_out_vld;
logic 													sciacc_resp_data_fifo_fifo_full;
logic 													sciacc_resp_data_fifo_fifo_empty;
logic														fifo_data_pop;
  logic fifo_full;
//-----------------------------//

//---------- Assignments ------------//
assign fifo_data_out = sciacc_resp_data_fifo_fifo_data_out;
assign fifo_data_out_vld = sciacc_resp_data_fifo_fifo_data_out_vld;
assign sciacc_resp_data_fifo_fifo_data_pop = fifo_data_pop;
assign fifo_ready = ~fifo_full;
assign sciacc_resp_data_fifo_fifo_data_in = fifo_data_in;
assign sciacc_resp_data_fifo_fifo_data_push = fifo_data_in_push;
//-----------------------------------//



//---------Gen by Python Script: integration_script.py ---------------//


 ram_dma_wr_ctrl i_ram_dma_wr_ctrl(
								.clk (clk),
 								.reset_n (reset_n),
 								.fifo_data_out (fifo_data_out),
 								.fifo_data_out_vld (fifo_data_out_vld),
 								.fifo_full (fifo_full),
 								.fifo_empty (fifo_empty),
 								.fifo_data_pop (fifo_data_pop),
 								.ram_wr_addr_l (ram_wr_addr_l),
 								.CE_bar_l (CE_bar_l),
 								.RW_bar_l (RW_bar_l),
 								.OE_bar_l (OE_bar_l),
 								.BUSY_bar_l (BUSY_bar_l),
 								.INTR_bar_l (INTR_bar_l),
 								.ram_wr_data (ram_wr_data),
 								.base_addr (0),
 								.batch_done (0)
								);





 generic_fifo #(
 								. FIFO_DATA_WIDTH  (32),
								. FIFO_DEPTH  (16)
) i_sciacc_resp_data_fifo(
								.clk (clk),
 								.reset_n (reset_n),
 								.fifo_data_in (sciacc_resp_data_fifo_fifo_data_in),
 								.fifo_data_push (sciacc_resp_data_fifo_fifo_data_push),
 								.fifo_data_pop (sciacc_resp_data_fifo_fifo_data_pop),
 								.fifo_data_out (sciacc_resp_data_fifo_fifo_data_out),
 								.fifo_data_out_vld (sciacc_resp_data_fifo_fifo_data_out_vld),
 								.fifo_full (fifo_full),
 								.fifo_empty (sciacc_resp_data_fifo_fifo_empty)
								);


endmodule //ram_wr_dma_top.sv

//---------Gen by Python Script: integration_script.py ---------------//
