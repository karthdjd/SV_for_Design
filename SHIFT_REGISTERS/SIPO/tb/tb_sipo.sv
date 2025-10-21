`timescale 1ns/1ps
module tb_sipo;
    parameter WIDTH = 8;

    logic clk, rst_n;
    logic shift_en;
    logic serial_in;
    logic [WIDTH-1:0] parallel_out;
  logic [7:0] data;

    // Instantiate DUT
    sipo #(.WIDTH(WIDTH)) uut (
        .clk(clk),
        .rst_n(rst_n),
        .shift_en(shift_en),
        .serial_in(serial_in),
        .parallel_out(parallel_out)
    );

    // Clock generator
    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz clock
  
  // VCD dump setup
    initial begin
        $dumpfile("sipo_wave.vcd");  // specify VCD file name
        $dumpvars(0, tb_sipo);       // dump all signals in this module (and submodules)
    end

    initial begin
        rst_n = 0;
        shift_en = 0;
        serial_in = 0;
        #20;

        rst_n = 1;
        #10;
      @(posedge clk);
        // Send 8-bit pattern (MSB-first: 1010_1100)
         data = 8'b10101100;
        for (int i = 7; i >= 0; i--) begin
            serial_in = data[i];
            shift_en = 1;
            #10;
           // shift_en = 0;
            #10;
            $display("t=%0t | in=%b | out=%b", $time, serial_in, parallel_out);
        end

        $display("Final parallel_out = %b (expected %b)", parallel_out, data);
        $finish;
    end
endmodule
