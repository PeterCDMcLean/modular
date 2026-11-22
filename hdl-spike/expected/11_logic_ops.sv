module LogicOps(
  input  wire       c,
  input  wire       c_xz,
  input  wire [7:0] a,
  input  wire [7:0] a_xz,
  input  wire [7:0] b,
  input  wire [7:0] b_xz,
  output wire [7:0] out,
  output wire [7:0] out_xz
);
  wire [7:0] _GEN = (a_xz | b_xz) & (a_xz | a) & (b_xz | b);
  wire [7:0] _GEN_0 = a & b;
  wire [7:0] _GEN_1 = a ^ b;
  wire [7:0] _GEN_2 = a_xz | b_xz;
  wire [7:0] _GEN_3 = (_GEN | _GEN_2) & (_GEN | ~_GEN_0) & (_GEN_2 | ~_GEN_1);
  wire [7:0] _GEN_4 = _GEN_0 | _GEN_1;
  assign out = c ? ~_GEN_4 : a;
  assign out_xz = c_xz ? ~(~(_GEN_3 | a_xz) & (_GEN_4 ^ a)) : c ? _GEN_3 : a_xz;
endmodule
