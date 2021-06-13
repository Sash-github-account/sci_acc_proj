`include "param.vh"
`include "input_fifo.v"
`include "op_pkt_chk.v"



module input_interface(
		       input 			   clk,
		       input 			   rst_n,
		       input 			   pkt_valid,
		       input [DATA_WIDTH-1:0] 	   op_pkt__data,
		       input [NUM_MODES-1:0] 	   op_pkt__mode,
		       input [RES_WIDTH-1:0] 	   op_pkt__res,
		       input 			   fifo_pop,

		       output 			   pkt_dropd,
		       output 			   ready,
		       output reg [DATA_WIDTH-1:0] in_fifo_data_o,
		       output reg [NUM_MODES-1:0]  in_fifo_mode_o,
		       output reg [RES_WIDTH-1:0]  in_fifo_res_o,
		       output reg 		   op_pkt_available
		       );
   

   
   // Parameter file include //
 `include "param.vh"
   //______________//


  
   // Declarations //
   wire 					   n_ready;
   wire 					   fifo_push;  
   wire 					   fifo_empty; 
   wire [38:0] 					   fifo_data_out;   
   wire [38:0] 					   chkd_pkt; 
   //______________//


   
   // Outputs //
   assign ready = ~n_ready;
   assign op_pkt_available = ~fifo_empty;   
   assign in_fifo_data_o = fifo_data_out[31:0];   
   assign in_fifo_mode_o = fifo_data_out[34:32];   
   assign in_fifo_res_o  = fifo_data_out[38:35];
   //______________//

   
   
   // Operation Packet checker instance //
   op_pkt_chk pkt_chk(
		      .clk(clk),
		      .rst_n(rst_n),
		      .pkt_good(fifo_push),
		      .pkt_in_valid(pkt_valid),
		      .pkt_i({op_pkt__res, op_pkt__mode, op_pkt__data}),
		      .pkt_dropd(pkt_dropd),
		      .pkt_o(chkd_pkt)		      
		      );   
   //______________//

   

   // input FIFO instance //
   input_fifo in_fifo(     
			   .Clk(clk), 
			   .dataIn(chkd_pkt), 
			   .RD(fifo_pop), 
			   .WR(fifo_push), 
			   .EN(1'b1), 
			   .dataOut(fifo_data_out), 
			   .Rst(rst_n),
			   .EMPTY(fifo_empty), 
			   .FULL(n_ready)
			   );
   //______________//

   

endmodule // input_interface
