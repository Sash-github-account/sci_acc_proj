`include "param.vh"



interface rst_intf (input clk);

   // logic Declarations //
   logic rst_n;
   //_____________//

   // Clocking Block Definition //
   clocking cb @ (posedge clk);
      default input #1step output #1ns;
      input rst_n;
   endclocking // cb
   //_____________//
   
endinterface // rst_intf



interface input_intf (input clk);

   // logic Declarations //
   logic    pkt_valid;
   logic [DATA_WIDTH-1:0] op_pkt__data;
   logic [NUM_MODES-1:0]  op_pkt__mode;
   logic [RES_WIDTH-1:0]  op_pkt__res; 
   logic 		  ready;
   //_____________//

   // Clocking Block Definition //
   clocking cb @ (posedge clk);
      default input #1step output #1ns;
      input 		  pkt_valid, op_pkt__data, op_pkt__mode, op_pkt__res;
      output 		  ready;      
   endclocking // cb
   //_____________//
   
endinterface // input_intf



interface output_intf (input clk);
   
   // logic Declarations //
   logic 		  pkt_dropd;
   logic [DATA_WIDTH-1:0] data_out;
   logic 		  done;
   //_____________//
   
   // Clocking Block Definition //
   clocking cb @ (posedge clk);
      output 		  pkt_dropd, data_out, done;  
   endclocking // cb
   //_____________//
   
endinterface // output_intf
