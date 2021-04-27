// Code source: https://esrd2014.blogspot.com/p/first-in-first-out-buffer.html //
`include "param.vh"
module input_fifo( Clk, 

                   dataIn, 

                   RD, 

                   WR, 

                   EN, 

                   dataOut, 

                   Rst,

                   EMPTY, 

                   FULL 

                   );
   
   `include "param.vh"

   input  Clk, 

	  RD, 

	  WR, 

	  EN, 

	  Rst;

   output EMPTY, 

          FULL;

   input [(DATA_WIDTH + NUM_MODES + RES_WIDTH)-1:0] dataIn;

   output reg [(DATA_WIDTH + NUM_MODES + RES_WIDTH)-1:0] dataOut; // internal registers 

   reg [FIFO_CNT_WIDTH-1:0] 	     Count = 0; 

   reg [(DATA_WIDTH + NUM_MODES + RES_WIDTH)-1:0] 	     FIFO [0:FIFO_DEPTH]; 

   reg [FIFO_CNT_WIDTH-1:0] 	     readCounter = 0, 

		     writeCounter = 0; 

   assign EMPTY = (Count==0)? 1'b1:1'b0; 

   assign FULL = (Count==FIFO_DEPTH)? 1'b1:1'b0; 

   always @ (posedge Clk) 

     begin 

	if (EN==0); 

	else begin 

	   if (Rst) begin 

	      readCounter = 0; 

	      writeCounter = 0; 

	   end 

	   else if (RD ==1'b1 && Count!=0) begin 

	      dataOut  = FIFO[readCounter]; 

	      readCounter = readCounter+1; 

	   end 

	   else if (WR==1'b1 && Count<FIFO_DEPTH) begin
	      FIFO[writeCounter]  = dataIn; 

	      writeCounter  = writeCounter+1; 

	   end 

	   else; 

	end 

	if (writeCounter==FIFO_DEPTH) 

	  writeCounter=0; 

	else if (readCounter==FIFO_DEPTH) 

	  readCounter=0; 

	else;

	if (readCounter > writeCounter) begin 

	   Count=readCounter-writeCounter; 

	end 

	else if (writeCounter > readCounter) 

	  Count=writeCounter-readCounter; 

	else;

     end 

endmodule
