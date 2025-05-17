module fifo_128 (
	input  logic         clk     ,
	input  logic         rst     ,
	input  logic         rd_en   ,
	input  logic         wr_en   ,
	input  logic [127:0] data_in ,
	output logic [127:0] data_out,
	output logic         empty   ,
	output logic         full
);

	logic [127:0] fifo_buffer;

	always_ff @(posedge clk) begin
		if(rst) begin
			fifo_buffer <= 0;
			full        <= 1'b0;
			empty       <= 1'b1;
			data_out    <= 0;
		end
		else if(wr_en ) begin
			fifo_buffer <= data_in;
			full        <= 1'b1;
			empty       <= 1'b0;
		end
		else if(rd_en ) begin
			data_out <= fifo_buffer;
			full     <= 1'b0;
			empty    <= 1'b1;
		end
	end
endmodule