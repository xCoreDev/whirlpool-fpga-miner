`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: CryptoFlyr
// 
// Create Date:    09:36:22 04/13/2015 
// Design Name: 
// Module Name:    whirlpool
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

module whirlpool (
	input clk,
	input rst,
	input [511:0] block,
	input [511:0] state,
	output hash_ready, 
	output [511:0] hash
);

	wire [511:0] b0,b1,b2,b3,b4,b5,b6,b7,b8,b9;
	wire [511:0] k0,k1,k2,k3,k4,k5,k6,k7,k8,k9;
	
	process_round r0 ({352'd0, block}, state, 64'h1823C6E887B8014F, b0, k0);
	process_round r1 (b0, k0, 64'h36A6D2F5796F9152, b1, k1);
	process_round r2 (b1, k1, 64'h60BC9B8EA30C7B35, b2, k2);
	process_round r3 (b2, k2, 64'h1DE0D7C22E4BFE57, b3, k3);
	process_round r4 (b3, k3, 64'h157737E59FF04ADA, b4, k4);
	process_round r5 (b4, k4, 64'h58C9290AB1A06B85, b5, k5);
	process_round r6 (b5, k5, 64'hBD5D10F4CB3E0567, b6, k6);
	process_round r7 (b6, k6, 64'hE427418BA77D95D8, b7, k7);
	process_round r8 (b7, k7, 64'hFBEE7C66DD17479E, b8, k8);
	process_round r9 (b8, k8, 64'hCA2DBF07AD5A8333, b9, k9);

	assign hash = state[511:480] ^ b9[511:480];
	
	assign hash_ready = 1'b1;

endmodule
