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

module serial_handler(
	input clk,
	output reg [7:0] tx_data,
	output reg new_tx_data,
	input tx_busy,
	input [7:0] rx_data,
	input new_rx_data,
	output new_work,
	output [511:0] midstate,
	output [95:0] block_header,
	output [31:0] nonce_start,
	output [31:0] nonce_end,
	output [31:0] target,
	input new_result,
	input [31:0] result_data
);

	// IO States
	localparam
		STATE_INIT 					= 8'h00,
		STATE_READ_MESSAGE		= 8'h01,
		STATE_READ_WORK			= 8'h02,
		STATE_WRITE_BEGIN			= 8'h03,
		STATE_WRITE_CONTINUE 	= 8'h04,
		STATE_SEND_ACK 			= 8'h05,
		STATE_SEND_INFO 			= 8'h06,
		STATE_SEND_RESULT			= 8'h07,
		STATE_SEND_ERROR 			= 8'h08
	;

	// IO Message Types (Must Matche Values In MinerPP)
	localparam
		MESSAGE_TYPE_NONE 		= 8'd0,
		MESSAGE_TYPE_ACK 			= 8'd2,
		MESSAGE_TYPE_PING 		= 8'd9,
		MESSAGE_TYPE_INFO 		= 8'd21,
		MESSAGE_TYPE_NEW_WORK 	= 8'd23,
		MESSAGE_TYPE_TEST_WORK 	= 8'd25,
		MESSAGE_TYPE_RESTART 	= 8'd27,
		MESSAGE_TYPE_RESULT 		= 8'd48,
		MESSAGE_TYPE_ERROR 		= 8'hFE
	;

	// Serial Tx Registers
	reg [7:0] tx_data_out [0:5];
	reg [2:0] tx_cnt;

	// Serial Rx Registers
	reg [7:0] msg_type;				// Based On Message Type Enum
	reg [7:0] msg_len;				// Includes Message, Length, And Value Bytes
	reg new_message;					// Indicates When A New Message Is Being Read

	// New Work Registers
	reg [703:0] work_data;			// Temp Storage For The Work Data Read From MinerPP
	reg [9:0] work_byte_cnt;		// Current Byte Of Work Data Being Read
	reg work_ready;					// Indicator For When Work Data Has Been Fully Received

	reg [31:0] res_buf;				// Buffer To Hold The Nonce To Be Returned To MinerPP
	reg res_send;						// Indicator Used To Send Result When Rx/Tx Not Busy
	
	reg[7:0] state_d;					// Current Step Of The Serial Process
	
	assign new_work = work_ready;
	assign {midstate, block_header, nonce_start, target, nonce_end} = work_data;
	 
	initial begin
		state_d = STATE_INIT;			// This is a workaground for the logipi fpga
//		state_d = STATE_READ_MESSAGE;	// This is the intial value for the Mojo
	end
  
	always @(posedge clk) begin
  
		work_ready = 1'b0;
		new_tx_data = 1'b0;

		// If the work_manager has a new result make a copy of it
		// to be sent later when serial is not busy.
		if (new_result) begin

			// Copy the result_data into the result_data_copy for sending later.
			res_buf = result_data;
			res_send = 1'b1;

		end

		// Check If The Rx / Tx Lines Are Free To Send The Result
		if (res_send && (state_d == STATE_READ_MESSAGE) && !tx_busy && !new_rx_data) begin
		
			// Send The Result
			state_d = STATE_SEND_RESULT;
			res_send = 1'b0;

		end

		// Process Messages
		case (state_d)
		
			STATE_INIT: begin					// This is a workaground for the logipi fpga
				if (new_rx_data)				// Other boards don't need this
					state_d = STATE_READ_MESSAGE;
			end

			STATE_READ_MESSAGE: begin

				if (new_rx_data) begin

					if (new_message) begin
						msg_type = rx_data;	// Read Message Type
						new_message = 1'b0;
					end
					
					else begin
						msg_len = rx_data;	// Read Message Length
						new_message = 1'b1;

						// Determine Next State Based On Message Type
						case(msg_type)
							MESSAGE_TYPE_PING 		: begin state_d = STATE_SEND_ACK; end
							MESSAGE_TYPE_INFO 		: begin state_d = STATE_SEND_INFO; end
							MESSAGE_TYPE_NEW_WORK	: begin state_d = STATE_READ_WORK; work_byte_cnt = msg_len; end
							MESSAGE_TYPE_TEST_WORK	: begin state_d = STATE_READ_WORK; work_byte_cnt = msg_len; end
							MESSAGE_TYPE_RESTART 	: begin state_d = STATE_SEND_ACK; work_ready = 1'b1; end
							default 						: begin state_d = STATE_SEND_ERROR; end
						endcase
					end
				end
			end

			STATE_READ_WORK: begin

				if (new_rx_data) begin

					work_byte_cnt = work_byte_cnt - 1'b1;

					work_data[work_byte_cnt << 3 +: 8] = rx_data;
					
					if(work_byte_cnt == 10'd0) begin
					
						if(msg_len == 10'd88) begin	// We Have To Read The Bytes Regardless Of Len To Clear The Buffer

							work_ready = 1'b1;			// Set Indicator That New Work Has Been Received

							state_d = STATE_SEND_ACK;

						end
						else
							state_d = STATE_SEND_ERROR;
					end
				end
			end

			STATE_SEND_ACK: begin
				tx_data_out[1] = MESSAGE_TYPE_ACK;
				tx_data_out[0] = 8'h00;
				tx_cnt = 3'd2;
				state_d = STATE_WRITE_BEGIN;
			end
			
			STATE_SEND_INFO: begin
				tx_data_out[5] = MESSAGE_TYPE_INFO;
				tx_data_out[4] = 8'h04;
				tx_data_out[3] = "M";
				tx_data_out[2] = "o";
				tx_data_out[1] = "V";
				tx_data_out[0] = "3";
				tx_cnt = 3'd6;
				state_d = STATE_WRITE_BEGIN;
			end
			
			STATE_SEND_RESULT: begin
				tx_data_out[5] = MESSAGE_TYPE_RESULT;
				tx_data_out[4] = 8'h04;
				tx_data_out[3] = res_buf[31:24];
				tx_data_out[2] = res_buf[23:16];
				tx_data_out[1] = res_buf[15:8];
				tx_data_out[0] = res_buf[7:0];
				tx_cnt = 3'd6;
				state_d = STATE_WRITE_BEGIN;
			end
			
			STATE_SEND_ERROR: begin
				tx_data_out[1] = MESSAGE_TYPE_ERROR;
				tx_data_out[0] = 8'h00;
				tx_cnt = 3'd2;
				state_d = STATE_WRITE_BEGIN;
			end
			
			STATE_WRITE_BEGIN: begin
				if (!tx_busy) begin
					tx_cnt = tx_cnt - 1'b1;
					tx_data = tx_data_out[tx_cnt];
					new_tx_data = 1'b1;
					state_d = STATE_WRITE_CONTINUE;
				end
			end
			
			STATE_WRITE_CONTINUE: begin
				new_tx_data = 1'b0;
			
				if (tx_cnt == 3'b000)
						state_d = STATE_READ_MESSAGE;
				else
						state_d = STATE_WRITE_BEGIN;
			end
		
			default: state_d = STATE_READ_MESSAGE;
			
		endcase
		
	end
	
endmodule
