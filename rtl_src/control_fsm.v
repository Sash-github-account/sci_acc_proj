`include "param.vh"



module control_fsm (
		    input 	clk,
		    input 	rst_n,
		    input 	op_pkt_available,
		    input [NUM_MODES-1:0] mode,
		    input [RES_WIDTH-1:0] res,
		    input [RES_WIDTH-1:0] term_cnt,

		    output reg 	done,
		    output reg 	rd_fifo,
		    output reg 	op,
		    output reg 	stg1_en,
		    output reg 	stg2_en,
		    output reg 	start_cnt,
		    output reg 	rd_coeff
		    );



   // Parameter file include //
`include "param.vh"
   //______________// 



   // Declarations //
   reg [3:0] 			cur_state;
   reg [3:0] 			nxt_state; 
   //______________//    


   
   // State Definitions //
   parameter IDLE = 4'h0;
   parameter READ_FIFO = 4'h1;
   parameter MODE_DETECT = 4'h2;
   parameter RUN_EXP = 4'h3;
   parameter DONE = 4'h4;   
   //______________//    


   
   // Operation definition //
   parameter ADD = 1'b0;
   parameter SUB = 1'b1;
   //______________//    
   


   // State Outputs //
   always@(posedge clk ) begin
      if(rst_n) begin
	 rd_coeff      <= 0;
	 done    <= 0;
	 stg1_en <= 0;
	 stg2_en <= 0;
	 cur_state <= IDLE;	 
      end
      else begin
	 cur_state <= nxt_state;
	 case (cur_state)
	   IDLE: begin
	      stg1_en <= 0; stg2_en <=0; start_cnt <= 0; rd_coeff <= 0; op <= ADD; done <= 0; rd_fifo <= 0;
	   end
	   
	   READ_FIFO: begin
	      stg1_en <= 0; stg2_en <=0; start_cnt <= 0; rd_coeff <= 0; op <= ADD; done <= 0; rd_fifo <= 1;
	   end

	   MODE_DETECT: begin
	      stg1_en <= 1; stg2_en <= 0; start_cnt <= 1; rd_coeff <= 1; op <= ADD; done <= 0; rd_fifo <= 0;
	   end

	   RUN_EXP: begin
	      stg1_en <= 1; stg2_en <= 1; start_cnt <= 0; rd_coeff <= 1; op <= ADD; done <= 0; rd_fifo <= 0;
	   end

	   DONE: begin
	      stg1_en <= 0; stg2_en <= 0; start_cnt <= 0; rd_coeff <= 0; op <= ADD; done <= 1; rd_fifo <= 0;
	   end
	   
	   default: begin
	      stg1_en <= 0; stg2_en <=0; start_cnt <= 0; rd_coeff <= 0; op <= ADD; done <= 0; rd_fifo <= 0;
	   end
	 endcase // case (cur_state)	 
      end
   end // always@ (posedge clk or negedge rst_n)
   //______________//    

   

   // State transitions //
   always@(*) begin
     nxt_state = IDLE;
      case(cur_state)
	IDLE: begin
	   if(op_pkt_available) nxt_state = READ_FIFO;
	   else nxt_state = IDLE;
	end
	
	READ_FIFO: begin
	   nxt_state = MODE_DETECT;
	end
	
	MODE_DETECT: begin
      if(mode == 3'b001 | mode == 3'b010 | mode == 3'b100) nxt_state = RUN_EXP;
	   else 	      nxt_state = IDLE;
	end

	RUN_EXP: begin
      if(term_cnt < res - 2) nxt_state = RUN_EXP;
	   else nxt_state = DONE;
	end

	DONE: begin
	   nxt_state = IDLE;
	end
	
	default: begin
	   nxt_state = IDLE;
	end
      endcase // case (cur_state)
   end // always@ (*)
   //______________//    
   
   
   
endmodule // control_fsm
