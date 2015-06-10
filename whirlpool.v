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

	wire [63:0] ROUND_CONSTANT [0:9] = {
		64'h1823C6E887B8014F, 64'h36A6D2F5796F9152, 64'h60BC9B8EA30C7B35, 64'h1DE0D7C22E4BFE57, 64'h157737E59FF04ADA, 
		64'h58C9290AB1A06B85, 64'hBD5D10F4CB3E0567, 64'hE427418BA77D95D8,	64'hFBEE7C66DD17479E, 64'hCA2DBF07AD5A8333	
	};
	
	reg [511:0] block_q, state_q;		// Temp Storage For State & Block Rounds Between Clock Cycles
	reg [511:0] round_in;				// Block Input For The Current Round
	reg [511:0] round_key;				// Key Input For The Current Round
	wire [511:0] round_out;				// Output For The Current Round

	reg [3:0] round_cnt = 4'd0;		// Current Round (0 to 9)
	reg process_state = 1'b1;			// Indicator To Indentify If State Or Block Round Is Being Processed
	reg hash_done = 1'b0;				// Indicator For When All 10 Rounds Are Complete
	
	// Process Rounds
	process_round round (round_in, round_key, round_out);

	assign hash = state ^ block ^ round_out;
	assign hash_ready = hash_done;

	always @ (posedge clk) begin
	
		hash_done = 1'b0;

		if (rst)	begin										// Reset The Data For The Next 10 Rounds
			round_cnt = 4'd0;
			process_state = 1'b1;
		end
	
		if (process_state) begin						// State Round

			round_key = {ROUND_CONSTANT[round_cnt], 448'd0};
			block_q = round_out;

			if (round_cnt == 4'd0)						// Reset The State Round To Use The Midstate
				round_in = state;
			else
				round_in = state_q;
		end
		else begin											// Block Round
		
			round_key = round_out;
			state_q = round_out;

			if (round_cnt == 4'd0)						// Reset The Block Round To Use The Work Block XOR'd With Midstate Data
				round_in = block ^ state;
			else
				round_in = block_q;

			// Increment Round Once Both State & Block Rounds Complete
			round_cnt = round_cnt + 1'b1;

			if (round_cnt == 4'd10) begin				// Notify Work Handler That Hash Is Complete
				round_cnt = 4'd0;
				hash_done = 1'b1;
			end

		end
		
		process_state = ~process_state;

//		$display("Round: %d, Rst: %d, P_State: %d, Ready: %d, Round Out: %x", round_cnt, rst, process_state, hash_ready, round_out);
	
	end
	
endmodule
