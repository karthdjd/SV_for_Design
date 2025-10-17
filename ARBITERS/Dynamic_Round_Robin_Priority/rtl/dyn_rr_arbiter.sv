`timescale 1ns/1ps
module dyn_rr_arbiter #(
    parameter int N = 4
) (
    input  logic           clk,
    input  logic           rst_n,   // active-low reset
    input  logic [N-1:0]   req,     // request lines
    output logic [N-1:0]   grant    // one-hot grant
);

    // Internal rotating priority pointer
    logic [$clog2(N)-1:0] ptr;

    // Rotated request vector
    logic [2*N-1:0] req_dbl;
    logic [N-1:0]   req_rot;
    logic [N-1:0]   grant_rot;

    // Concatenate req to itself and rotate by ptr
    always_comb begin
        req_dbl = {req, req};
        req_rot = req_dbl >> ptr;      // simple rotate right by ptr
    end
// Find first-high bit in req_rot and generate one-hot grant_rot
logic [N-1:0] grant_rot_tmp;
always_comb begin
    grant_rot_tmp = '0;
    for (int i = 0; i < N; i++) begin
        // Only assign if no previous bit is granted
        if ((grant_rot_tmp == 0) && req_rot[i])
            grant_rot_tmp[i] = 1'b1;
    end
    grant_rot = grant_rot_tmp;
end
    // Rotate grant back to original alignment
    always_comb begin
        grant = (grant_rot << ptr) | (grant_rot >> (N - ptr));
    end

    // Update pointer to next after granted index
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            ptr <= '0;
        else if (|grant)
            ptr <= (ptr + 1) % N; // move pointer after last grant
    end

    // Simple safety assertion
    always_ff @(posedge clk) begin
        if (rst_n)
            assert ($onehot0(grant))
                else $error("Multiple grants detected! grant=%b", grant);
    end

endmodule
