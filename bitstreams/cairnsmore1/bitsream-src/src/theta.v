/*
 * Copyright (c) 2015 CryptoFlyr
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
 
module theta (
	input [63:0] in,
	output [63:0] out
);

	wire [7:0] p0,p1,p2,p3,p4,p5,p6,p7;
	wire [7:0] t0,t1,t2,t3,t4,t5,t6,t7;
	
	assign {p0,p1,p2,p3,p4,p5,p6,p7} = in;
	
	assign t0 = GF256 ( p0,p1,p2,p3,p4,p5,p6,p7 );
	assign t1 = GF256 ( p1,p2,p3,p4,p5,p6,p7,p0 );
	assign t2 = GF256 ( p2,p3,p4,p5,p6,p7,p0,p1 );
	assign t3 = GF256 ( p3,p4,p5,p6,p7,p0,p1,p2 );
	assign t4 = GF256 ( p4,p5,p6,p7,p0,p1,p2,p3 );
	assign t5 = GF256 ( p5,p6,p7,p0,p1,p2,p3,p4 );
	assign t6 = GF256 ( p6,p7,p0,p1,p2,p3,p4,p5 );
	assign t7 = GF256 ( p7,p0,p1,p2,p3,p4,p5,p6 );
	
	assign out = {t0,t1,t2,t3,t4,t5,t6,t7};

	// Calculate Theta
	function [7:0] GF256;
		input [7:0] b0;
		input [7:0] b1;
		input [7:0] b2;
		input [7:0] b3;
		input [7:0] b4;
		input [7:0] b5;
		input [7:0] b6;
		input [7:0] b7;

		begin

			// These Steps Include The Theta Matrix Multiplication Using GF(256)
			GF256 = {
				b0[7]^b1[7]^b1[4]^b2[6]^b3[7]^b3[5]^b4[4]^b5[7]^b6[5]^b7[7],
				b0[6]^b1[6]^b1[3]^b1[7]^b2[5]^b3[6]^b3[4]^b4[3]^b4[7]^b5[6]^b6[4]^b7[6],
				b0[5]^b1[5]^b1[2]^b1[7]^b1[6]^b2[4]^b3[5]^b3[3]^b3[7]^b4[2]^b4[7]^b4[6]^b5[5]^b6[3]^b6[7]^b7[5],
				b0[4]^b1[4]^b1[1]^b1[7]^b1[6]^b1[5]^b2[3]^b2[7]^b3[4]^b3[2]^b3[7]^b3[6]^b4[1]^b4[7]^b4[6]^b4[5]^b5[4]^b6[2]^b6[7]^b6[6]^b7[4],
				b0[3]^b1[3]^b1[0]^b1[6]^b1[5]^b2[2]^b2[7]^b3[3]^b3[1]^b3[7]^b3[6]^b4[0]^b4[6]^b4[5]^b5[3]^b6[1]^b6[7]^b6[6]^b7[3],
				b0[2]^b1[2]^b1[7]^b1[5]^b2[1]^b2[7]^b3[2]^b3[0]^b3[6]^b4[7]^b4[5]^b5[2]^b6[0]^b6[6]^b7[2],
				b0[1]^b1[1]^b1[6]^b2[0]^b3[1]^b3[7]^b4[6]^b5[1]^b6[7]^b7[1],
				b0[0]^b1[0]^b1[5]^b2[7]^b3[0]^b3[6]^b4[5]^b5[0]^b6[6]^b7[0]
			};

		end
	endfunction

endmodule
