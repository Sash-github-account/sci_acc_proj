`ifndef _parameters_vh_
`define _parameters_vh_
parameter integer DATA_WIDTH = 32;
parameter integer NUM_MODES = 3;
parameter integer MAX_NUM_TERMS = 16;
parameter integer RES_WIDTH = $clog2(MAX_NUM_TERMS);
parameter [31:0] ACCUM_INIT = 32'h3f800000;
parameter integer NUM_COEFF = 33;
parameter integer ADDR_WIDTH = 6;
parameter integer FIFO_DEPTH = 32;
parameter integer FIFO_CNT_WIDTH = $clog2(FIFO_DEPTH);
parameter integer CNTR_DEPTH = $clog2(MAX_NUM_TERMS)+1;
`endif



