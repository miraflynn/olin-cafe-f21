`default_nettype none // Overrides default behaviour (in a good way)

module led_array_driver(ena, x, cells, rows, cols);
  // Module I/O and parameters
  parameter N=3; // Size of Conway Cell Grid.
  parameter ROWS=N;
  parameter COLS=N;

  // I/O declarations
  input wire ena;
  input wire [$clog2(N):0] x;
  input wire [N*N-1:0] cells;
  output logic [N-1:0] rows;
  output logic [N-1:0] cols;

  // You can check parameters with the $error macro within initial blocks.
  initial begin
    if ((N <= 0) || (N > 8)) begin
      $error("N must be within 0 and 8.");
    end
    if (ROWS != COLS) begin
      $error("Non square led arrays are not supported. (%dx%d)", ROWS, COLS);
    end
    if (ROWS < N) begin
      $error("ROWS/COLS must be >= than the size of the Conway Grid.");
    end
  end

  wire [N-1:0] x_decoded;
  decoder_3_to_8 COL_DECODER(ena, x, x_decoded);

  always_comb cols = x_decoded;

  // generate
  //   genvar i;
  //   for(i = 0; i < N; i++) begin : fuckedy_fuck
  //     always_comb begin
  //       rows[i] = ~(
  //       (cells[0*N+i] & x_decoded[0]) |
  //       (cells[1*N+i] & x_decoded[1]) |
  //       (cells[2*N+i] & x_decoded[2])
  //       // (cells[3*N] & x_decoded[3]) |
  //       // (cells[4*N] & x_decoded[4]) |
  //       // (cells[5*N] & x_decoded[5]) |
  //       // (cells[6*N] & x_decoded[6]) |
  //       // (cells[7*N] & x_decoded[7])
  //     );
  //     end
  //   end
  // endgenerate
  always_comb begin : led_comb_logic
    cols = x_decoded;
    rows[N:0] = ~(
      (cells[1*N-1:0*N] & x_decoded) |
      (cells[2*N-1:1*N] & x_decoded) |
      (cells[3*N-1:2*N] & x_decoded) //|
      // (cells[4*N-1:3*N] & x_decoded[3]) |
      // (cells[5*N-1:4*N] & x_decoded[4]) |
      // (cells[6*N-1:5*N] & x_decoded[5]) |
      // (cells[7*N-1:6*N] & x_decoded[6]) |
      // (cells[8*N-1:7*N] & x_decoded[7])
    );
    // $display("\n");
    $display("CELLS: %b", cells);
    $display("X_DECODED: %b", x_decoded);
    // $display("***");
  end
  
endmodule

`default_nettype wire // reengages default behaviour, needed when using 
                      // other designs that expect it.