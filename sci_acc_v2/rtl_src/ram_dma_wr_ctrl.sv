module ram_dma_wr_ctrl(
							input logic clk,
							input logic reset_n,
							// FIFO output interface //
							input logic [FIFO_DATA_WIDTH-1:0] 	fifo_data_out,
							input logic							  		fifo_data_out_vld,
							input logic							  		fifo_full,
							input logic							  		fifo_empty,
							output logic 							  	fifo_data_pop,
							// RAM write interface //
							output logic [RAM_ADDR_WIDTH-1:0]	ram_wr_addr_l,
							output logic 								CE_bar_l,
							output logic								RW_bar_l,
							output logic								OE_bar_l,
							input logic									BUSY_bar_l,
							input	logic									INTR_bar_l,
							output logic [RAM_DATA_WIDTH-1:0]	ram_wr_data,
							// Config inputs //
							input logic [RAM_ADDR_WIDTH-1:0]		base_addr,
							input logic									batch_done
							);
	


	
							
//----------- Declarations ------------//
typedef enum logic[3:0]{
			IDLE,
			WR_PLACE_ADDR,
			WR_PLACE_DATA,
			WR_START,
			WR_BYTE,
			DONE
			} t_ram_wr_ctrl_st;

t_ram_wr_ctrl_st  ram_wr_ctrl_cur_st;
t_ram_wr_ctrl_st  ram_wr_ctrl_nxt_st;
logic [5:0] byte_cntr;
logic [5:0] byte_cntr_plus1;
logic [RAM_ADDR_WIDTH-1:0]	ram_addr_pc_o;
logic [RAM_ADDR_WIDTH-1:0]	ram_addr_pc_o_plus1;
logic [RAM_DATA_WIDTH-1:0]	ram_wr_data_bytes[0:3];
logic upd_byte_cntr;
logic clr_upd_byte_cntr;
logic max_num_bytes_rchd;
logic upd_pc;
//-------------------------------------//





//---------- Split 32 bit data into 4 Bytes -------------//
  assign ram_wr_data_bytes[3] = (fifo_data_out_vld)? fifo_data_out[31:24]: 8'h00;
  assign ram_wr_data_bytes[2] = (fifo_data_out_vld)? fifo_data_out[23:16]: 8'h00;
  assign ram_wr_data_bytes[1] = (fifo_data_out_vld)? fifo_data_out[15:8]: 8'h00;
  assign ram_wr_data_bytes[0] = (fifo_data_out_vld)? fifo_data_out[7:0]: 8'h00;
//--------------------------------------------------------//






//----------- Byte counter logic --------------//
assign byte_cntr_plus1 = byte_cntr + 1;
assign clr_upd_byte_cntr = (ram_wr_ctrl_cur_st == IDLE);

always_ff@(posedge clk) begin
	if(!reset_n) begin
		byte_cntr <= 0;
	end
	else begin
		if(upd_byte_cntr) 				byte_cntr <= byte_cntr_plus1;
		else if(clr_upd_byte_cntr) 	byte_cntr <= 0;
		else 									byte_cntr <= byte_cntr;
	end
end
//---------------------------------------------//






//-------------- Write program counter ----------------//
assign ram_addr_pc_o_plus1 = ram_addr_pc_o + 1;
assign upd_pc = upd_byte_cntr;
assign clr_pc = batch_done;

always_ff@(posedge clk) begin
	if(!reset_n) begin
		ram_addr_pc_o <= 0;
	end
	else begin
		if(upd_pc) 				ram_addr_pc_o <= ram_addr_pc_o_plus1;
		else if(batch_done)	ram_addr_pc_o <= 0;
		else						ram_addr_pc_o <= ram_addr_pc_o;
	end
end
//------------------------------------------------//





//------------- RAM WR CTRL FSM ------------//
  assign max_num_bytes_rchd = (byte_cntr == (BYTES_PER_BURST - 1));

always_ff@(posedge clk) begin
	if(!reset_n) begin
		ram_wr_ctrl_cur_st <= IDLE;
	end
	else begin
		ram_wr_ctrl_cur_st <= ram_wr_ctrl_nxt_st;
	end
end


always@(*) begin

	// Defaults //
	ram_wr_ctrl_nxt_st = ram_wr_ctrl_cur_st;
	ram_wr_addr_l = 0;
	CE_bar_l = 1;
	RW_bar_l = 1;
	ram_wr_data = 0;
	upd_byte_cntr = 0;
	fifo_data_pop = 0;
	OE_bar_l = 1;
	//----------//


	//------- Transitions -------------//
	case(ram_wr_ctrl_cur_st)
	
	
		//------- IDLE --------//
		IDLE: begin
			if(fifo_data_out_vld) ram_wr_ctrl_nxt_st = WR_START;
		end//------- IDLE --------//
			
		
		
		
		//------- WR_START --------//
		WR_START: begin
			CE_bar_l = 0;
			ram_wr_ctrl_nxt_st = WR_PLACE_ADDR;
		end//------- WR_START --------//
		
		
		
		
		//------- WR_PLACE_ADDR --------//
		WR_PLACE_ADDR: begin
			CE_bar_l = 0;
			ram_wr_addr_l = base_addr + ram_addr_pc_o;
			ram_wr_ctrl_nxt_st = WR_PLACE_DATA;
		end//------- WR_PLACE_ADDR --------//
				
		
		
		
		//------- WR_PLACE_DATA --------//
		WR_PLACE_DATA: begin
			CE_bar_l = 0;
			ram_wr_addr_l = base_addr + ram_addr_pc_o;
			ram_wr_data = ram_wr_data_bytes[byte_cntr];
			ram_wr_ctrl_nxt_st = WR_BYTE;
		end//------- WR_PLACE_DATA --------//
		
		
			
		
		//------- WR_BYTE --------//
		WR_BYTE: begin
			CE_bar_l = 0;
			ram_wr_addr_l = base_addr + ram_addr_pc_o;
			ram_wr_data = ram_wr_data_bytes[byte_cntr];
			RW_bar_l = 0;
			ram_wr_ctrl_nxt_st = DONE;
		end//------- WR_BYTE --------//

		
			
		
		//------- DONE --------//
		DONE: begin		
			CE_bar_l = 1;
			ram_wr_addr_l = base_addr + ram_addr_pc_o;
			ram_wr_data = ram_wr_data_bytes[byte_cntr];
			RW_bar_l = 0;		
			upd_byte_cntr = 1;
			if(max_num_bytes_rchd) 	begin
				ram_wr_ctrl_nxt_st = IDLE;
				fifo_data_pop = 1;
			end
			else	begin
				ram_wr_ctrl_nxt_st = WR_START;
			end
		end//------- DONE --------//
		
		
		
		
		//------- default --------//
		default: begin
			ram_wr_ctrl_nxt_st = IDLE;
		end//------- default --------//
		
	endcase

end
//------------------------------------------//
endmodule // ram_dma_wr_ctrl //