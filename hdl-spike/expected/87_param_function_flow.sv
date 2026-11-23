function automatic integer hdl_clamp(input integer a0, input integer a1, input integer a2);
  if ((a0 < a1)) begin
    return a1;
  end
  if ((a0 > a2)) begin
    return a2;
  end
  return a0;
endfunction
module Clamped
  #(parameter /*integer*/ W) (
  input  wire [hdl_clamp(W, 16, 64) - 1:0] a,
  output wire [hdl_clamp(W, 16, 64) - 1:0] out
);
  assign out = a;
endmodule
