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

	wire [7:0] s0,s1,s2,s3,s4,s5,s6,s7;
	wire [7:0] t0,t1,t2,t3,t4,t5,t6,t7;
	
	// Non-Linear Layer - Gama (S-Box)
	assign s0 = s_box(in[56 +: 8]);
	assign s1 = s_box(in[48 +: 8]);
	assign s2 = s_box(in[40 +: 8]);
	assign s3 = s_box(in[32 +: 8]);
	assign s4 = s_box(in[24 +: 8]);
	assign s5 = s_box(in[16 +: 8]);
	assign s6 = s_box(in[ 8 +: 8]);
	assign s7 = s_box(in[ 0 +: 8]);

	// Diffusion Layer - Theta
	assign t0 = theta ( s0,s1,s2,s3,s4,s5,s6,s7 );
	assign t1 = theta ( s1,s2,s3,s4,s5,s6,s7,s0 );
	assign t2 = theta ( s2,s3,s4,s5,s6,s7,s0,s1 );
	assign t3 = theta ( s3,s4,s5,s6,s7,s0,s1,s2 );
	assign t4 = theta ( s4,s5,s6,s7,s0,s1,s2,s3 );
	assign t5 = theta ( s5,s6,s7,s0,s1,s2,s3,s4 );
	assign t6 = theta ( s6,s7,s0,s1,s2,s3,s4,s5 );
	assign t7 = theta ( s7,s0,s1,s2,s3,s4,s5,s6 );
	
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


	// Calculate Theta
	function [7:0] theta;
		input [7:0] b0;
		input [7:0] b1;
		input [7:0] b2;
		input [7:0] b3;
		input [7:0] b4;
		input [7:0] b5;
		input [7:0] b6;
		input [7:0] b7;

		reg z0,z1,z2,z3,z4,z5,z6,z7;

		begin

			// These Steps Include The Theta Matrix Multiplication Using GF(256)
			z0 = b0[7]^b1[7]^b1[4]^b2[6]^b3[7]^b3[5]^b4[4]^b5[7]^b6[5]^b7[7];
			z1 = b0[6]^b1[6]^b1[3]^b1[7]^b2[5]^b3[6]^b3[4]^b4[3]^b4[7]^b5[6]^b6[4]^b7[6];
			z2 = b0[5]^b1[5]^b1[2]^b1[7]^b1[6]^b2[4]^b3[5]^b3[3]^b3[7]^b4[2]^b4[7]^b4[6]^b5[5]^b6[3]^b6[7]^b7[5];
			z3 = b0[4]^b1[4]^b1[1]^b1[7]^b1[6]^b1[5]^b2[3]^b2[7]^b3[4]^b3[2]^b3[7]^b3[6]^b4[1]^b4[7]^b4[6]^b4[5]^b5[4]^b6[2]^b6[7]^b6[6]^b7[4];
			z4 = b0[3]^b1[3]^b1[0]^b1[6]^b1[5]^b2[2]^b2[7]^b3[3]^b3[1]^b3[7]^b3[6]^b4[0]^b4[6]^b4[5]^b5[3]^b6[1]^b6[7]^b6[6]^b7[3];
			z5 = b0[2]^b1[2]^b1[7]^b1[5]^b2[1]^b2[7]^b3[2]^b3[0]^b3[6]^b4[7]^b4[5]^b5[2]^b6[0]^b6[6]^b7[2];
			z6 = b0[1]^b1[1]^b1[6]^b2[0]^b3[1]^b3[7]^b4[6]^b5[1]^b6[7]^b7[1];
			z7 = b0[0]^b1[0]^b1[5]^b2[7]^b3[0]^b3[6]^b4[5]^b5[0]^b6[6]^b7[0];

			theta = {z0,z1,z2,z3,z4,z5,z6,z7};

		end
	endfunction

endmodule
