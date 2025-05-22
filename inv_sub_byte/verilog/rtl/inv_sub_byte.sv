module inv_sub_byte (
	input  logic [127:0] in ,
	output logic [127:0] out
);

	logic [7:0] s   [ 15:0];
	logic [7:0] sub [ 15:0];

	assign {s[0 ], s[1 ], s[2 ], s[3 ],
		    s[4 ], s[5 ], s[6 ], s[7 ],
		    s[8 ], s[9 ], s[10], s[11],
		    s[12], s[13], s[14], s[15]} = in;

	genvar i;
	generate
		for(i=0;i<=15;i=i+1)
			begin : substitute

				aes_isbox isboxx (
					.addr(s[i]),
					.data(sub[i])
				);
				// assign sub[i] = sbox[s[i]];
			end
	endgenerate

	assign out = {sub[0 ], sub[1 ], sub[2 ], sub[3 ],
		          sub[4 ], sub[5 ], sub[6 ], sub[7 ],
		          sub[8 ], sub[9 ], sub[10], sub[11],
		          sub[12], sub[13], sub[14], sub[15]} ;
endmodule






