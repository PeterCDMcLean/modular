module LogicCompare(
  input  [7:0] a,
               a_xz,
               b,
               b_xz,
               x,
               x_xz,
               y,
               y_xz,
  output       eq_out,
               eq_out_xz,
               ne_out,
               ne_out_xz
);
  wire [7:0] _GEN = a_xz | b_xz;
  wire       _GEN_0 = |_GEN;
  wire       _GEN_1 = (~_GEN & (a ^ b)) == 8'h0;
  wire [7:0] _GEN_2 = x_xz | y_xz;
  wire       _GEN_3 = |(~_GEN_2 & (x ^ y));
  assign eq_out = _GEN_1 & ~_GEN_0;
  assign eq_out_xz = _GEN_0 & _GEN_1;
  assign ne_out = _GEN_3;
  assign ne_out_xz = (|_GEN_2) & ~_GEN_3;
endmodule
