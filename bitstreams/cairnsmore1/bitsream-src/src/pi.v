`timescale 1ns / 1ps
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
 
module pi (
	input [511:0] in,
	output [511:0] out
);

	assign out = {
		in[504 +: 8],in[ 48 +: 8],in[104 +: 8],in[160 +: 8],in[216 +: 8],in[272 +: 8],in[328 +: 8],in[384 +: 8],
		in[440 +: 8],in[496 +: 8],in[ 40 +: 8],in[ 96 +: 8],in[152 +: 8],in[208 +: 8],in[264 +: 8],in[320 +: 8],
		in[376 +: 8],in[432 +: 8],in[488 +: 8],in[ 32 +: 8],in[ 88 +: 8],in[144 +: 8],in[200 +: 8],in[256 +: 8],
		in[312 +: 8],in[368 +: 8],in[424 +: 8],in[480 +: 8],in[ 24 +: 8],in[ 80 +: 8],in[136 +: 8],in[192 +: 8],
		in[248 +: 8],in[304 +: 8],in[360 +: 8],in[416 +: 8],in[472 +: 8],in[ 16 +: 8],in[ 72 +: 8],in[128 +: 8],
		in[184 +: 8],in[240 +: 8],in[296 +: 8],in[352 +: 8],in[408 +: 8],in[464 +: 8],in[  8 +: 8],in[ 64 +: 8],
		in[120 +: 8],in[176 +: 8],in[232 +: 8],in[288 +: 8],in[344 +: 8],in[400 +: 8],in[456 +: 8],in[  0 +: 8],
		in[ 56 +: 8],in[112 +: 8],in[168 +: 8],in[224 +: 8],in[280 +: 8],in[336 +: 8],in[392 +: 8],in[448 +: 8]
	};

endmodule
