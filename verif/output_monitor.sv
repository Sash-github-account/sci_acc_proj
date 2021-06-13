class output_monitor extends uvm_monitor;
   
   `uvm_component_utils(output_monitor)


   // Constructor //
   function new(string name="output_monitor", uvm_component parent=null);
      super.new(name, parent);
   endfunction // new
   //_____________________//



   // Declarations //
   uvm_analysis_port  #(comp_reslt) comp_reslt_analysis_port;
   uvm_analysis_port  #(op_pkt) op_pkt_analysis_port;
   virtual output_intf o_vif;
   virtual input_intf i_vif;
   //_____________________//



   // Build phase //
   virtual function void build_phase(uvm_phase phase);
      
      super.build_phase(phase);
      
     if (!uvm_config_db#(virtual output_intf)::get(this, "", "output_intf", o_vif))
	`uvm_fatal("MON", "Could not get o_vif")
      
       if (!uvm_config_db#(virtual input_intf)::get(this, "", "input_intf", i_vif))
	`uvm_fatal("MON", "Could not get i_vif")

      comp_reslt_analysis_port = new ("comp_reslt_analysis_port", this);
      
      op_pkt_analysis_port = new ("op_pkt_analysis_port", this);
      
   endfunction // build_phase
   //_____________________//



   // Run phase //
   virtual task run_phase(uvm_phase phase);
      
      super.run_phase(phase);
      
      fork
	 sample_port("Thread0");
      join
      
   endtask // run_phase
   //_____________________//


   
   // Task monitoring the activity on the interfaces //   
   virtual task sample_port(string tag="");

      forever begin
	 @(posedge o_vif.clk);
	 
	 if (o_vif.done) begin
            comp_reslt item = new;
	    item.valid = 1;	    
            item.data_out = o_vif.data_out;
            `uvm_info("MON", $sformatf("T=%0t [Monitor] %s First part over",$time, tag), UVM_LOW)
            comp_reslt_analysis_port.write(item);
            `uvm_info("MON", $sformatf("T=%0t [Monitor] %s Second part over, item:",$time, tag), UVM_LOW)
            item.print();
	 end // if ( vif.done)

         if  (i_vif.pkt_valid ) begin
	    op_pkt in_pkt = new;
	    in_pkt.dropd = 0;	    
            in_pkt.mode = i_vif.op_pkt__mode;
	    in_pkt.res = i_vif.op_pkt__res; 	    
            in_pkt.data = i_vif.op_pkt__data;
            `uvm_info("MON", $sformatf("T=%0t [Monitor] %s First part over",$time, tag), UVM_LOW)
            op_pkt_analysis_port.write(in_pkt);
            `uvm_info("MON", $sformatf("T=%0t [Monitor] %s Second part over, item:",$time, tag), UVM_LOW)
            in_pkt.print();
	 end
	 
         if (o_vif.pkt_dropd & i_vif.pkt_valid) begin
	    op_pkt drpod_pkt = new;
	    drpod_pkt.dropd = 1;	    
            drpod_pkt.mode = i_vif.op_pkt__mode;
	    drpod_pkt.res = i_vif.op_pkt__res; 	    
            drpod_pkt.data = i_vif.op_pkt__data;
            `uvm_info("MON", $sformatf("T=%0t [Monitor] %s First part over",$time, tag), UVM_LOW)
            op_pkt_analysis_port.write(drpod_pkt);
            `uvm_info("MON", $sformatf("T=%0t [Monitor] %s Second part over, item:",$time, tag), UVM_LOW)
            drpod_pkt.print();
	 end
      end
   endtask // sample_port
   //_____________________//


   
endclass // output_monitor

