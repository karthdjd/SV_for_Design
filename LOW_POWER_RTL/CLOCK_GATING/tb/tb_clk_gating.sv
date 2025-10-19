module tb_clk_gating;
  logic clk, rst_n, en;
  logic [3:0] din, dout;

  clk_gating_safe dut (.*);

  initial begin
    clk = 0; forever #5 clk = ~clk;
  end

  initial begin
    rst_n = 0; en = 0; din = 4'h0;
    #12 rst_n = 1;

    repeat (3) begin
      @(negedge clk);
      en = 1;
      din = $urandom_range(0,15);
    end

    #50 $finish;
  end

  initial begin
    $dumpfile("clk_gating.vcd");
    $dumpvars(0, tb_clk_gating);
  end
endmodule
