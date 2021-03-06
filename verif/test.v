module test; 
`include "param.vh"
   
   reg 			clk;
   reg 			rst_n;
   reg 			pkt_valid; 
   reg [DATA_WIDTH-1:0] op_pkt__data;
   reg [NUM_MODES-1:0] 	op_pkt__mode;
   reg [RES_WIDTH-1:0] 	op_pkt__res; 

   wire			pkt_dropd;
   wire 		ready;
   wire [DATA_WIDTH-1:0] data_out;
   wire 		 done;
   
   initial
     begin
	$display($time, " << Starting the Simulation >>");
	clk = 1’b0; // at time 0
	rst_n = 1; // reset is active
	#20 rst_n = 1’b0; // at time 20 release reset
     end

   always
     #10 clk = ~clk; 

   sci_acc_top inst(
		    .clk,
		    .rst_n,
		    .pkt_valid, 
		    .op_pkt__data,
		    .op_pkt__mode,
		    .op_pkt__res, 

		    .pkt_dropd,
		    .ready,
		    .data_out,
		    .done
		    );
   
endmodule // test

