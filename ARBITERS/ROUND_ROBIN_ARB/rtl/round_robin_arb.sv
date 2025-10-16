module round_robin_arb (
  input  logic        clk,
  input  logic        rst_n,
  input  logic [2:0]  req,
  output logic [2:0]  grant
);

  logic [2:0] next_grant_sel;
  logic       grant_given;

  assign grant_given = (grant != 3'b000);

  // Sequential: update grant selector
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      next_grant_sel <= 3'b001;  // Start from requester 0
    else if (grant_given)
      next_grant_sel <= grant;   // Remember last granted requester
  end

  // Combinational: determine next grant
  always_comb begin
    grant = 3'b000;

    case (next_grant_sel)
      3'b001: begin
        if (req[1]) grant = 3'b010;
        else if (req[2]) grant = 3'b100;
        else if (req[0]) grant = 3'b001;
        else grant = 3'b000;
      end
      3'b010: begin
        if (req[2]) grant = 3'b100;
        else if (req[0]) grant = 3'b001;
        else if (req[1]) grant = 3'b010;
        else grant = 3'b000;
      end
      3'b100: begin
        if (req[0]) grant = 3'b001;
        else if (req[1]) grant = 3'b010;
        else if (req[2]) grant = 3'b100;
        else grant = 3'b000;
      end
      default: grant = 3'b001;
    endcase
  end

endmodule
