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
 
module whirlpool (
	input clk,
	input new_work,
	input [511:0] state,
	input [95:0] header,
	output [31:0] nonce_out,
	output nonce_found,
	output [31:0] hash_xor
);

	reg [511:0] block_d [0:101];
	reg [511:0] block_q [0:101];
	reg [511:0] key_d [0:9];
	reg [511:0] key_q [0:9];
	
	reg [31:0] nonce_d, nonce_q, nonce_out_d, nonce_out_q;
	reg nonce_found_d, nonce_found_q;
	
	assign nonce_out = nonce_out_q;
	assign nonce_found = nonce_found_q;

	reg hash_ready_d, hash_ready_q;
	reg [31:0] hash_xor_d, hash_xor_q;
	
	assign hash_xor = hash_xor_q;

	reg hashing_d, hashing_q;

	// Wires For Cyclical Permutations (Pi) Output
	wire [511:0] pi0,pi1,pi2,pi3,pi4,pi5,pi6,pi7,pi8,pi9;
	
	// Wires For Non-Linear Layer (S-BOX) Output
	wire [63:0] s01,s02,s03,s04,s05,s06,s07,s08;
	wire [63:0] s11,s12,s13,s14,s15,s16,s17,s18;
	wire [63:0] s21,s22,s23,s24,s25,s26,s27,s28;
	wire [63:0] s31,s32,s33,s34,s35,s36,s37,s38;
	wire [63:0] s41,s42,s43,s44,s45,s46,s47,s48;
	wire [63:0] s51,s52,s53,s54,s55,s56,s57,s58;
	wire [63:0] s61,s62,s63,s64,s65,s66,s67,s68;
	wire [63:0] s71,s72,s73,s74,s75,s76,s77,s78;
	wire [63:0] s81,s82,s83,s84,s85,s86,s87,s88;
	wire [63:0] s91,s92,s93,s94,s95,s96,s97,s98;

	// Wires For Diffusion Layer (Theta) Output
	wire [63:0] t01,t02,t03,t04,t05,t06,t07,t08;
	wire [63:0] t11,t12,t13,t14,t15,t16,t17,t18;
	wire [63:0] t21,t22,t23,t24,t25,t26,t27,t28;
	wire [63:0] t31,t32,t33,t34,t35,t36,t37,t38;
	wire [63:0] t41,t42,t43,t44,t45,t46,t47,t48;
	wire [63:0] t51,t52,t53,t54,t55,t56,t57,t58;
	wire [63:0] t61,t62,t63,t64,t65,t66,t67,t68;
	wire [63:0] t71,t72,t73,t74,t75,t76,t77,t78;
	wire [63:0] t81,t82,t83,t84,t85,t86,t87,t88;
	wire [63:0] t91,t92,t93,t94,t95,t96,t97,t98;
	
	reg block_key_ready_d;
	reg [6:0] cnt_100_d, cnt_100_q;

	// Pipelines To Calculate 1 Hash Every 91 Clks

	// Round 1
	pi pi_0 ( block_q[0], pi0 );
	
	sbox sbox_01 ( block_q[1][511:448], s01 );
	sbox sbox_02 ( block_q[2][447:384], s02 );
	sbox sbox_03 ( block_q[3][383:320], s03 );
	sbox sbox_04 ( block_q[4][319:256], s04 );
	sbox sbox_05 ( block_q[5][255:192], s05 );
	sbox sbox_06 ( block_q[6][191:128], s06 );
	sbox sbox_07 ( block_q[7][127: 64], s07 );
	sbox sbox_08 ( block_q[8][ 63:  0], s08 );

	theta theta_01 ( s01, t01 );
	theta theta_02 ( s02, t02 );
	theta theta_03 ( s03, t03 );
	theta theta_04 ( s04, t04 );
	theta theta_05 ( s05, t05 );
	theta theta_06 ( s06, t06 );
	theta theta_07 ( s07, t07 );
	theta theta_08 ( s08, t08 );

	// Round 2
	pi pi_1 ( block_q[10], pi1 );
	
	sbox sbox_11 ( block_q[11][511:448], s11 );
	sbox sbox_12 ( block_q[12][447:384], s12 );
	sbox sbox_13 ( block_q[13][383:320], s13 );
	sbox sbox_14 ( block_q[14][319:256], s14 );
	sbox sbox_15 ( block_q[15][255:192], s15 );
	sbox sbox_16 ( block_q[16][191:128], s16 );
	sbox sbox_17 ( block_q[17][127: 64], s17 );
	sbox sbox_18 ( block_q[18][ 63:  0], s18 );

	theta theta_11 ( s11, t11 );
	theta theta_12 ( s12, t12 );
	theta theta_13 ( s13, t13 );
	theta theta_14 ( s14, t14 );
	theta theta_15 ( s15, t15 );
	theta theta_16 ( s16, t16 );
	theta theta_17 ( s17, t17 );
	theta theta_18 ( s18, t18 );

	// Round 3
	pi pi_2 ( block_q[20], pi2 );
	
	sbox sbox_21 ( block_q[21][511:448], s21 );
	sbox sbox_22 ( block_q[22][447:384], s22 );
	sbox sbox_23 ( block_q[23][383:320], s23 );
	sbox sbox_24 ( block_q[24][319:256], s24 );
	sbox sbox_25 ( block_q[25][255:192], s25 );
	sbox sbox_26 ( block_q[26][191:128], s26 );
	sbox sbox_27 ( block_q[27][127: 64], s27 );
	sbox sbox_28 ( block_q[28][ 63:  0], s28 );

	theta theta_21 ( s21, t21 );
	theta theta_22 ( s22, t22 );
	theta theta_23 ( s23, t23 );
	theta theta_24 ( s24, t24 );
	theta theta_25 ( s25, t25 );
	theta theta_26 ( s26, t26 );
	theta theta_27 ( s27, t27 );
	theta theta_28 ( s28, t28 );

	// Round 4
	pi pi_3 ( block_q[30], pi3 );
	
	sbox sbox_31 ( block_q[31][511:448], s31 );
	sbox sbox_32 ( block_q[32][447:384], s32 );
	sbox sbox_33 ( block_q[33][383:320], s33 );
	sbox sbox_34 ( block_q[34][319:256], s34 );
	sbox sbox_35 ( block_q[35][255:192], s35 );
	sbox sbox_36 ( block_q[36][191:128], s36 );
	sbox sbox_37 ( block_q[37][127: 64], s37 );
	sbox sbox_38 ( block_q[38][ 63:  0], s38 );

	theta theta_31 ( s31, t31 );
	theta theta_32 ( s32, t32 );
	theta theta_33 ( s33, t33 );
	theta theta_34 ( s34, t34 );
	theta theta_35 ( s35, t35 );
	theta theta_36 ( s36, t36 );
	theta theta_37 ( s37, t37 );
	theta theta_38 ( s38, t38 );

	// Round 5
	pi pi_4 ( block_q[40], pi4 );
	
	sbox sbox_41 ( block_q[41][511:448], s41 );
	sbox sbox_42 ( block_q[42][447:384], s42 );
	sbox sbox_43 ( block_q[43][383:320], s43 );
	sbox sbox_44 ( block_q[44][319:256], s44 );
	sbox sbox_45 ( block_q[45][255:192], s45 );
	sbox sbox_46 ( block_q[46][191:128], s46 );
	sbox sbox_47 ( block_q[47][127: 64], s47 );
	sbox sbox_48 ( block_q[48][ 63:  0], s48 );

	theta theta_41 ( s41, t41 );
	theta theta_42 ( s42, t42 );
	theta theta_43 ( s43, t43 );
	theta theta_44 ( s44, t44 );
	theta theta_45 ( s45, t45 );
	theta theta_46 ( s46, t46 );
	theta theta_47 ( s47, t47 );
	theta theta_48 ( s48, t48 );

	// Round 6
	pi pi_5 ( block_q[50], pi5 );
	
	sbox sbox_51 ( block_q[51][511:448], s51 );
	sbox sbox_52 ( block_q[52][447:384], s52 );
	sbox sbox_53 ( block_q[53][383:320], s53 );
	sbox sbox_54 ( block_q[54][319:256], s54 );
	sbox sbox_55 ( block_q[55][255:192], s55 );
	sbox sbox_56 ( block_q[56][191:128], s56 );
	sbox sbox_57 ( block_q[57][127: 64], s57 );
	sbox sbox_58 ( block_q[58][ 63:  0], s58 );

	theta theta_51 ( s51, t51 );
	theta theta_52 ( s52, t52 );
	theta theta_53 ( s53, t53 );
	theta theta_54 ( s54, t54 );
	theta theta_55 ( s55, t55 );
	theta theta_56 ( s56, t56 );
	theta theta_57 ( s57, t57 );
	theta theta_58 ( s58, t58 );

	// Round 7
	pi pi_6 ( block_q[60], pi6 );
	
	sbox sbox_61 ( block_q[61][511:448], s61 );
	sbox sbox_62 ( block_q[62][447:384], s62 );
	sbox sbox_63 ( block_q[63][383:320], s63 );
	sbox sbox_64 ( block_q[64][319:256], s64 );
	sbox sbox_65 ( block_q[65][255:192], s65 );
	sbox sbox_66 ( block_q[66][191:128], s66 );
	sbox sbox_67 ( block_q[67][127: 64], s67 );
	sbox sbox_68 ( block_q[68][ 63:  0], s68 );

	theta theta_61 ( s61, t61 );
	theta theta_62 ( s62, t62 );
	theta theta_63 ( s63, t63 );
	theta theta_64 ( s64, t64 );
	theta theta_65 ( s65, t65 );
	theta theta_66 ( s66, t66 );
	theta theta_67 ( s67, t67 );
	theta theta_68 ( s68, t68 );

	// Round 8
	pi pi_7 ( block_q[70], pi7 );
	
	sbox sbox_71 ( block_q[71][511:448], s71 );
	sbox sbox_72 ( block_q[72][447:384], s72 );
	sbox sbox_73 ( block_q[73][383:320], s73 );
	sbox sbox_74 ( block_q[74][319:256], s74 );
	sbox sbox_75 ( block_q[75][255:192], s75 );
	sbox sbox_76 ( block_q[76][191:128], s76 );
	sbox sbox_77 ( block_q[77][127: 64], s77 );
	sbox sbox_78 ( block_q[78][ 63:  0], s78 );

	theta theta_71 ( s71, t71 );
	theta theta_72 ( s72, t72 );
	theta theta_73 ( s73, t73 );
	theta theta_74 ( s74, t74 );
	theta theta_75 ( s75, t75 );
	theta theta_76 ( s76, t76 );
	theta theta_77 ( s77, t77 );
	theta theta_78 ( s78, t78 );

	// Round 9
	pi pi_8 ( block_q[80], pi8 );
	
	sbox sbox_81 ( block_q[81][511:448], s81 );
	sbox sbox_82 ( block_q[82][447:384], s82 );
	sbox sbox_83 ( block_q[83][383:320], s83 );
	sbox sbox_84 ( block_q[84][319:256], s84 );
	sbox sbox_85 ( block_q[85][255:192], s85 );
	sbox sbox_86 ( block_q[86][191:128], s86 );
	sbox sbox_87 ( block_q[87][127: 64], s87 );
	sbox sbox_88 ( block_q[88][ 63:  0], s88 );

	theta theta_81 ( s81, t81 );
	theta theta_82 ( s82, t82 );
	theta theta_83 ( s83, t83 );
	theta theta_84 ( s84, t84 );
	theta theta_85 ( s85, t85 );
	theta theta_86 ( s86, t86 );
	theta theta_87 ( s87, t87 );
	theta theta_88 ( s88, t88 );

	// Round 10
	pi pi_9 ( block_q[90], pi9 );
	
	sbox sbox_91 ( block_q[91][511:448], s91 );
	sbox sbox_92 ( block_q[92][447:384], s92 );
	sbox sbox_93 ( block_q[93][383:320], s93 );
	sbox sbox_94 ( block_q[94][319:256], s94 );
	sbox sbox_95 ( block_q[95][255:192], s95 );
	sbox sbox_96 ( block_q[96][191:128], s96 );
	sbox sbox_97 ( block_q[97][127: 64], s97 );
	sbox sbox_98 ( block_q[98][ 63:  0], s98 );

	theta theta_91 ( s91, t91 );
	theta theta_92 ( s92, t92 );
	theta theta_93 ( s93, t93 );
	theta theta_94 ( s94, t94 );
	theta theta_95 ( s95, t95 );
	theta theta_96 ( s96, t96 );
	theta theta_97 ( s97, t97 );
	theta theta_98 ( s98, t98 );


	always @(*) begin
	
		block_key_ready_d = 1'b0;
		cnt_100_d = cnt_100_q;
		
		nonce_d = nonce_q;
		nonce_out_d = 32'h00000000;
		nonce_found_d = 1'b0;
		
		hash_ready_d = hash_ready_q;
		hash_xor_d = 32'hFFFFFFFF;

		hashing_d = hashing_q;

		key_d[0] = key_q[0];
		key_d[1] = key_q[1];
		key_d[2] = key_q[2];
		key_d[3] = key_q[3];
		key_d[4] = key_q[4];
		key_d[5] = key_q[5];
		key_d[6] = key_q[6];
		key_d[7] = key_q[7];
		key_d[8] = key_q[8];
		key_d[9] = key_q[9];
		

		//
		// Round Pipelines
		//

		// Round 10
		block_d[100] = block_q[99] ^ key_d[9];
		block_d[99] = { block_q[98][511: 64], t98 };
		block_d[98] = { block_q[97][511:128], t97, block_q[97][ 63:0] };
		block_d[97] = { block_q[96][511:192], t96, block_q[96][127:0] };
		block_d[96] = { block_q[95][511:256], t95, block_q[95][191:0] };
		block_d[95] = { block_q[94][511:320], t94, block_q[94][255:0] };
		block_d[94] = { block_q[93][511:384], t93, block_q[93][319:0] };
		block_d[93] = { block_q[92][511:448], t92, block_q[92][383:0] };
		block_d[92] = {                       t91, block_q[91][447:0] };

		block_d[91] = pi9;

		// Round 9
		block_d[90] = block_q[89] ^ key_d[8];
		block_d[89] = { block_q[88][511: 64], t88 };
		block_d[88] = { block_q[87][511:128], t87, block_q[87][ 63:0] };
		block_d[87] = { block_q[86][511:192], t86, block_q[86][127:0] };
		block_d[86] = { block_q[85][511:256], t85, block_q[85][191:0] };
		block_d[85] = { block_q[84][511:320], t84, block_q[84][255:0] };
		block_d[84] = { block_q[83][511:384], t83, block_q[83][319:0] };
		block_d[83] = { block_q[82][511:448], t82, block_q[82][383:0] };
		block_d[82] = {                       t81, block_q[81][447:0] };

		block_d[81] = pi8;

		// Round 8
		block_d[80] = block_q[79] ^ key_d[7];
		block_d[79] = { block_q[78][511: 64], t78 };
		block_d[78] = { block_q[77][511:128], t77, block_q[77][ 63:0] };
		block_d[77] = { block_q[76][511:192], t76, block_q[76][127:0] };
		block_d[76] = { block_q[75][511:256], t75, block_q[75][191:0] };
		block_d[75] = { block_q[74][511:320], t74, block_q[74][255:0] };
		block_d[74] = { block_q[73][511:384], t73, block_q[73][319:0] };
		block_d[73] = { block_q[72][511:448], t72, block_q[72][383:0] };
		block_d[72] = {                       t71, block_q[71][447:0] };

		block_d[71] = pi7;

		// Round 7
		block_d[70] = block_q[69] ^ key_d[6];
		block_d[69] = { block_q[68][511: 64], t68 };
		block_d[68] = { block_q[67][511:128], t67, block_q[67][ 63:0] };
		block_d[67] = { block_q[66][511:192], t66, block_q[66][127:0] };
		block_d[66] = { block_q[65][511:256], t65, block_q[65][191:0] };
		block_d[65] = { block_q[64][511:320], t64, block_q[64][255:0] };
		block_d[64] = { block_q[63][511:384], t63, block_q[63][319:0] };
		block_d[63] = { block_q[62][511:448], t62, block_q[62][383:0] };
		block_d[62] = {                       t61, block_q[61][447:0] };

		block_d[61] = pi6;

		// Round 6
		block_d[60] = block_q[59] ^ key_d[5];
		block_d[59] = { block_q[58][511: 64], t58 };
		block_d[58] = { block_q[57][511:128], t57, block_q[57][ 63:0] };
		block_d[57] = { block_q[56][511:192], t56, block_q[56][127:0] };
		block_d[56] = { block_q[55][511:256], t55, block_q[55][191:0] };
		block_d[55] = { block_q[54][511:320], t54, block_q[54][255:0] };
		block_d[54] = { block_q[53][511:384], t53, block_q[53][319:0] };
		block_d[53] = { block_q[52][511:448], t52, block_q[52][383:0] };
		block_d[52] = {                       t51, block_q[51][447:0] };

		block_d[51] = pi5;

		// Round 5
		block_d[50] = block_q[49] ^ key_d[4];
		block_d[49] = { block_q[48][511: 64], t48 };
		block_d[48] = { block_q[47][511:128], t47, block_q[47][ 63:0] };
		block_d[47] = { block_q[46][511:192], t46, block_q[46][127:0] };
		block_d[46] = { block_q[45][511:256], t45, block_q[45][191:0] };
		block_d[45] = { block_q[44][511:320], t44, block_q[44][255:0] };
		block_d[44] = { block_q[43][511:384], t43, block_q[43][319:0] };
		block_d[43] = { block_q[42][511:448], t42, block_q[42][383:0] };
		block_d[42] = {                       t41, block_q[41][447:0] };

		block_d[41] = pi4;

		// Round 4
		block_d[40] = block_q[39] ^ key_d[3];
		block_d[39] = { block_q[38][511: 64], t38 };
		block_d[38] = { block_q[37][511:128], t37, block_q[37][ 63:0] };
		block_d[37] = { block_q[36][511:192], t36, block_q[36][127:0] };
		block_d[36] = { block_q[35][511:256], t35, block_q[35][191:0] };
		block_d[35] = { block_q[34][511:320], t34, block_q[34][255:0] };
		block_d[34] = { block_q[33][511:384], t33, block_q[33][319:0] };
		block_d[33] = { block_q[32][511:448], t32, block_q[32][383:0] };
		block_d[32] = {                       t31, block_q[31][447:0] };

		block_d[31] = pi3;

		// Round 3
		block_d[30] = block_q[29] ^ key_d[2];
		block_d[29] = { block_q[28][511: 64], t28 };
		block_d[28] = { block_q[27][511:128], t27, block_q[27][ 63:0] };
		block_d[27] = { block_q[26][511:192], t26, block_q[26][127:0] };
		block_d[26] = { block_q[25][511:256], t25, block_q[25][191:0] };
		block_d[25] = { block_q[24][511:320], t24, block_q[24][255:0] };
		block_d[24] = { block_q[23][511:384], t23, block_q[23][319:0] };
		block_d[23] = { block_q[22][511:448], t22, block_q[22][383:0] };
		block_d[22] = {                       t21, block_q[21][447:0] };

		block_d[21] = pi2;

		// Round 2
		block_d[20] = block_q[19] ^ key_d[1];
		block_d[19] = { block_q[18][511: 64], t18 };
		block_d[18] = { block_q[17][511:128], t17, block_q[17][ 63:0] };
		block_d[17] = { block_q[16][511:192], t16, block_q[16][127:0] };
		block_d[16] = { block_q[15][511:256], t15, block_q[15][191:0] };
		block_d[15] = { block_q[14][511:320], t14, block_q[14][255:0] };
		block_d[14] = { block_q[13][511:384], t13, block_q[13][319:0] };
		block_d[13] = { block_q[12][511:448], t12, block_q[12][383:0] };
		block_d[12] = {                       t11, block_q[11][447:0] };
		
		block_d[11] = pi1;

		// Round 1
		block_d[10] = block_q[9] ^ key_d[0];
		block_d[9]  = { block_q[8][511: 64], t08 };
		block_d[8]  = { block_q[7][511:128], t07, block_q[7][ 63:0] };
		block_d[7]  = { block_q[6][511:192], t06, block_q[6][127:0] };
		block_d[6]  = { block_q[5][511:256], t05, block_q[5][191:0] };
		block_d[5]  = { block_q[4][511:320], t04, block_q[4][255:0] };
		block_d[4]  = { block_q[3][511:384], t03, block_q[3][319:0] };
		block_d[3]  = { block_q[2][511:448], t02, block_q[2][383:0] };
		block_d[2]  = {                      t01, block_q[1][447:0] };
		
		block_d[1]  = pi0;


		// Reset Keys When New Work Is Received
		if ( new_work ) begin
		
			// State Keys
			key_d[0] = {64'h1823C6E887B8014F, 448'd0};
			key_d[1] = {64'h36A6D2F5796F9152, 448'd0};
			key_d[2] = {64'h60BC9B8EA30C7B35, 448'd0};
			key_d[3] = {64'h1DE0D7C22E4BFE57, 448'd0};
			key_d[4] = {64'h157737E59FF04ADA, 448'd0};
			key_d[5] = {64'h58C9290AB1A06B85, 448'd0};
			key_d[6] = {64'hBD5D10F4CB3E0567, 448'd0};
			key_d[7] = {64'hE427418BA77D95D8, 448'd0};
			key_d[8] = {64'hFBEE7C66DD17479E, 448'd0};
			key_d[9] = {64'hCA2DBF07AD5A8333, 448'd0};

			block_d[0] = state;
			
			nonce_d = 32'd0;
			
			hash_ready_d = 1'b0;
			hashing_d = 1'b0;
			cnt_100_d = 7'd0;

		end

		// The First 90 Clks Are Use To Calculate The Block Keys
		else if ( !hashing_d ) begin

			// Use Midstate To Calculate Block Keys
			block_d[0] = state;
			
			nonce_d = 32'd0;
//			nonce_d = 32'h8752FFF0;
		
			cnt_100_d = cnt_100_d + 7'd1;
			
			if ( cnt_100_d == 7'd101 ) begin
			
				block_key_ready_d = 1'b1;
				hashing_d = 1'b1;
				cnt_100_d = 7'd0;
				
				// Start Using The Block Data In The Pipeline
				block_d[0] = { header, nonce_d, 8'h80, 360'd0, 16'h0280 } ^ state;

			end
			
		end
		
		// Check If A Valid Nonce Was Found
		else begin

			block_d[0] = block_q[0];
			block_d[0][415:384] = state[415:384] ^ nonce_d;

			// Calculate The XOR Of The Whirlpool Hash (Only 32 Bits Are Checked)
			hash_xor_d = {state[263:256] ^ state[135:128] ^ block_q[100][263:256] ^ block_q[100][135:128],
							  state[271:264] ^ state[143:136] ^ block_q[100][271:264] ^ block_q[100][143:136],
							  state[279:272] ^ state[151:144] ^ block_q[100][279:272] ^ block_q[100][151:144],
							  state[287:280] ^ state[159:152] ^ block_q[100][287:280] ^ block_q[100][159:152]};

//			if ( hash_ready_q && ( hash_xor_d[31:8] == 24'h000000 ) ) begin
			if ( hash_ready_q && ( hash_xor_d == 32'h00000000 ) ) begin
			
				nonce_found_d = 1'b1;
				
			end
			
			nonce_out_d = nonce_q - 32'd101;
			nonce_d = nonce_q + 32'd1;

			// Need To Wait 100 Clocks Before Valid Hashes Are Produced
			if ( !hash_ready_q ) begin
				cnt_100_d = cnt_100_d + 7'd1;
			
				if ( cnt_100_d == 7'd103 ) begin
			
					hash_ready_d = 1'b1;
					cnt_100_d = 7'd0;

				end

			end

		end

	end

	always @ (posedge clk) begin

		cnt_100_q <= cnt_100_d;

		nonce_q <= nonce_d;
		nonce_out_q <= nonce_out_d;
		nonce_found_q <= nonce_found_d;
		
		hash_ready_q <= hash_ready_d;
		hash_xor_q <= hash_xor_d;

		hashing_q <= hashing_d;

		// Check If The Block Keys Are Ready
		if ( block_key_ready_d ) begin

			key_q[0] <= block_d[10];
			key_q[1] <= block_d[20];
			key_q[2] <= block_d[30];
			key_q[3] <= block_d[40];
			key_q[4] <= block_d[50];
			key_q[5] <= block_d[60];
			key_q[6] <= block_d[70];
			key_q[7] <= block_d[80];
			key_q[8] <= block_d[90];
			key_q[9] <= block_d[100];
			
		end
		else begin
		
			key_q[9] <= key_d[9];
			key_q[8] <= key_d[8];
			key_q[7] <= key_d[7];
			key_q[6] <= key_d[6];
			key_q[5] <= key_d[5];
			key_q[4] <= key_d[4];
			key_q[3] <= key_d[3];
			key_q[2] <= key_d[2];
			key_q[1] <= key_d[1];
			key_q[0] <= key_d[0];
		
		end

		block_q[100] <= block_d[100];
		block_q[99] <= block_d[99];
		block_q[98] <= block_d[98];
		block_q[97] <= block_d[97];
		block_q[96] <= block_d[96];
		block_q[95] <= block_d[95];
		block_q[94] <= block_d[94];
		block_q[93] <= block_d[93];
		block_q[92] <= block_d[92];
		block_q[91] <= block_d[91];
		block_q[90] <= block_d[90];
		block_q[89] <= block_d[89];
		block_q[88] <= block_d[88];
		block_q[87] <= block_d[87];
		block_q[86] <= block_d[86];
		block_q[85] <= block_d[85];
		block_q[84] <= block_d[84];
		block_q[83] <= block_d[83];
		block_q[82] <= block_d[82];
		block_q[81] <= block_d[81];
		block_q[80] <= block_d[80];
		block_q[79] <= block_d[79];
		block_q[78] <= block_d[78];
		block_q[77] <= block_d[77];
		block_q[76] <= block_d[76];
		block_q[75] <= block_d[75];
		block_q[74] <= block_d[74];
		block_q[73] <= block_d[73];
		block_q[72] <= block_d[72];
		block_q[71] <= block_d[71];
		block_q[70] <= block_d[70];
		block_q[69] <= block_d[69];
		block_q[68] <= block_d[68];
		block_q[67] <= block_d[67];
		block_q[66] <= block_d[66];
		block_q[65] <= block_d[65];
		block_q[64] <= block_d[64];
		block_q[63] <= block_d[63];
		block_q[62] <= block_d[62];
		block_q[61] <= block_d[61];
		block_q[60] <= block_d[60];
		block_q[59] <= block_d[59];
		block_q[58] <= block_d[58];
		block_q[57] <= block_d[57];
		block_q[56] <= block_d[56];
		block_q[55] <= block_d[55];
		block_q[54] <= block_d[54];
		block_q[53] <= block_d[53];
		block_q[52] <= block_d[52];
		block_q[51] <= block_d[51];
		block_q[50] <= block_d[50];
		block_q[49] <= block_d[49];
		block_q[48] <= block_d[48];
		block_q[47] <= block_d[47];
		block_q[46] <= block_d[46];
		block_q[45] <= block_d[45];
		block_q[44] <= block_d[44];
		block_q[43] <= block_d[43];
		block_q[42] <= block_d[42];
		block_q[41] <= block_d[41];
		block_q[40] <= block_d[40];
		block_q[39] <= block_d[39];
		block_q[38] <= block_d[38];
		block_q[37] <= block_d[37];
		block_q[36] <= block_d[36];
		block_q[35] <= block_d[35];
		block_q[34] <= block_d[34];
		block_q[33] <= block_d[33];
		block_q[32] <= block_d[32];
		block_q[31] <= block_d[31];
		block_q[30] <= block_d[30];
		block_q[29] <= block_d[29];
		block_q[28] <= block_d[28];
		block_q[27] <= block_d[27];
		block_q[26] <= block_d[26];
		block_q[25] <= block_d[25];
		block_q[24] <= block_d[24];
		block_q[23] <= block_d[23];
		block_q[22] <= block_d[22];
		block_q[21] <= block_d[21];
		block_q[20] <= block_d[20];
		block_q[19] <= block_d[19];
		block_q[18] <= block_d[18];
		block_q[17] <= block_d[17];
		block_q[16] <= block_d[16];
		block_q[15] <= block_d[15];
		block_q[14] <= block_d[14];
		block_q[13] <= block_d[13];
		block_q[12] <= block_d[12];
		block_q[11] <= block_d[11];
		block_q[10] <= block_d[10];
		block_q[9] <= block_d[9];
		block_q[8] <= block_d[8];
		block_q[7] <= block_d[7];
		block_q[6] <= block_d[6];
		block_q[5] <= block_d[5];
		block_q[4] <= block_d[4];
		block_q[3] <= block_d[3];
		block_q[2] <= block_d[2];
		block_q[1] <= block_d[1];
		block_q[0] <= block_d[0];
	
	end

endmodule
