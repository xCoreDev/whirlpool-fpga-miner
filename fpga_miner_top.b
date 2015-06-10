`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:41:02 04/21/2015 
// Design Name: 
// Module Name:    fpga_miner 
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
module fpga_miner(
	input  clk,				// 50 MHz Clock (Pin 85)
	input  pi_tx,			// Pi Serial Tx (Pin 83)
	output pi_rx,			// Pi Serial Rx (Pin 82)
	output [1:0] led		// LEDs (Pins 104 & 105)
);

	// Wires Used For Miner Work / Results
	wire new_work;						// Indicates When New Work Has Been Received
	wire [511:0] midstate;			// Stores The Midstate For The Current Work Item
	wire [95:0] block_header;		// Stores The Remaining Block Header Data For The Current Work Item
	wire [31:0] nonce_start;		// Nonce To Use When Hashing First Begins
	wire [31:0] nonce_end;			// Continue Hashing Until This Nonce Is Reached
	wire [31:0] target;				// A Valid Nonce Is Found When The Resulting Hash Is Less Than The Target
	wire new_result;					// Indicates When A Valid Nonce Has Been Found Or Hashing Is Complete
	wire [31:0] result_data;		// Stores The Nonce That Was Found
	wire hashing;						// Indicates The FPGA Is Hashing
	
	// Define Serial Interface Settings
	parameter CLK_RATE = 50000000;												// clk = 50 MHz
	parameter SERIAL_BAUD_RATE = 115200;										// baud = 115200 bps
	parameter CLK_PER_BIT = $rtoi($ceil(CLK_RATE/SERIAL_BAUD_RATE));	// CLK_PER_BIT is the number of cycles each 'bit' lasts for. rtoi converts a 'real' number to an 'integer'

	// Wires Used For Serial Interface
	wire [7:0] rx_data, tx_data;
	wire new_rx_data, new_tx_data, tx_busy;

	// Instantiate The Object For Serial Data Receive (Rx)
	serial_rx #(.CLK_PER_BIT(CLK_PER_BIT)) serial_rx (
		.clk(clk),
//		.rst(1'b0),
		.rx(pi_tx),		// FPGA rx goes to Pi tx
		.data(rx_data),
		.new_data(new_rx_data)
	);

	// Instantiate The Object For Serial Data Transmit (Tx)
	serial_tx #(.CLK_PER_BIT(CLK_PER_BIT)) serial_tx (
		.clk(clk),
//		.rst(1'b0),
		.tx(pi_rx),		// FPGA tx goes to Pi rx
		.busy(tx_busy),
		.data(tx_data),
		.new_data(new_tx_data)
	);

	// Instantiate The Object For Data Mapping Of Serial Data To Miner
	serial_handler serial_handler(
		.clk(clk),
		.tx_data(tx_data),
		.new_tx_data(new_tx_data),
		.tx_busy(tx_busy),
		.rx_data(rx_data),
		.new_rx_data(new_rx_data),
		.new_work(new_work),
		.midstate(midstate),
		.block_header(block_header),
		.nonce_start(nonce_start),
		.nonce_end(nonce_end),
		.target(target),
		.new_result(new_result),
		.result_data(result_data)
	);

	// Instantiate The Object To Light The LEDs
	led_handler led_handler(
		.clk(clk),
		.led(led),
		.new_work(new_work),
		.new_result(new_result),
		.hashing(hashing)
	);

	// Instantiate The Object To Process The Work (i.e. Hash)
	work_handler work_handler(
		.clk(clk),
		.new_work(new_work),
		.midstate(midstate),
		.header(block_header),
		.nonce_start(nonce_start),
		.nonce_end(nonce_end),
		.target(target),
		.hashing(hashing),
		.new_result(new_result),
		.result_data(result_data)
	);

endmodule
