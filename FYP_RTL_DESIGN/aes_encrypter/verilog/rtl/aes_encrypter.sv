module aes_encrypter (
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
    logic [0:127] round_keys            ; // Store 11 round keys
    logic [127:0] state_pipeline  [0:10];
    logic         valid_pipeline  [0:10];
    logic         valid_pipeline_d      ;

    // Key Expansion Module
    key_expansion key_exp (
        .clk       (clk       ),
        .rst       (rst       ),
        .cipher_key(key       ),
        .valid     (valid_key ),
        .out       (round_keys)
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
            state_pipeline[0] <= fifo_out ^ key;
            valid_pipeline[0] <= 1;
        end
    end

    // AES Rounds 1-9
    genvar i;
    generate
        for (i = 0; i < 9; i++) begin : aes_rounds
            logic [127:0] subbyte_stage, shiftrows_stage, mixcolumns_stage;

            sub_byte sub_byte_inst (
                .in (state_pipeline[i]),
                .out(subbyte_stage    )
            );

            shift_rows shift_rows_inst (
                .in (subbyte_stage  ),
                .out(shiftrows_stage)
            );

            mix_column mix_column_inst (
                .in (shiftrows_stage ),
                .out(mixcolumns_stage)
            );

            always_ff @(posedge clk or posedge rst) begin
                if (rst)
                    state_pipeline[i+1] <= 0;
                else if (valid_pipeline[i])
                    state_pipeline[i+1] <= mixcolumns_stage ^ round_keys;
            end

            always_ff @(posedge clk or posedge rst) begin
                if (rst)
                    valid_pipeline[i+1] <= 0;
                else
                    valid_pipeline[i+1] <= valid_pipeline[i];
            end
        end
    endgenerate

    // Final Round (no MixColumns)
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
        if (rst) begin
            state_pipeline[10] <= 0;
            valid_pipeline[10] <= 0;
        end  else if(valid_pipeline[10]) begin
            for (int i = 0; i < 11; i++) begin
            valid_pipeline[i] <=  0 ;
            end
        end else if (valid_pipeline[9]) begin
            state_pipeline[10] <= shiftrows_last ^ round_keys;
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
