
module coeff_rom(
		 input logic			     			clk,
		 input logic			     			rst_n,
		 input logic			     			rd,
		 input logic [ADDR_WIDTH-1:0]    rd_addr,
		 output logic							coeff_o_vld,						
		 output logic [DATA_WIDTH-1:0] 	coeff_out
		 );




   // Declarations //
  logic [DATA_WIDTH-1:0]      coeff_rom [NUM_COEFF-1:0];
   //_____________//


   
   // Coefficient ROM //
   always_ff@(posedge clk ) begin
      if(!rst_n)begin
	 coeff_rom[0] <= 32'h00000000;  // (1/0!)
	 coeff_rom[1] <= 32'h00000000;  // (1/1!)
	 coeff_rom[2] <= 32'h00000000;  // (1/2!)   
	 coeff_rom[3] <= 32'h00000000;  // (1/3!)
	 coeff_rom[4] <= 32'h00000000;  // (1/4!)
	 coeff_rom[5] <= 32'h00000000;  // (1/5!)
	 coeff_rom[6] <= 32'h00000000;  // (1/6!)
	 coeff_rom[7] <= 32'h00000000;  // (1/7!)
	 coeff_rom[8] <= 32'h00000000;  // (1/8!)
	 coeff_rom[9] <= 32'h00000000;  // (1/9!)
	 coeff_rom[10] <= 32'h00000000; // (1/10!)
	 coeff_rom[11] <= 32'h00000000; // (1/11!)
	 coeff_rom[12] <= 32'h00000000; // (1/12!)
	 coeff_rom[13] <= 32'h00000000; // (1/13!)
	 coeff_rom[14] <= 32'h00000000; // (1/14!)
	 coeff_rom[15] <= 32'h00000000; // (1/15!)
	 coeff_rom[16] <= 32'h00000000; // (1/16!)
	 coeff_rom[17] <= 32'h00000000; // (1/17!)
	 coeff_rom[18] <= 32'h00000000; // (1/18!)
	 coeff_rom[19] <= 32'h00000000; // (1/19!)
	 coeff_rom[20] <= 32'h00000000; // (1/20!)
	 coeff_rom[21] <= 32'h00000000; // (1/21!)
	 coeff_rom[22] <= 32'h00000000; // (1/22!)
	 coeff_rom[23] <= 32'h00000000; // (1/23!)
	 coeff_rom[24] <= 32'h00000000; // (1/24!)
	 coeff_rom[25] <= 32'h00000000; // (1/25!)
	 coeff_rom[26] <= 32'h00000000; // (1/26!)
	 coeff_rom[27] <= 32'h00000000; // (1/27!)
	 coeff_rom[28] <= 32'h00000000; // (1/28!)
	 coeff_rom[29] <= 32'h00000000; // (1/29!)
	 coeff_rom[30] <= 32'h00000000; // (1/30!)
	 coeff_rom[31] <= 32'h00000000; // (1/31!)
	 coeff_rom[32] <= 32'h00000000; // (1/32!)

      end
      else begin
      coeff_rom[0] <= 32'h3f800000;  // (1/0!)
      coeff_rom[1] <= 32'h3f800000;  // (1/1!)
      coeff_rom[2] <= 32'h3f000000;  // (1/2!)   
      coeff_rom[3] <= 32'h3e2aaaab;  // (1/3!)
      coeff_rom[4] <= 32'h3d2aaaab;  // (1/4!)
      coeff_rom[5] <= 32'h3c088889;  // (1/5!)
      coeff_rom[6] <= 32'h3ab60b61;  // (1/6!)
      coeff_rom[7] <= 32'h39500d00;  // (1/7!)
      coeff_rom[8] <= 32'h37d00cfd;  // (1/8!)
      coeff_rom[9] <= 32'h3638ef15;  // (1/9!)
      coeff_rom[10] <= 32'h3493f27e; // (1/10!)
      coeff_rom[11] <= 32'h32d7322b; // (1/11!)
      coeff_rom[12] <= 32'h310f76c8; // (1/12!)
      coeff_rom[13] <= 32'h2f309231; // (1/13!)
      coeff_rom[14] <= 32'h2d49cba6; // (1/14!)
      coeff_rom[15] <= 32'h2b573f9f; // (1/15!)
      coeff_rom[16] <= 32'h29573f9f; // (1/16!)
      coeff_rom[17] <= 32'h274a963c; // (1/17!)
      coeff_rom[18] <= 32'h253413c3; // (1/18!)
      coeff_rom[19] <= 32'h2317a4da; // (1/19!)
      coeff_rom[20] <= 32'h20f2a15d; // (1/20!)
      coeff_rom[21] <= 32'h1eb8dc78; // (1/21!)
      coeff_rom[22] <= 32'h1c8671cb; // (1/22!)
      coeff_rom[23] <= 32'h1a3b0da1; // (1/23!)
      coeff_rom[24] <= 32'h17f96781; // (1/24!)
      coeff_rom[25] <= 32'h159f9e67; // (1/25!)
      coeff_rom[26] <= 32'h13447430; // (1/26!)
      coeff_rom[27] <= 32'h10e8d58e; // (1/27!)
      coeff_rom[28] <= 32'h0e850c51; // (1/28!)
      coeff_rom[29] <= 32'h0c12cfcc; // (1/29!)
      coeff_rom[30] <= 32'h099c9962; // (1/30!)
      coeff_rom[31] <= 32'h0721a697; // (1/31!)
      coeff_rom[32] <= 32'h04a1a697; // (1/32!)
      end
   end
   //_____________//

   

   // Read logic //
   always_ff@(posedge clk ) begin
		if(!rst_n) begin
			coeff_out <= 0;
			coeff_o_vld <= 0;
      end
      else begin
			if(rd) begin
				coeff_out <= coeff_rom[rd_addr];
				coeff_o_vld <= 1;
			end
			else begin
				coeff_out <= 0;
				coeff_o_vld <= 0;
			end
      end
   end
   //_____________//
   

   
endmodule // coeff_rom