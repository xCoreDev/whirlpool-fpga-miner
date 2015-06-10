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

module led_handler(
	input  clk,
	output [1:0] led,
	input  new_work,
	input  new_result,
	input  hashing
);

	reg [23:0] led_loop_cnt;
	reg led_result, led_new_work;

	/**
	 * Assign the LED's to has_new_work and is_working.
	 */
	assign led[0] = led_new_work;
	assign led[1] = led_result;
	
	initial begin
		led_loop_cnt = 16'h0000;
		led_result = 1'b0;
		led_new_work = 1'b0;
	end

	always @(posedge clk) begin
		if (!hashing) begin
			led_loop_cnt <= 16'h0000;
			led_new_work <= 1'b0;
			led_result <= 1'b0;
		end
		 
		if (new_result) begin						// Turn On Both LEDs
			led_new_work <= 1'b1;
			led_result <= 1'b1;
			led_loop_cnt <= 16'h0000;
		end
		else
		begin
			if (led_loop_cnt == 16'hFFFF)	begin		// Turn Off New Work LED After 16K Clock Cycles
				led_loop_cnt <= 16'h0000;
				led_new_work <= 1'b0;
				led_result <= 1'b1;
			end
			else begin
				if (new_work) begin					// Turn On New Work LED
						led_loop_cnt <= 16'h0000;
						led_new_work <= 1'b1;
						led_result <= 1'b0;
				end
				else begin
					if (led_new_work) begin
						led_loop_cnt <= led_loop_cnt + 1'b1;
					end
				end
			end
		end
	end
endmodule
