module BitPick(
  input  [11:0] a,
  input  [63:0] i,
  output        out
);
  wire [11:0] _GEN = a >> i[11:0];
  assign out = _GEN[0];
endmodule
