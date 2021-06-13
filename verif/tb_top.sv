// Top level testbench module to instantiate design, interface
// start clocks and run the test
`include "sci_acc_test.sv"
module tb;
   reg clk;

   always #1 clk =~ clk;
   input_intf 	i_if (clk);
   output_intf 	o_if (clk);
   rst_intf 	rst_if (clk);

   sci_acc_top DUT(
	       .clk(clk),
	       .rst_n(rst_if.rst_n),
     //.rst_n(t0.rst_vif.rst_n),
	       .pkt_valid(i_if.pkt_valid), 
	       .op_pkt__data(i_if.op_pkt__data),
	       .op_pkt__mode(i_if.op_pkt__mode),
	       .op_pkt__res(i_if.op_pkt__res), 

	       .pkt_dropd(o_if.pkt_dropd),
	       .ready(i_if.ready),
	       .data_out(o_if.data_out),
	       .done(o_if.done)
	       );
   //sci_acc_test t0;
   rand_test t0;

  initial begin
          $dumpfile ("dump.vcd");
           $dumpvars;
  end
  
   initial begin

      clk <= 0;
     uvm_config_db#(virtual input_intf)::set(null,"uvm_test_top", "input_intf",i_if);
     uvm_config_db#(virtual output_intf)::set(null,"uvm_test_top", "output_intf",o_if);
     uvm_config_db#(virtual rst_intf)::set(null,"uvm_test_top", "rst_intf",rst_if);

     run_test("rand_test");
      //t0 = new;
      //t0.i_vif  = i_if;
      //t0.o_vif  = o_if;
      //t0.rst_vif= rst_if;
        //rst_if  =  t0.rst_vif;
      //t0.run();

      // Because multiple components and clock are running
      // in the background, we need to call $finish explicitly
      #500 $finish;
   end


endmodule
