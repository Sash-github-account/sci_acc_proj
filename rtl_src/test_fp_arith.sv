module test_fp_arith; 
`include "param.vh"
   reg [DATA_WIDTH-1:0]      data_1;
   reg [DATA_WIDTH-1:0]      data_2;
   reg 			     op_sel;
   reg 			     en;
   wire [DATA_WIDTH-1:0]     data_o;

   
   initial
     begin
	$dumpfile("dump.vcd"); $dumpvars;
	$display($time, " << Starting the Simulation >>");

       en = 1;
	// Addition testing begin //
       // data2[22:0]: 000_0000_0000_0000_0000_0000; exp2:0011_1111_1
       // data1[22:0]: 000_0000_0000_0000_0000_0000; exp1:0011_1111_0
       // to make exps equal: add 2 0011_1111_1110
	$display( " << Starting Addition tesing \n >>");
	op_sel = 0;
	// test both +ve
	$display( " << Adding two positive numbers \n >>");
	data_2 = 32'h3f800000;
	data_1 = 32'h3f000000;
	#10;
       	// test data_1 +ve and data_2 -ve
       $display( " << data_1 +ve \n >>");
	data_1 = 32'h3c54fdf4;
	data_2 = 32'hbccccccd;
	#10;
        // test data_1 +ve and data_2 -ve
       $display( " << data_2 +ve\n >>");
	data_1 = 32'hbc54fdf4;
	data_2 = 32'h3ccccccd;
	#10;
	// test both -ve
	$display( " << Adding two negative numbers \n >>");
	data_1 = 32'hbc54fdf4;
	data_2 = 32'hbccccccd;
	#10;
	//--addition testing done--//

	// Subtraction testing begin //
	$display( " << Starting Subtraction tesing \n >>");
	op_sel = 1;
	// test subtraction when both are +ve
	$display( " << Subtract two positive numbers \n >>");
	data_1 = 32'h3c54fdf4;
	data_2 = 32'h3ccccccd;
	#10;
	// test addition when data_1 +ve and data_2 -ve 
       $display( " << data_1 +ve \n >>");
	data_1 = 32'h3c54fdf4;
	data_2 = 32'hbccccccd;
	#10;
	// test addition when data_2 +ve and data_1 -ve 
       $display( " << data_2 +ve \n >>");
	data_1 = 32'hbc54fdf4;
	data_2 = 32'h3ccccccd;
	#10;
	// test subtraction when both -ve
	$display( " << Subtract two negative numbers \n >>");
	data_1 = 32'hbc54fdf4;
	data_2 = 32'hbccccccd;
	#10;
	//--subtraction testing done--//
	$finish;	
     end
   
   initial  begin      $monitor(" data_1=%x,data_2=%x,data_o=%x \n",data_1, data_2, data_o ); end


   fp_arith dut(
		.data_1(data_1),
		.data_2(data_2),
		.op_sel(op_sel),
     .en(en),
		.data_o(data_o)
		);

   
   
endmodule // test_fp_arith

