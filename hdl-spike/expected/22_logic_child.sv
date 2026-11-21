module LogicInverter(
  input  [7:0] a,
               a_xz,
  output [7:0] out,
               out_xz
);
  assign out = ~a;
  assign out_xz = a_xz;
endmodule
module LogicTop(
  input  [7:0] d,
               d_xz,
  output [7:0] out,
               out_xz
);
  LogicInverter inv (
    .a      (d),
    .a_xz   (d_xz),
    .out    (out),
    .out_xz (out_xz)
  );
endmodule
