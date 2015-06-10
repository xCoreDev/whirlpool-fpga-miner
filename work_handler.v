/*
 * Copyright (c) 2013-2015 John Connor (BM-NC49AxAjcqVcF5jNPu85Rb8MJ2d9JqZt)
 *
 * This is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License with
 * additional permissions to the one published by the Free Software
 * Foundation, either version 3 of the License, or (at your option)
 * any later version. For more information see LICENSE.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

`timescale 1ns / 1ps

module work_handler (
	input clk,
	input new_work,
	input [511:0] midstate,
	input [95:0] header,
	input [31:0] nonce_start,
	input [31:0] nonce_end,
	input [31:0] target,
	output hashing,
	output new_result,
	output [31:0] result_data
);

	wire [511:0] block;
	wire [511:0] hash;
	wire hash_ready;

	reg [31:0] hash_xor;
	reg [31:0] nonce, result;
	reg rst, hash_enabled, new_res;

	initial begin
		hash_enabled = 1'b0;
		result = 32'd0;
		new_res = 1'b0;
		rst = 1'b0;
	end

	assign block = {header, nonce, 8'h80, 360'd0, 16'h0280};;	// Add Nonce To Supplied Header

	whirlpool whirlpool ( clk, rst, block, midstate, hash_ready, hash );

	assign result_data = result;
	assign new_result = new_res;
	assign hashing = hash_enabled;

	always @(posedge clk) begin

		new_res = 1'b0;
		result = 32'h00000000;
		rst = new_work;
		
		// When New Work Arrives, Reset All Values
		if (new_work) begin
			nonce = nonce_start;
			hash_enabled = 1'b1;
			new_res = 1'b0;
		end 
		else if (hash_enabled) begin
		
			if (hash_ready) begin							// Because Multiple Cycles Are Used, Wait For Hash To Complete
			
				// XOR The Whirlpool Hash To Itself Offset By 128 Bits (Only 32 Bits Required For Target Check)
				hash_xor = {hash[263:256] ^ hash[135:128],
								hash[271:264] ^ hash[143:136],
								hash[279:272] ^ hash[151:144],
								hash[287:280] ^ hash[159:152]};

//				$display("\n\tHash:  %x\n\tHashx: %x\n", hash, hash_xor);

				if (hash_xor <= target) begin				// Check If A Nonce Was Found On Prior Hash
					new_res = 1'b1;
					result = nonce;
				end

				else if (nonce == nonce_end) begin		// Check If All Nonces Have Been Used
					hash_enabled = 1'b0;
					new_res = 1'b1;
					result = nonce;
				end

				nonce = nonce + 1'b1;

			end
		end

//		$display ("Nonce: %d, Ready: %d, State: %x, Block: %x, New Work: %d, Enabled: %d, Hashing: %d, New Result: %d, Result: %d", nonce, hash_ready, midstate[511:480], block[159:128], new_work, hash_enabled, hashing, new_res, result);

	end

endmodule
