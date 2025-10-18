module mux_recirculation_sync (
  input  logic        c1, c2, rstn,
  input  logic [1:0]  A,      // data in (2 bits)
  input  logic        EN,     // enable in C1 domain
  output logic [1:0]  B       // data out (in C2 domain)
);

  // -------------------------------------------------
  // Stage 1: Source domain registers (C1)
  // -------------------------------------------------
  logic [1:0] A_reg;
  logic       EN_reg;

  always_ff @(posedge c1 or negedge rstn) begin
    if (!rstn) begin
      A_reg  <= '0;
      EN_reg <= 1'b0;
    end else begin
      A_reg  <= A;
      EN_reg <= EN;
    end
  end

  // -------------------------------------------------
  // Stage 2: Synchronize EN signal to C2 domain
  // -------------------------------------------------
  logic EN_sync1, EN_sync2;

  always_ff @(posedge c2 or negedge rstn) begin
    if (!rstn) begin
      EN_sync1 <= 1'b0;
      EN_sync2 <= 1'b0;
    end else begin
      EN_sync1 <= EN_reg;
      EN_sync2 <= EN_sync1;
    end
  end

  // -------------------------------------------------
  // Stage 3: Recirculating MUX in destination domain
  // -------------------------------------------------
  always_ff @(posedge c2 or negedge rstn) begin
    if (!rstn)
      B <= '0;
    else if (EN_sync2)
      B <= A_reg;          // load new data when EN is asserted (synced)
    else
      B <= B;              // recirculate old value
  end

endmodule
