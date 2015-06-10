`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:56:11 05/27/2015 
// Design Name: 
// Module Name:    process_round 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module process_round (
	input [511:0] block,
	input [511:0] key,
	input [63:0] r_const,
	output [511:0] block_out,
	output [511:0] key_out
);

	wire [63:0] b1,b2,b3,b4,b5,b6,b7,b8;
	wire [63:0] k1,k2,k3,k4,k5,k6,k7,k8;
	
	wire [63:0] b1o,b2o,b3o,b4o,b5o,b6o,b7o,b8o;
	wire [63:0] k1o,k2o,k3o,k4o,k5o,k6o,k7o,k8o;

	// Cyclical Permutations - Pi
	assign b1 = {block[504 +: 8],block[ 48 +: 8],block[104 +: 8],block[160 +: 8],block[216 +: 8],block[272 +: 8],block[328 +: 8],block[384 +: 8]};
	assign b2 = {block[440 +: 8],block[496 +: 8],block[ 40 +: 8],block[ 96 +: 8],block[152 +: 8],block[208 +: 8],block[264 +: 8],block[320 +: 8]};
	assign b3 = {block[376 +: 8],block[432 +: 8],block[488 +: 8],block[ 32 +: 8],block[ 88 +: 8],block[144 +: 8],block[200 +: 8],block[256 +: 8]};
	assign b4 = {block[312 +: 8],block[368 +: 8],block[424 +: 8],block[480 +: 8],block[ 24 +: 8],block[ 80 +: 8],block[136 +: 8],block[192 +: 8]};
	assign b5 = {block[248 +: 8],block[304 +: 8],block[360 +: 8],block[416 +: 8],block[472 +: 8],block[ 16 +: 8],block[ 72 +: 8],block[128 +: 8]};
	assign b6 = {block[184 +: 8],block[240 +: 8],block[296 +: 8],block[352 +: 8],block[408 +: 8],block[464 +: 8],block[  8 +: 8],block[ 64 +: 8]};
	assign b7 = {block[120 +: 8],block[176 +: 8],block[232 +: 8],block[288 +: 8],block[344 +: 8],block[400 +: 8],block[456 +: 8],block[  0 +: 8]};
	assign b8 = {block[ 56 +: 8],block[112 +: 8],block[168 +: 8],block[224 +: 8],block[280 +: 8],block[336 +: 8],block[392 +: 8],block[448 +: 8]};

	assign k1 = {key[504 +: 8],key[ 48 +: 8],key[104 +: 8],key[160 +: 8],key[216 +: 8],key[272 +: 8],key[328 +: 8],key[384 +: 8]};
	assign k2 = {key[440 +: 8],key[496 +: 8],key[ 40 +: 8],key[ 96 +: 8],key[152 +: 8],key[208 +: 8],key[264 +: 8],key[320 +: 8]};
	assign k3 = {key[376 +: 8],key[432 +: 8],key[488 +: 8],key[ 32 +: 8],key[ 88 +: 8],key[144 +: 8],key[200 +: 8],key[256 +: 8]};
	assign k4 = {key[312 +: 8],key[368 +: 8],key[424 +: 8],key[480 +: 8],key[ 24 +: 8],key[ 80 +: 8],key[136 +: 8],key[192 +: 8]};
	assign k5 = {key[248 +: 8],key[304 +: 8],key[360 +: 8],key[416 +: 8],key[472 +: 8],key[ 16 +: 8],key[ 72 +: 8],key[128 +: 8]};
	assign k6 = {key[184 +: 8],key[240 +: 8],key[296 +: 8],key[352 +: 8],key[408 +: 8],key[464 +: 8],key[  8 +: 8],key[ 64 +: 8]};
	assign k7 = {key[120 +: 8],key[176 +: 8],key[232 +: 8],key[288 +: 8],key[344 +: 8],key[400 +: 8],key[456 +: 8],key[  0 +: 8]};
	assign k8 = {key[ 56 +: 8],key[112 +: 8],key[168 +: 8],key[224 +: 8],key[280 +: 8],key[336 +: 8],key[392 +: 8],key[448 +: 8]};


	// Process Key Rows
	process_row key_row1 (k1, k1o);
	process_row key_row2 (k2, k2o);
	process_row key_row3 (k3, k3o);
	process_row key_row4 (k4, k4o);
	process_row key_row5 (k5, k5o);
	process_row key_row6 (k6, k6o);
	process_row key_row7 (k7, k7o);
	process_row key_row8 (k8, k8o);

	assign key_out = {k1o ^ r_const,k2o,k3o,k4o,k5o,k6o,k7o,k8o};

	// Process Block Rows
	process_row blk_row1 (b1, b1o);
	process_row blk_row2 (b2, b2o);
	process_row blk_row3 (b3, b3o);
	process_row blk_row4 (b4, b4o);
	process_row blk_row5 (b5, b5o);
	process_row blk_row6 (b6, b6o);
	process_row blk_row7 (b7, b7o);
	process_row blk_row8 (b8, b8o);

	// Add Key
	assign block_out = {b1o,b2o,b3o,b4o,b5o,b6o,b7o,b8o} ^ key_out;

endmodule
