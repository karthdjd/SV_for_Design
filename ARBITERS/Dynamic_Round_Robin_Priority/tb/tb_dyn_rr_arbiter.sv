`timescale 1ns/1ps
module tb_dyn_rr_arbiter;

    localparam int N = 4;
    logic clk, rst_n;
    logic [N-1:0] req, grant;

    // DUT
    dyn_rr_arbiter #(.N(N)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .req(req),
        .grant(grant)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;  // 100 MHz
  

    // Stimulus
    initial begin
        $dumpfile("dyn_rr_arbiter.vcd");
        $dumpvars(0, tb_dyn_rr_arbiter);

        rst_n = 0;
        req   = 0;
        repeat (3) @(posedge clk);
        rst_n = 1;

        // Random traffic
        repeat (20) begin
            req = $urandom_range(0, (1<<N)-1);
            @(posedge clk);
            $display("[%0t] req=%b grant=%b", $time, req, grant);
        end

        // All requests active
        req = '1;
        repeat (8) @(posedge clk);
        req = '0;
        repeat (2) @(posedge clk);

        $display("Simulation completed");
        $finish;
    end

endmodule
