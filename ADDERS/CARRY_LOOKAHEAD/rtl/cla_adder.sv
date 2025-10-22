module cla_adder #(
    parameter int WIDTH = 16  // must be multiple of 4
) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic             cin,
    output logic [WIDTH-1:0] sum,
    output logic             cout
);
    localparam int NUM_BLOCKS = WIDTH / 4;
    // Per-block propagate/generate and block carries
    logic [NUM_BLOCKS-1:0] P_blk, G_blk;
    logic [NUM_BLOCKS:0]   C_blk; // block carries: C_blk[0] = cin, C_blk[i+1] = carry-out of block i
    assign C_blk[0] = cin;

    genvar i;
    generate
        for (i = 0; i < NUM_BLOCKS; i++) begin : gen_blocks
            // slice signals for block i
            localparam int LSB = 4*i;
            localparam int MSB = LSB + 3;
            // instantiate 4-bit CLA block
            cla_4bit u_cla4 (
                .a    (a[LSB +: 4]),
                .b    (b[LSB +: 4]),
                .cin  (C_blk[i]),
                .sum  (sum[LSB +: 4]),
                .cout (),         // internal, we use C_blk[i+1] computed from G_blk/P_blk
                .P_blk(P_blk[i]),
                .G_blk(G_blk[i])
            );
            // compute next block carry using block PG
            assign C_blk[i+1] = G_blk[i] | (P_blk[i] & C_blk[i]);
        end
    endgenerate

    assign cout = C_blk[NUM_BLOCKS];

endmodule
