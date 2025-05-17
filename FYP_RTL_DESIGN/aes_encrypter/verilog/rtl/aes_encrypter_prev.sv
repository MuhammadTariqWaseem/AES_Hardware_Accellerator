//aes_encrypter_prev.sv
module aes_encrypter (
    input  logic         clk      ,
    input  logic         rst      ,
    input  logic [127:0] data_in  ,
    input  logic [127:0] key      ,
    input  logic         valid_in ,
    input  logic         fifo_rd_en_t,
    output logic [127:0] data_out ,
    output logic         valid_out
);

    // Internal FIFO signals
    logic [127:0]  fifo_out;
    logic         fifo_wr_en, fifo_rd_en, fifo_empty, fifo_full;

    // Pipeline registers for AES rounds
    logic [127:0] round_keys    [0:10]; // Store 11 round keys
    logic [127:0] state_pipeline[0:10];
    logic         valid_pipeline[0:10];

    // Key Expansion Module
    key_expansion key_exp (
        .clk       (clk),
        .rst       (rst),
        .cipher_key(key),
        .out       ({round_keys[0],round_keys[1],round_keys[2],round_keys[3],
                    round_keys[4],round_keys[5],round_keys[6],round_keys[7],round_keys[8],round_keys[9]})
    );

    // Input FIFO
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
    logic fifo_rd_en_d;

    assign fifo_wr_en = valid_in & ~fifo_full;
    assign fifo_rd_en = ~fifo_empty;

    always_ff @(posedge clk or posedge rst) begin
        fifo_rd_en_d <= fifo_rd_en; 
        if (rst) begin
            state_pipeline[0] <= 0;
            valid_pipeline[0] <= 0;
        end else if (fifo_rd_en_d) begin
            state_pipeline[0] <= fifo_out ^ key; // Initial AddRoundKey
            valid_pipeline[0] <= 1;
        end
    end



    // AES Round Pipeline
    genvar i;
    generate
        for (i = 0; i < 9; i = i + 1) begin : aes_rounds
            logic [127:0] subbyte_stage, shiftrows_stage, mixcolumns_stage;

            sub_byte sub_byte_inst (
                .in (state_pipeline[i]),
                .out(subbyte_stage    )
            );

            // ShiftRows
            shift_rows shift_rows_inst (
                .in (subbyte_stage  ),
                .out(shiftrows_stage)
            );

            // MixColumns (Skipped in last round)
            mix_column mix_columns_inst (
                .in (shiftrows_stage ),
                .out(mixcolumns_stage)
            );

            // AddRoundKey
            always_ff @(posedge clk or posedge rst) begin
                if (rst)
                    state_pipeline[i+1] <= 128'b0;
                else
                    state_pipeline[i+1] <= mixcolumns_stage ^ round_keys[i];
            end


            always_ff @(posedge clk or posedge rst) begin
                if (rst) valid_pipeline[i+1] <= 0;
                else valid_pipeline[i+1] <= valid_pipeline[i];
            end
        end
    endgenerate

    logic [127:0] subbyte_last, shiftrows_last;

    sub_byte sub_byte_last (
        .in (state_pipeline[9]),
        .out(subbyte_last     )
    );

    shift_rows shift_rows_last (
        .in (subbyte_last  ),
        .out(shiftrows_last)
    );

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            state_pipeline[10] <= 128'b0;
        else begin
            state_pipeline[10] <= shiftrows_last ^ round_keys[9]; // Final AddRoundKey
            valid_pipeline[10] <= valid_pipeline[9];
        end
    end

    // Output FIFO
    fifo_128 output_fifo (
        .clk     (clk               ),
        .rst     (rst               ),
        .wr_en   (valid_pipeline[10]),
        .rd_en   (fifo_rd_en_t      ),
        .data_in (state_pipeline[10]),
        .data_out(data_out          ),
        .empty   (                  ),
        .full    (                  )
    );

    assign valid_out = valid_pipeline[10];

endmodule
