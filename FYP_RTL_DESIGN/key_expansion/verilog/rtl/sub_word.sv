module sub_word (
	input  logic [31:0] in ,
	output logic [31:0] out
);

	logic [7:0] s   [  0:3];
	logic [7:0] sub [  0:3];
	logic [7:0] sbox[0:255];


	assign {s[3 ], s[2 ], s[1 ], s[0 ]} = in;

	genvar i;
	generate
		for(i=0;i<=3;i=i+1)
			begin:subsword
				aes_sbox sboxx (
					.addr(s[i]),
					.data(sub[i])
				);
			end
	endgenerate

	assign out = {sub[3 ], sub[2 ], sub[1 ], sub[0 ]} ;



endmodule 