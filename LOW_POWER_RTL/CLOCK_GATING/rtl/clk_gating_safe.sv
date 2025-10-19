module clk_gating_safe(
  input  logic        clk, en, rst_n,
  input  logic [3:0]  din,
  output logic [3:0]  dout
);
  logic en_latched;
  logic clk_gt;

  // Latch the enable signal when clock is low
  always_latch begin
    if (!clk)
      en_latched <= en;
  end

  // Generate gated clock (safe)
  assign clk_gt = clk & en_latched;

  // Use gated clock for data flops
  always_ff @(posedge clk_gt or negedge rst_n) begin
    if (!rst_n)
      dout <= '0;
    else
      dout <= din;
  end

endmodule
