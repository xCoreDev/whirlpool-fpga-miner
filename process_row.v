`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:18:54 05/28/2015 
// Design Name: 
// Module Name:    process_row 
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
module process_row (
	input  [63:0] in,
	output [63:0] out
);

	// Look Up Tables For E, EI, & R Mini-Boxes
	wire [3:0] E  [0:15] = {4'h1,4'hB,4'h9,4'hC,4'hD,4'h6,4'hF,4'h3,4'hE,4'h8,4'h7,4'h4,4'hA,4'h2,4'h5,4'h0};	//  E Mini-Box
	wire [3:0] EI [0:15] = {4'hF,4'h0,4'hD,4'h7,4'hB,4'hE,4'h5,4'hA,4'h9,4'h2,4'hC,4'h1,4'h3,4'h4,4'h8,4'h6};	// EI Mini-Box
	wire [3:0] R  [0:15] = {4'h7,4'hC,4'hB,4'hD,4'hE,4'h4,4'h9,4'hF,4'h6,4'h3,4'h8,4'hA,4'h2,4'h5,4'h1,4'h0};	//  R Mini-Box

	wire [7:0] b0,b1,b2,b3,b4,b5,b6,b7;
	wire [7:0] t0,t1,t2,t3,t4,t5,t6,t7;

	// Non-Linear Layer - Gama (S-Box)
	assign b0 = s_box(in[56 +: 8]);
	assign b1 = s_box(in[48 +: 8]);
	assign b2 = s_box(in[40 +: 8]);
	assign b3 = s_box(in[32 +: 8]);
	assign b4 = s_box(in[24 +: 8]);
	assign b5 = s_box(in[16 +: 8]);
	assign b6 = s_box(in[ 8 +: 8]);
	assign b7 = s_box(in[ 0 +: 8]);

	// Diffusion Layer - Theta
	assign t0 = b0 ^ mult_9(b1) ^ mult_2(b2) ^ mult_5(b3) ^ mult_8(b4) ^ b5 ^ mult_4(b6) ^ b7;
	assign t1 = b1 ^ mult_9(b2) ^ mult_2(b3) ^ mult_5(b4) ^ mult_8(b5) ^ b6 ^ mult_4(b7) ^ b0;
	assign t2 = b2 ^ mult_9(b3) ^ mult_2(b4) ^ mult_5(b5) ^ mult_8(b6) ^ b7 ^ mult_4(b0) ^ b1;
	assign t3 = b3 ^ mult_9(b4) ^ mult_2(b5) ^ mult_5(b6) ^ mult_8(b7) ^ b0 ^ mult_4(b1) ^ b2;
	assign t4 = b4 ^ mult_9(b5) ^ mult_2(b6) ^ mult_5(b7) ^ mult_8(b0) ^ b1 ^ mult_4(b2) ^ b3;
	assign t5 = b5 ^ mult_9(b6) ^ mult_2(b7) ^ mult_5(b0) ^ mult_8(b1) ^ b2 ^ mult_4(b3) ^ b4;
	assign t6 = b6 ^ mult_9(b7) ^ mult_2(b0) ^ mult_5(b1) ^ mult_8(b2) ^ b3 ^ mult_4(b4) ^ b5;
	assign t7 = b7 ^ mult_9(b0) ^ mult_2(b1) ^ mult_5(b2) ^ mult_8(b3) ^ b4 ^ mult_4(b5) ^ b6;

	assign out = {t0,t1,t2,t3,t4,t5,t6,t7};

	// Calculate S-Box
	function [7:0] s_box (
		input [7:0] in
	);

		reg [3:0] l, r, tmp, lr;

		begin

			l = E[in[7:4]];
			r = EI[in[3:0]];

			lr = l ^ r;
			
			tmp = R[lr];

			s_box[7:4] = E[l ^ tmp];
			s_box[3:0] = EI[r ^ tmp];

		end
	endfunction

	// Calculate GF(256) Multiplication (x2)
	function [7:0] mult_2;
		input [7:0] n;

		reg [2:0] z7;

		begin
			z7 = {n[7],n[7],n[7]};
			mult_2 = {n[6],n[5],n[4],n[3:1]^z7,n[0],n[7]};
		end
	endfunction

	// Calculate GF(256) Multiplication (x4)
	function [7:0] mult_4;
		input [7:0] n;
		begin
			mult_4 = mult_2(mult_2(n));
		end
	endfunction

	// Calculate GF(256) Multiplication (x5)
	function [7:0] mult_5;
		input [7:0] n;
		begin
			mult_5 = mult_4(n) ^ n;
		end
	endfunction

	// Calculate GF(256) Multiplication (x8)
	function [7:0] mult_8;
		input [7:0] n;
		begin
			mult_8 = mult_2(mult_4(n));
		end
	endfunction

	// Calculate GF(256) Multiplication (x9)
	function [7:0] mult_9;
		input [7:0] n;
		begin
			mult_9 = mult_8(n) ^ n;
		end
	endfunction
	
endmodule
