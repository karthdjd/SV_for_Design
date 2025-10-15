`timescale 1ns/1ps

module tb_fixed_pri_arbiter;

  // Parameters
  localparam N = 8;  // You can change this to match your DUT parameter (default 32)

  // DUT I/O
  reg  [N-1:0] req;
  wire [N-1:0] gnt;

  // Instantiate DUT
  fixed_pri_arbiter #(.N(N)) dut (
    .req(req),
    .gnt(gnt)
  );

  // Test procedure
  initial begin
    // --- VCD DUMP SETUP ---
    $dumpfile("dump.vcd");     // Output file name
    $dumpvars(0, tb_fixed_pri_arbiter); // Dump all signals in this module (recursively)
    // -----------------------

    $display("==============================================");
    $display("  Fixed Priority Arbiter Testbench (N=%0d)   ", N);
    $display("==============================================");
    $display("Time\t\tRequest\t\tGrant");
    $display("----------------------------------------------");

    // Initialize
    req = 0;
    #10; display_status();

    // Test 1: Single request at bit 0 (highest priority)
    req = 8'b0000_0001;
    #10; display_status();

    // Test 2: Multiple requests, bit 0 and bit 3
    req = 8'b0000_1001;
    #10; display_status();

    // Test 3: Only bit 3 active
    req = 8'b0000_1000;
    #10; display_status();

    // Test 4: Multiple requests (bit 4–7)
    req = 8'b1111_0000;
    #10; display_status();

    // Test 5: Random request patterns
    repeat (5) begin
      req = $random;
      #10; display_status();
    end

    // Done
    $display("----------------------------------------------");
    $display("Test completed! Check dump.vcd for waveform.");
    $finish;
  end

  // Helper task to print status
  task display_status;
    $display("%0t\t%b\t%b", $time, req, gnt);
  endtask

endmodule
