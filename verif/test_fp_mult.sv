module test_fp_mult; 
`include "param.vh"
   reg [DATA_WIDTH-1:0]      data_1;
   reg [DATA_WIDTH-1:0]      data_2;
   wire [DATA_WIDTH-1:0]     data_prod;

   
   initial
     begin
	$dumpfile("dump.vcd"); $dumpvars;
	$display($time, " << Starting the Simulation >>");
	data_1 = 32'h3c54fdf4;
	data_2 = 32'h3ccccccd;
	#10;
        data_1 = 32'hbccccccd;
       	data_2 = 32'h3c54fdf4;
	#10;
        data_1 = 32'h41b80000; //23
       	data_2 = 32'h42340000; //45
	#10;
	$finish;
	
     end
   
   initial  begin      $monitor(" data_1=%x,data_2=%x,data_prod=%x \n",data_1, data_2, data_prod ); end


   fp_mult dut(
	       .data_1(data_1),
	       .data_2(data_2),
	       .data_prod(data_prod)
	       );

   
endmodule // test_fp_mult

