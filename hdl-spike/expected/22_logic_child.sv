module LogicInverter(
  input  wire [7:0] a,
  input  wire [7:0] a_xz,
  output wire [7:0] out,
  output wire [7:0] out_xz
);
  assign out = ~a;
  assign out_xz = a_xz;
endmodule
module LogicTop(
  input  wire [7:0] d,
  input  wire [7:0] d_xz,
  output wire [7:0] out,
  output wire [7:0] out_xz
);
  LogicInverter inv (
    .a      (d),
    .a_xz   (d_xz),
    .out    (out),
    .out_xz (out_xz)
  );
endmodule
