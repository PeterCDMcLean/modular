module Counter(
  input        clk,
  output [7:0] out
);
  wire      [7:0] _GEN;
  var logic [7:0] _GEN_0;
  always_ff @(posedge clk)
    _GEN_0 <= _GEN;
  assign _GEN = _GEN_0 + 8'h1;
  assign out = _GEN_0;
endmodule
