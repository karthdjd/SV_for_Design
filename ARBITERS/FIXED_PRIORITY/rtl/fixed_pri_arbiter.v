module fixed_pri_arbiter#(parameter N=32)(
  
  input logic [N-1:0] req,
  output logic [N-1:0] gnt
);
  
  logic [N-1:0] high_pri_req;
  
  assign high_pri_req[0]= 1'b0;
  
  for(genvar i=0; i<N-1 ;i++)begin
    assign high_pri_req[i+1]= high_pri_req[i] | req[i];
  end
  
  assign gnt[N-1:0] = req[N-1:0] & ~(high_pri_req[N-1:0]);
  
endmodule
