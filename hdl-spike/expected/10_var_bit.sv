module BitPick(
  input  wire [11:0] a,
  input  wire [63:0] i,
  output wire        out
);
  wire [11:0] _GEN = a >> i[11:0];
  assign out = _GEN[0];
endmodule
