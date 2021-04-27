`include "sci_acc_env.sv"
`include "get_seq_item.sv"



class sci_acc_base_test extends uvm_test;
  `uvm_component_utils(sci_acc_base_test)
  function new(string name = "sci_acc_base_test", uvm_component parent=null);
      super.new(name, parent);
   endfunction

   sci_acc_env e0;
  gen_op_pkt_seq seq;
   virtual rst_intf rst_vif;
   virtual input_intf i_vif;
   virtual output_intf o_vif;

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      e0 = sci_acc_env::type_id::create("e0", this);
      
      if (!uvm_config_db#(virtual input_intf)::get(this, "", "input_intf", i_vif))
	`uvm_fatal("TEST", "Did not get vif")

      uvm_config_db#(virtual input_intf)::set(this, "e0.a0.*", "input_intf", i_vif);
      
      if (!uvm_config_db#(virtual output_intf)::get(this, "", "output_intf", o_vif))
	`uvm_fatal("TEST", "Did not get vif")

      uvm_config_db#(virtual output_intf)::set(this, "e0.a0.*", "output_intf", o_vif);
      
      if (!uvm_config_db#(virtual rst_intf)::get(this, "", "rst_intf", rst_vif))
	`uvm_fatal("TEST", "Did not get vif")

      uvm_config_db#(virtual rst_intf)::set(this, "e0.a0.*", "rst_intf", rst_vif);
     
           seq = gen_op_pkt_seq::type_id::create("seq");
   endfunction

   virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      apply_reset();

      seq.start(e0.a0.s0);
     #500;
      phase.drop_objection(this);
   endtask

   virtual task apply_reset();
      rst_vif.rst_n <= 1;
      repeat(5) @ (posedge rst_vif.clk);
      rst_vif.rst_n <= 0;
      repeat(10) @ (posedge rst_vif.clk);
   endtask
endclass

class rand_test extends sci_acc_base_test;
  `uvm_component_utils(rand_test)
  
  function new (string name = "rand_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
      seq.randomize();
  endfunction
endclass

