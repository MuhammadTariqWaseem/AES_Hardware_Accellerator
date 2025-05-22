module aes_decrypter (
  input  logic         clk         ,
  input  logic         rst         ,
  input  logic         valid_key   ,
  input  logic [127:0] data_in     ,
  input  logic [127:0] key         ,
  input  logic         valid_in    ,
  input  logic         fifo_rd_en_t,
  output logic [127:0] data_out    ,
  output logic         valid_out
);

  // Internal FIFO signals
  logic [127:0] fifo_out  ;
  logic         fifo_wr_en, fifo_rd_en, fifo_empty, fifo_full;

  // Pipeline registers for AES rounds
  logic [ 10:0][0:127] round_keys            ; // Store 11 round keys
  logic [127:0]        state_pipeline  [0:10];
  logic                valid_pipeline  [0:10];
  logic                valid_pipeline_d      ;
  logic [ 10:0][0:127] valid_in_store        ;

  logic [10:0][0:127] key_storage[22:0];

  always_ff @(posedge clk) begin
    if(rst) begin
      for (int i = 0; i < 23; i++) begin
        key_storage[i] <= 0;
      end
    end 
    else begin
      key_storage[0] <= round_keys;
      for (int i = 0; i < 22; i++) begin
        key_storage[i+1] <= key_storage[i];
      end
    end
  
    always_ff @(posedge clk) begin
        if(rst) begin
            valid_in_store <= 0;
        end 
        else begin
            valid_in_store <= {valid_in_store[10:0], valid_in};
        end
    end
  // Key Expansion Module
  key_expansion key_exp (
    .clk       (clk       ),
    .rst       (rst       ),
    .cipher_key(key       ),
    .valid     (valid_key ),
    .out       (round_keys)
  );

  Input FIFO
  fifo_128 input_fifo (
    .clk     (clk       ),
    .rst     (rst       ),
    .wr_en   (fifo_wr_en),
    .rd_en   (fifo_rd_en),
    .data_in (data_in   ),
    .data_out(fifo_out  ),
    .empty   (fifo_empty),
    .full    (fifo_full )
  );

  assign fifo_wr_en = valid_in & ~fifo_full;
  assign fifo_rd_en = ~fifo_empty;

  logic fifo_rd_en_d;
  always_ff @(posedge clk or posedge rst) begin
    if (rst)
      fifo_rd_en_d <= 0;
    else
      fifo_rd_en_d <= fifo_rd_en;
  end

  // Initial AddRoundKey
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state_pipeline[0] <= 0;
      valid_pipeline[0] <= 0;
    end else if (fifo_rd_en_d) begin
      state_pipeline[0] <= fifo_out ^ key_storage[10][10][0:127];
      valid_pipeline[0] <= 1;
    end
  end

  // AES Rounds 1-9
  genvar i;
  generate
    for (i = 0; i < 9; i++) begin : aes_rounds
      logic [127:0] inv_subbyte_stage, inv_shiftrows_stage, inv_mixcolumns_stage ,inv_addround_stage;

      inv_shift_rows inv_shift_rows_inst (
        .in (state_pipeline[i]  ),
        .out(inv_shiftrows_stage)
      );
      inv_sub_byte inv_sub_byte_inst (
        .in (inv_shiftrows_stage),
        .out(inv_subbyte_stage  )
      );

      always_ff @(posedge clk or posedge rst) begin
        if (rst)
          state_pipeline[i+1] <= 0;
        else if (valid_pipeline[i])
          inv_addround_stage <= inv_subbyte_stage ^ key_storage[11+i][9-i];
      end

      inv_mix_column inv_mix_column_inst (
        .in (inv_addround_stage),
        .out(state_pipeline[i+1])
      );

      always_ff @(posedge clk or posedge rst) begin
        if (rst)
          valid_pipeline[i+1] <= 0;
        else
          valid_pipeline[i+1] <= valid_pipeline[i];
      end
    end
  endgenerate

  // Final Round (no MixColumns)
  logic [127:0] inv_subbyte_last, inv_shiftrows_last;
  inv_shift_rows inv_shift_rows_last (
    .in (state_pipeline[9] ),
    .out(inv_shiftrows_last)
  );
  inv_sub_byte inv_sub_byte_last (
    .in (inv_shiftrows_last),
    .out(inv_subbyte_last  )
  );


  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state_pipeline[10] <= 0;
      valid_pipeline[10] <= 0;
    end  else if(valid_pipeline[10]) begin
      for (int i = 0; i < 11; i++) begin
        valid_pipeline[i] <= 0 ;
      end
    end else if (valid_pipeline[9]) begin
      state_pipeline[10] <= inv_subbyte_last ^ key_storage[20][0];
      valid_pipeline[10] <= valid_pipeline[9];
    end
  end

  always@(posedge  clk) begin
    valid_pipeline_d <= valid_pipeline[9];
    if (rst) begin
      valid_out <= 0;
    end
    else
      valid_out <= !valid_pipeline_d & valid_pipeline[9];
  end

  // Output FIFO
  fifo_128 output_fifo (
    .clk     (clk               ),
    .rst     (rst               ),
    .wr_en   (valid_out         ),
    .rd_en   (fifo_rd_en_t      ),
    .data_in (state_pipeline[10]),
    .data_out(data_out          ),
    .empty   (                  ),
    .full    (                  )
  );


endmodule
