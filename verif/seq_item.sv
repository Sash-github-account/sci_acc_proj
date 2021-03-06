class op_pkt extends uvm_sequence_item;


   
`include "param.vh"

   
   logic dropd;
   rand bit [DATA_WIDTH-1:0] data;   
   rand bit [NUM_MODES-1:0]  mode;   
   rand bit [RES_WIDTH-1:0]  res;

   // Constraints for resolution and mode //0x3f800000,0x3dcccccd,0x3c23d70a
                                          //0x402df854,0x3f8d763e,0x3f814953
  constraint c_data { data inside {'h3f800000};}
   constraint c_res { res inside {[5:15]}; }
  constraint c_mode { mode inside {[1:1]}; }

   
   // Use utility macros to implement standard functions
   // like print, copy, clone, etc
   `uvm_object_utils_begin(op_pkt)
      `uvm_field_int (data, UVM_DEFAULT)
      `uvm_field_int (mode, UVM_DEFAULT)
      `uvm_field_int (res, UVM_DEFAULT)
   `uvm_object_utils_end

   function new(string name = "op_pkt");
      super.new(name);
   endfunction // new
   
endclass // op_pkt



class comp_reslt extends uvm_sequence_item;
   
`include "param.vh"

   bit 		             valid;   
   bit [DATA_WIDTH-1:0]      data_out;
   
   // Use utility macros to implement standard functions
   // like print, copy, clone, etc
   `uvm_object_utils_begin(comp_reslt)
      `uvm_field_int (valid,     UVM_DEFAULT)
      `uvm_field_int (data_out, UVM_DEFAULT)
   `uvm_object_utils_end

   function new(string name = "comp_reslt");
      super.new(name);
   endfunction // new
   
endclass // comp_reslt


