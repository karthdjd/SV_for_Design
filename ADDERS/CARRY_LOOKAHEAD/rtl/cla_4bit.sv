module cla_4bit (
    input  logic [3:0] a,
    input  logic [3:0] b,
    input  logic       cin,    // carry-in for this 4-bit block
    output logic [3:0] sum,
    output logic       cout,   // carry-out from this 4-bit block
    output logic       P_blk,  // block propagate
    output logic       G_blk   // block generate
);
    // per-bit generate and propagate
    logic [3:0] g, p;
    assign g = a & b;
    assign p = a ^ b; // propagate = a xor b for sum, but for group P we need a|b? Note: for CLA, per-bit propagate used as a|b only in some formulations. We use p = a ^ b for sum, but use p_or = a | b for group propagate if needed. We'll adhere to conventional definitions below.

    // conventional per-bit propagate (p_or) and generate (g)
    logic [3:0] p_or;
    assign p_or = a | b;

    // block generate G = g3 | (p_or3 & g2) | (p_or3 & p_or2 & g1) | (p_or3 & p_or2 & p_or1 & g0)
    assign G_blk = g[3] | (p_or[3] & g[2]) | (p_or[3] & p_or[2] & g[1])
                   | (p_or[3] & p_or[2] & p_or[1] & g[0]);

    // block propagate P = p_or3 & p_or2 & p_or1 & p_or0
    assign P_blk = p_or[3] & p_or[2] & p_or[1] & p_or[0];

    // internal carries (c0 is cin)
    logic c1, c2, c3, c4;
    assign c1 = g[0] | (p_or[0] & cin);
    assign c2 = g[1] | (p_or[1] & g[0]) | (p_or[1] & p_or[0] & cin);
    assign c3 = g[2] | (p_or[2] & g[1]) | (p_or[2] & p_or[1] & g[0])
                | (p_or[2] & p_or[1] & p_or[0] & cin);
    assign c4 = G_blk | (P_blk & cin); // block carry-out

    // sum bits: sum[i] = a ^ b ^ carry_in
    assign sum[0] = a[0] ^ b[0] ^ cin;
    assign sum[1] = a[1] ^ b[1] ^ c1;
    assign sum[2] = a[2] ^ b[2] ^ c2;
    assign sum[3] = a[3] ^ b[3] ^ c3;

    assign cout = c4;

endmodule
