`timescale 1ns / 1ps
module tb_aes_decrypter ();
logic         clk       = 0;
logic         rst       = 1;
logic [127:0] data_in   = 0;
logic [127:0] key       ;
logic         valid_in  = 0;
logic [127:0] data_out     ;
logic         valid_out    ;
logic         fifo_rd_en_t = 0;
logic valid_key;

//*********************************
//DUT instantiation
//*********************************
	aes_decrypter aes_decrypter (
		.clk      (clk      ),
		.rst      (rst      ),
		.data_in  (data_in  ),
		.key      (key      ),
		.valid_in (valid_in ),
		.data_out (data_out ),
		.valid_out(valid_out),
		.valid_key   (valid_key),
		.fifo_rd_en_t(fifo_rd_en_t)
	);
logic [127:0] exp_out ;



  assign exp_out = {8'h01,8'h02,8'h04,8'h03,
		            8'h02,8'h03,8'h02,8'h01,
		            8'h04,8'h05,8'h06,8'h07,
		            8'h07,8'h05,8'h04,8'h03};
	always #5 clk= !clk;


	initial begin
		

		 key={8'h01,8'h05,8'h09,8'h0d,
		      8'h02,8'h06,8'h0a,8'h0e,
		      8'h03,8'h07,8'h0b,8'h0f,
		      8'h04,8'h08,8'h0c,8'h10};

		 repeat(10) @(posedge clk);
		 rst = 0;

		 repeat(5 ) @(posedge clk);
         data_in = { 8'hB1, 8'h86, 8'h31, 8'h7E,
                     8'hB9, 8'hCC, 8'hAE, 8'h5B,
                     8'hBB, 8'hD0, 8'h27, 8'hA1,
                     8'h1C, 8'hEB, 8'h8D, 8'h22 };
		 valid_in = 1;
		 @(posedge clk);
		 valid_in = 0;

		 valid_key= 1;
		 @(posedge clk);
		 valid_key=0;

		 repeat(20) @(posedge clk);
		 fifo_rd_en_t = 1;
		repeat(1) @(posedge clk);
		 fifo_rd_en_t = 0;
		 repeat(100) @(posedge clk);
			 $stop;
	end

	always_ff @(posedge clk) begin 
		 if (data_out == exp_out) begin
		 	$display("encrypted succesfully");
		 // repeat(100) @(posedge clk);
		    $stop;
		  end
		 else begin	
		 	$display("encryption failed");
		 end		 	
		end
endmodule 