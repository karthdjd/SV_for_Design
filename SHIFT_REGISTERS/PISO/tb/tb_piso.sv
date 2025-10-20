`timescale 1ns/1ps

module tb_piso;

    // Parameters
    parameter int WIDTH = 8;

    // DUT signals
    logic                 clk;
    logic                 rst_n;
    logic                 load;
    logic                 shift_en;
    logic [WIDTH-1:0]     parallel_in;
    logic                 serial_out;

    // Expected results
    logic [WIDTH-1:0]     expected_data;
    logic [WIDTH-1:0]     captured_data;

    // Instantiate DUT
    piso #(.WIDTH(WIDTH)) dut (
        .clk         (clk),
        .rst_n       (rst_n),
        .load        (load),
        .shift_en    (shift_en),
        .parallel_in (parallel_in),
        .serial_out  (serial_out)
    );

    //------------------------------------------------------------
    // Clock generation (100 MHz)
    //------------------------------------------------------------
    initial clk = 0;
    always #5 clk = ~clk;

    //------------------------------------------------------------
    // VCD Dump setup
    //------------------------------------------------------------
    initial begin
        $dumpfile("piso_tb.vcd");   // Name of VCD file
        $dumpvars(0, tb_piso);      // Dump all signals in this testbench hierarchy
    end

    //------------------------------------------------------------
    // Test sequence
    //------------------------------------------------------------
    initial begin
        // Initialize signals
        rst_n         = 0;
        load          = 0;
        shift_en      = 0;
        parallel_in   = '0;
        captured_data = '0;

        // Apply reset
        #20;
        rst_n = 1;
        #10;

        // Load a test pattern
      @(posedge clk);
        parallel_in   = 8'b1101_0101;
        expected_data = parallel_in;
        load          = 1;
        @(posedge clk);
        load = 0;
        $display("\n[%0t] Loaded parallel data = %b", $time, parallel_in);

        // Shift out all bits
        for (int i = 0; i < WIDTH; i++) begin
            shift_en = 1;
            @(posedge clk);
            captured_data[WIDTH-1-i] = serial_out; // capture MSB-first output
            $display("[%0t] Shift %0d -> serial_out=%b", $time, i, serial_out);
         
            @(posedge clk);
        end

        // Check result
        if (captured_data === expected_data)
            $display("\n✅ TEST PASSED! Captured=%b Expected=%b\n", captured_data, expected_data);
        else
            $display("\n❌ TEST FAILED! Captured=%b Expected=%b\n", captured_data, expected_data);

        #20;
        $finish;
    end
  
  

endmodule
