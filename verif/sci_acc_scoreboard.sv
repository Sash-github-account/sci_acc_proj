class sci_acc_scoreboard extends uvm_scoreboard;
   
   `uvm_component_utils(sci_acc_scoreboard)
   `uvm_analysis_imp_decl(_port_a)
   `uvm_analysis_imp_decl(_port_b)
   
   function new(string name="sci_acc_scoreboard", uvm_component parent=null);
      super.new(name, parent);
   endfunction

   uvm_analysis_imp_port_b #(comp_reslt, sci_acc_scoreboard) comp_reslt_analysis_imp;
   uvm_analysis_imp_port_a #(op_pkt, sci_acc_scoreboard) op_pkt_analysis_imp;
   //real exp_fp_num = $exp();
   
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      comp_reslt_analysis_imp = new("comp_reslt_analysis_imp", this);
      op_pkt_analysis_imp = new("op_pkt_analysis_imp", this);
   endfunction // build_phase
   
  virtual function write_port_a(op_pkt item);
     `uvm_info("write",$sformatf("Data:",item.data), UVM_MEDIUM);
   endfunction // write_port_a   

  virtual function write_port_b(comp_reslt c_item);
    `uvm_info("write",$sformatf("Data:",c_item.data_out), UVM_MEDIUM);
   endfunction // write_port_a   
   
 //  virtual function write_port_b(op_pkt item);
   //endfunction // write_port_b


   
endclass // sci_acc_scoreboard

