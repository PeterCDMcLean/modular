module PackedGet(
  input  [31:0] p,
  input  [63:0] i,
  output [7:0]  out
);
  wire [31:0] _GEN = p >> {i[28:0], 3'h0};
  assign out = _GEN[7:0];
endmodule
module PackedSet(
  input  [31:0] p,
  input  [63:0] i,
  input  [7:0]  v,
  output [31:0] out
);
  wire [31:0] _GEN = {i[28:0], 3'h0};
  assign out = p & ~(32'hFF << _GEN) | {24'h0, v} << _GEN;
endmodule
