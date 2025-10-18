`timescale 1ns/1ps

module tb_mux_recirculation_sync;

  // -------------------------------------
  // DUT I/O declarations
  // -------------------------------------
  logic c1, c2, rstn;
  logic [1:0] A;
  logic EN;
  logic [1:0] B;

  // -------------------------------------
  // DUT instantiation
  // -------------------------------------
  mux_recirculation_sync dut (
    .c1   (c1),
    .c2   (c2),
    .rstn (rstn),
    .A    (A),
    .EN   (EN),
    .B    (B)
  );

  // -------------------------------------
  // Clock generation (asynchronous)
  // -------------------------------------
  initial begin
    c1 = 0;
    forever #5 c1 = ~c1;    // 100 MHz
  end

  initial begin
    c2 = 0;
    forever #7 c2 = ~c2;    // ~71 MHz (asynchronous)
  end

  // -------------------------------------
  // Reset generation
  // -------------------------------------
  initial begin
    rstn = 0;
    repeat (3) @(posedge c1);
    rstn = 1;
  end

  // -------------------------------------
  // Stimulus generation
  // -------------------------------------
  initial begin
    A  = 2'b00;
    EN = 1'b0;

    wait (rstn);  // wait for reset deassertion

    // Send multiple asynchronous updates
    repeat (10) begin
      @(posedge c1);
      A  <= $urandom_range(0, 3);
      EN <= 1'b1;
      @(posedge c1);
      EN <= 1'b0; // disable for random time (recirculation phase)
      repeat ($urandom_range(1, 4)) @(posedge c1);
    end

    // Finish after a few extra cycles
    repeat (10) @(posedge c1);
    $finish;
  end

  // -------------------------------------
  // Display activity in console
  // -------------------------------------
  initial begin
    $display("Time\tC1\tC2\tEN\tA\tB");
    $monitor("%0t\t%b\t%b\t%b\t%0d\t%0d", $time, c1, c2, EN, A, B);
  end

  // -------------------------------------
  // VCD dump for waveform viewing
  // -------------------------------------
  initial begin
    $dumpfile("mux_recirculation.vcd");   // output VCD filename
    $dumpvars(0, tb_mux_recirculation_sync); // dump all hierarchy
  end

endmodule
