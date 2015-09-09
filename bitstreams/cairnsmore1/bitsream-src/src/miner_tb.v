`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:			CryptoFlyr
// 
// Create Date:		06/10/2015 
// Design Name:		Whirlpool Miner
// Module Name:		miner_tb
// Project Name:		Whirlpool Miner
// Target Devices:	Spartan 6 - LX9 / LX45
// Tool versions:		ISE 14.7
// Description:
//
// Dependencies:		N/A
//
// Revision: 
// Revision 0.01		File Created
//
//////////////////////////////////////////////////////////////////////////////////

module miner_tb(
    );

	reg clk, rst;
	reg [63:0] cnt = 0;

	// Intialize The Clock For The Simulation
	initial begin
		clk = 1'b0;
		repeat(4) #10 clk = ~clk;	// Initialize The Clock
		rst = 1'b0;
		forever #10 clk = ~clk;		// Start The Clock
	end
	
	wire new_result;
	wire [31:0] result;

	reg reset = 1'b0;

	reg [511:0] midstate;
	reg [95:0] data;
	wire [31:0] golden_nonce;
	wire [31:0] nonce;
	wire [31:0] hash;
	wire golden_nonce_match, miner_busy;

	// Instantiate The work_handler Object
	hashcore hashcore (
		.hash_clk(clk),
		.reset(reset),
		.midstate(midstate),
		.data(data),
		.nonce_msb(1'b0),
		.golden_nonce(golden_nonce),
		.golden_nonce_match(golden_nonce_match),
		.miner_busy(miner_busy),
		.nonce_out(nonce),
		.hash_out(hash)
	);

 	always @ (posedge clk)
	begin
		reset = 1'b0;

		// Test Block (xor = 00000010)
		midstate = 512'hbc40712ea6acefe74dad34f3b2e02f2adc50dc653f43ab1da4c98e90f4249b3d56ecc9a60bc2b69015d59bf03317eb47f3de8b3dc1ff79733e609c9a5049309a; 
		data = 96'h7ee4ad7bb92e9e54db20011e;

		// Send New Work To Work_Handler
		if( cnt == 2 ) begin
			reset = 1'b1;
		end

		cnt = cnt + 1;

		$display("Clk: %d, Reset: %d, golden_nonce: %x, golden_nonce_match: %d, miner_busy: %d, nonce2: %x, hash2: %x", cnt, reset, golden_nonce, golden_nonce_match, miner_busy, nonce, hash);

	end

endmodule
