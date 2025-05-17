module mix_column (
  input  logic [127:0] in ,
  output logic [127:0] out
);
  logic [7:0] inp      [0:3][0:3];
  logic [7:0] mul_mat  [0:3][0:3];
  logic [7:0] mul      [0:3][0:3][0:3]; // Stores multiplication results
  logic [7:0] const_mat[0:3][0:3];

  // Unpack input into 4x4 matrix
  assign {inp[0][0], inp[0][1], inp[0][2], inp[0][3],
          inp[1][0], inp[1][1], inp[1][2], inp[1][3],
          inp[2][0], inp[2][1], inp[2][2], inp[2][3],
          inp[3][0], inp[3][1], inp[3][2], inp[3][3]} = in;

  // Initialize constant matrix
  always_comb begin
    const_mat[0][0] = 8'h02; const_mat[0][1] = 8'h03; const_mat[0][2] = 8'h01; const_mat[0][3] = 8'h01;
    const_mat[1][0] = 8'h01; const_mat[1][1] = 8'h02; const_mat[1][2] = 8'h03; const_mat[1][3] = 8'h01;
    const_mat[2][0] = 8'h01; const_mat[2][1] = 8'h01; const_mat[2][2] = 8'h02; const_mat[2][3] = 8'h03;
    const_mat[3][0] = 8'h03; const_mat[3][1] = 8'h01; const_mat[3][2] = 8'h01; const_mat[3][3] = 8'h02;
  end

  // Generate block for gf_mul instantiation
  genvar i, j, k;
  generate
    for (i = 0; i < 4; i++) begin : row_loop
      for (j = 0; j < 4; j++) begin : col_loop
        for (k = 0; k < 4; k++) begin : mul_loop
          gf_mul gf_mul_inst (
            .a(inp[k][j]), 
            .b(const_mat[i][k]), 
            .result(mul[i][j][k])
          );
        end
      end
    end
  endgenerate

  // Compute XOR operation in always_comb
  always_comb begin
    for (int i = 0; i < 4; i++) begin
      for (int j = 0; j < 4; j++) begin
        mul_mat[i][j] = mul[i][j][0] ^ mul[i][j][1] ^ mul[i][j][2] ^ mul[i][j][3];
      end
    end
  end

  // Pack output back to 128-bit vector
  assign out = {mul_mat[0][0], mul_mat[0][1], mul_mat[0][2], mul_mat[0][3],
                mul_mat[1][0], mul_mat[1][1], mul_mat[1][2], mul_mat[1][3],
                mul_mat[2][0], mul_mat[2][1], mul_mat[2][2], mul_mat[2][3],
                mul_mat[3][0], mul_mat[3][1], mul_mat[3][2], mul_mat[3][3]};
endmodule
