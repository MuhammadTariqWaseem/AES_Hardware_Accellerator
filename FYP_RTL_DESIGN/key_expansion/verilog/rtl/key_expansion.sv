
module key_expansion (
	input  logic          clk       ,
	input  logic          rst       ,
	input  logic          valid     ,
	input  logic [ 0:127] cipher_key,
	output logic [ 0:127] out
);
	logic [7:0] exp_key[0:43][0:3];
	// logic   [127:0] exp_key [9:0]                                         ;
	logic [7:0] tmp1_reg[0:3]                                         ;
	logic [7:0] tmp2_reg[0:3]                                         ;
	logic [7:0] Rcon    [0:9] = '{1, 2, 4, 8, 16, 32, 64, 128, 27, 54};
	// logic         start                                                       ;
	integer i;
	logic [3:0] idx;
	integer cnt;

	logic [2:0] cs,ns;

	always@(*) begin
		case (cs)
			0 : begin
				for (int n = 0; n < 4; n++) begin
					tmp1_reg[n] = 0;
					for (int m = 0; m < 44 ; m++) begin
						exp_key[m][n] = 0;
					end
				end
				out = 0;
				// idx=0;
			end

			1 : begin
				for (int j = 0; j < 4; j++) begin
					for (int k = 0; k < 4; k++) begin
						exp_key[j][k] = cipher_key[ (j*32)+(k*8)  +: 8];/*((15 - (j * 4 + k)) * 8)*/
				      // out[(idx++)*8 +: 8] = exp_key[j][k];
					end
				end
				// idx=0;
			end


			2 : begin
				// if (i % 4 == 0)
				//    begin
				// Rotate Word
				tmp1_reg[0] = exp_key[i-3][3]; //1 3
				tmp1_reg[1] = exp_key[i-2][3]; //2 3
				tmp1_reg[2] = exp_key[i-1][3]; //3 3
				tmp1_reg[3] = exp_key[i-4][3]; //0 3
				// XOR with Rcon
				exp_key[i][0]   = tmp2_reg[0] ^ exp_key[i-4][0] ^ Rcon[i/4 - 1];
				exp_key[i+1][0] = tmp2_reg[1] ^ exp_key[i-3][0];
				exp_key[i+2][0] = tmp2_reg[2] ^ exp_key[i-2][0];
				exp_key[i+3][0] = tmp2_reg[3] ^ exp_key[i-1][0];

            
				// end
				// else begin
				for (int j = 1; j < 4; j++) begin
					exp_key[i][j]   = exp_key[i  ][j-1] ^ exp_key[i-4][j];
					exp_key[i+1][j] = exp_key[i+1][j-1] ^ exp_key[i-3][j];
					exp_key[i+2][j] = exp_key[i+2][j-1] ^ exp_key[i-2][j];
					exp_key[i+3][j] = exp_key[i+3][j-1] ^ exp_key[i-1][j];
				   // out[(idx++)*8 +: 8] = exp_key[i][j];
				end

            // cnt= cnt+4; 
         
			end
		endcase
	end

	always@(*)
		begin
			if (rst) begin
				cs = 0;
				// cnt =0;
				idx=0;
			end
			else cs = ns;
		end

   always@(posedge clk) begin
   	case (cs)
   	   2'b00 : begin
   	   	     if (valid) begin
   		          ns <= 1;
   		          i  <= 4;
   		          cnt <=0;
   	   	      end
   	   	      else
   	   	       ns <= 0;	
   		        end
   	   2'b01 : begin
   		          ns <= 2;
   		          i  <= 4;
   		          // cnt <=0;
            cnt<= cnt+4; 

   		        end
   	   2'b10 : if(i == 44) begin
   	             ns <= 0;
   	             i  <= 0;
		   	     end
                 else begin
                 	 ns <= 2;
                 	 i  <= i + 4;
            cnt<= cnt+4; 

                 end
   	
   	endcase
   end

	sub_word sub_word (
		.in ({tmp1_reg[3], tmp1_reg[2], tmp1_reg[1], tmp1_reg[0]}),
		.out({tmp2_reg[3], tmp2_reg[2], tmp2_reg[1], tmp2_reg[0]})
	);

	always@(* )
	begin
		
			for (int j = cnt; j < cnt+4 ; j++) begin
				for (int k = 0; k < 4; k++) begin
			        out[(idx++)*8 +: 8] <= exp_key[j][k];
				end
		    end
		
	end

endmodule





// module key_expansion (
//     input  logic [127:0] cipher_key,
//     output logic [1407:0] out
// );
//     logic [31:0] w[0:43];   // 44 words (4 per round × 11 rounds)
//     logic [7:0]  Rcon[0:9] = '{8'h01, 8'h02, 8'h04, 8'h08, 8'h10, 8'h20, 8'h40, 8'h80, 8'h1B, 8'h36};

//     // AES S-box
//     function automatic [7:0] sbox(input [7:0] a);
//         case (a)
//             8'h00: sbox = 8'h63; 8'h01: sbox = 8'h7c; 8'h02: sbox = 8'h77; 8'h03: sbox = 8'h7b;
//             8'h04: sbox = 8'hf2; 8'h05: sbox = 8'h6b; 8'h06: sbox = 8'h6f; 8'h07: sbox = 8'hc5;
//             // ... (continue AES S-box)
//             8'hfd: sbox = 8'hd3; 8'hfe: sbox = 8'hc4; 8'hff: sbox = 8'h0b;
//             default: sbox = 8'h00;
//         endcase
//     endfunction

//     function automatic [31:0] sub_word(input [31:0] word);
//         sub_word = {sbox(word[31:24]), sbox(word[23:16]), sbox(word[15:8]), sbox(word[7:0])};
//     endfunction

//     integer i;
//     logic [31:0] temp;
//     logic [31:0] temp1;
//     logic [31:0] temp2;

//     always_comb begin
//         // Initial key to w[0..3]
//         for (i = 0; i < 4; i++) begin
//             w[i] = cipher_key[127 - i*32 -: 32];
//         end

//         // Key expansion loop
//         for (i = 4; i < 44; i++) begin
//             temp = w[i - 1];
//             if (i % 4 == 0) begin
//                 temp1 = {temp[23:0], temp[31:24]};      // RotWord
//                 // temp = sub_word(temp);                 // SubWord
//                 temp2[31:24] = temp2[31:24] ^ Rcon[(i/4) - 1]; // Rcon
//             end
//             w[i] = w[i - 4] ^ temp;
//         end

//         // Pack into output (round keys: 11 × 128 bits)
//         for (i = 0; i < 44; i++) begin
//             out[1407 - i*32 -: 32] = w[i];
//         end
//     end
// sub_word sub_word (
// 		.in ({temp1[31:24], temp1[23:16], temp1[15:8], temp1[7:0]}),
// 		.out({temp2[:24], temp2[23:16], temp2[15:8], temp2[7:0]})
// 	);
// endmodule