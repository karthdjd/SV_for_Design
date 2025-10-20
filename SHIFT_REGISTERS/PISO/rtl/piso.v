// PISO: Parallel-In Serial-Out (MSB-first), parameterizable width
module piso #(
    parameter int WIDTH = 8
) (
    input  logic                 clk,
    input  logic                 rst_n,      // active low sync reset
    input  logic                 load,       // load parallel_in when high (takes effect on rising edge)
    input  logic                 shift_en,   // when high, shift on rising edge
    input  logic [WIDTH-1:0]     parallel_in,
    output logic                 serial_out
);

    logic [WIDTH-1:0] shift_reg;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            shift_reg  <= '0;
            serial_out <= 1'b0;
        end else begin
            if (load) begin
                // Load parallel data into register
                shift_reg  <= parallel_in;
                // Output the MSB immediately after load (optional — consistent semantics)
                serial_out <= parallel_in[WIDTH-1];
            end else if (shift_en) begin
                // Output MSB, then shift left (MSB-first)
                serial_out <= shift_reg[WIDTH-1];
                shift_reg  <= {shift_reg[WIDTH-2:0], 1'b0}; // shift left, LSB fills zero
            end
        end
    end

endmodule
