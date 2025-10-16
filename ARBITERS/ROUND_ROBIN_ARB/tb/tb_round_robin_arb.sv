`timescale 1ns/1ps

module tb_round_robin_arb;
  logic clk, rst_n;
  logic [2:0] req;
  logic [2:0] grant;

  // DUT instantiation
  round_robin_arb dut (
    .clk(clk),
    .rst_n(rst_n),
    .req(req),
    .grant(grant)
  );

  // Clock generation: 10ns period
  initial clk = 0;
  always #5 clk = ~clk;
  
   // Waveform dump setup
  initial begin
    $dumpfile("dump.vcd");   // Name of VCD file
    $dumpvars(0, tb_round_robin_arb); // Dump all signals in this module
  end


  // Test sequence
  initial begin
    $display("Time\t rst_n req grant");
    $monitor("%0t\t %b   %b   %b", $time, rst_n, req, grant);

    rst_n = 0;
    req   = 3'b000;
    #10;
    rst_n = 1;

    // Request pattern simulation
    #10 req = 3'b001; // Requester 0
    #20 req = 3'b011; // 0 and 1 request
    #20 req = 3'b110; // 1 and 2 request
    #20 req = 3'b101; // 0 and 2 request
    #20 req = 3'b000; // No requests
    #20 req = 3'b111; // All request simultaneously
    #50;

    $finish;
  end
endmodule
