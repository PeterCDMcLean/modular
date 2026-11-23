function automatic integer hdl_max(input integer a, input integer b);
  return (a > b) ? a : b;
endfunction
module MaxWidth
  #(parameter /*integer*/ W) (
  input  wire [hdl_max(W, 16) - 1:0] a,
  output wire [hdl_max(W, 16) - 1:0] out
);
  assign out = a;
endmodule
