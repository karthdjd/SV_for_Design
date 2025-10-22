`timescale 1ns/1ps

module tb_cla_adder;

  // --------------------------------------------------
  // Parameters
  // --------------------------------------------------
  localparam int WIDTH = 16;
  localparam int NUM_TESTS = 100;

  // --------------------------------------------------
  // DUT I/O signals
  // --------------------------------------------------
  logic [WIDTH-1:0] a, b;
  logic             cin;
  logic [WIDTH-1:0] sum;
  logic             cout;

  // expected result
  logic [WIDTH:0]   expected;
  int               error_count = 0;

  // --------------------------------------------------
  // DUT instantiation
  // --------------------------------------------------
  cla_adder #(.WIDTH(WIDTH)) dut (
      .a    (a),
      .b    (b),
      .cin  (cin),
      .sum  (sum),
      .cout (cout)
  );

  // --------------------------------------------------
  // Task: run one test vector
  // --------------------------------------------------
  task automatic run_test(
      input logic [WIDTH-1:0] a_in,
      input logic [WIDTH-1:0] b_in,
      input logic             cin_in
  );
      begin
          a   = a_in;
          b   = b_in;
          cin = cin_in;
          #1; // allow combinational settle

          // compute expected value
          expected = {1'b0, a} + {1'b0, b} + cin;

          if ({cout, sum} !== expected) begin
              error_count++;
              $display("[ERROR] a=%0h b=%0h cin=%0b => sum=%0h cout=%0b (expected sum=%0h cout=%0b)",
                        a, b, cin, sum, cout, expected[WIDTH-1:0], expected[WIDTH]);
          end
          else if (NUM_TESTS <= 10) begin
              $display("[PASS] a=%0h b=%0h cin=%0b => sum=%0h cout=%0b",
                        a, b, cin, sum, cout);
          end
      end
  endtask

  // --------------------------------------------------
  // Main test process
  // --------------------------------------------------
  initial begin
      $display("======================================");
      $display(" Starting Carry Lookahead Adder TB");
      $display(" WIDTH = %0d, NUM_TESTS = %0d", WIDTH, NUM_TESTS);
      $display("======================================");

      // --- VCD dump for waveform ---
      $dumpfile("cla_adder.vcd");
      $dumpvars(0, tb_cla_adder);

      // --- Directed tests ---
      run_test('h0000, 'h0000, 1'b0);
      run_test('h0001, 'h0001, 1'b0);
      run_test('hFFFF, 'h0001, 1'b0);
      run_test('hAAAA, 'h5555, 1'b1);
      run_test('h1234, 'h1111, 1'b0);

      // --- Random tests ---
      for (int i = 0; i < NUM_TESTS; i++) begin
          run_test($urandom, $urandom, $urandom_range(0,1));
      end

      // --- Summary ---
      if (error_count == 0)
          $display("\n✅ All %0d tests PASSED!", NUM_TESTS + 5);
      else
          $display("\n❌ %0d ERRORS detected out of %0d tests.", error_count, NUM_TESTS + 5);

      $display("======================================");
      $finish;
  end

endmodule
