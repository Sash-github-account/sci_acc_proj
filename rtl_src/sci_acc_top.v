`include "param.vh"
`include "input_interface.v"
`include "sci_compute_core.v"



module sci_acc_top(
		   input 		       clk,
		   input 		       rst_n,
		   input 		       pkt_valid, 
		   input [DATA_WIDTH-1:0]      op_pkt__data,
		   input [NUM_MODES-1:0]       op_pkt__mode,
		   input [RES_WIDTH-1:0]       op_pkt__res, 

		   output reg 		       pkt_dropd,
		   output reg 		       ready,
		   output reg [DATA_WIDTH-1:0] data_out,
		   output reg 		       done
		   );


   
   // Parameter file include //
`include "param.vh"
   //_____________//



   // Declarations //
   wire 				       fifo_pop;
   wire 				       op_done;
   wire [DATA_WIDTH-1:0] 		       final_value;
   wire [RES_WIDTH-1:0] 		       res;
   wire [NUM_MODES-1:0] 		       mode;
   wire 				       op_pkt_available;
   wire [DATA_WIDTH-1:0] 		       x_value;  
   //_____________//



   // Output assignments //
   assign data_out = final_value;
   assign done = op_done;
   //_____________//



   // Input interface instance //
   input_interface input_intf(
			      // Inputs
			      .clk(clk),
			      .rst_n(rst_n),
			      .pkt_valid(pkt_valid),
			      .op_pkt__data(op_pkt__data),
			      .op_pkt__mode(op_pkt__mode),
			      .op_pkt__res(op_pkt__res),
			      .fifo_pop(fifo_pop),
			      // Outputs
			      .pkt_dropd,
			      .ready,
			      .in_fifo_data_o(x_value),
			      .in_fifo_mode_o(mode),
			      .in_fifo_res_o(res),
			      .op_pkt_available(op_pkt_available)
			      );   
   //_____________//



   // Compute Core instance //
     sci_compute_core sci_compute_core(
				       // Inputs
				       .clk(clk),
				       .rst_n(rst_n),
				       .op_pkt_available(op_pkt_available),
				       .res(res),
				       .mode(mode),
				       .data_x(x_value),
				       // Outputs
				       .final_value(final_value),
				       .fifo_pop(fifo_pop),
				       .op_done(op_done)				 
				       );
   //_____________//



   // Output interface instance //
       //TBD
   //_____________//



endmodule // sci_acc_top
