module sipo #(
    parameter int WIDTH = 8
) (
    input  logic             clk,          // clock
    input  logic             rst_n,        // active-low synchronous reset
    input  logic             shift_en,     // enables shifting
    input  logic             serial_in,    // serial input bit
    output logic [WIDTH-1:0] parallel_out  // parallel output (register contents)
);

    logic [WIDTH-1:0] shift_reg;

    always_ff @(posedge clk) begin
        if (!rst_n)
            shift_reg <= '0;
        else if (shift_en)
            // MSB-first: new bit enters LSB, data shifts left
            shift_reg <= {shift_reg[WIDTH-2:0], serial_in};
    end

    assign parallel_out = shift_reg;

endmodule
