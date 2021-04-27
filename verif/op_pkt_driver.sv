`include "input_intf.sv"
`include "seq_item.sv"



class op_pkt_driver extends uvm_driver #(op_pkt);
   `uvm_component_utils(op_pkt_driver)
   function new(string name = "op_pkt_driver", uvm_component parent=null);
      super.new(name, parent);
   endfunction

   virtual input_intf vif;

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual input_intf)::get(this, "", "input_intf", vif))
	`uvm_fatal("DRV", "Could not get vif")
   endfunction

   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
	 op_pkt m_item;
	 `uvm_info("DRV", $sformatf("Wait for item from sequencer"), UVM_LOW)
	 seq_item_port.get_next_item(m_item);
	 drive_item(m_item);
	 seq_item_port.item_done();
      end
   endtask

   virtual task drive_item(op_pkt m_item);
      if(vif.ready) begin
  	 vif.pkt_valid 	<= 1;
	 vif.op_pkt__data 	<= m_item.data;
	 vif.op_pkt__mode 	<= m_item.mode;
	 vif.op_pkt__res 	<= m_item.res;

	 @ (posedge vif.clk);
	 vif.pkt_valid	<= 0;
      end
      else begin
	 vif.pkt_valid 	<= 0;
      end // else: !if(vif.ready)
      

   endtask
endclass
