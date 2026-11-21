module BitsCounter(
  input         clk,
  output [11:0] out
);
  wire      [11:0] _GEN;
  var logic [11:0] _GEN_0;
  always_ff @(posedge clk)
    _GEN_0 <= _GEN;
  assign _GEN = _GEN_0 + 12'h1;
  assign out = _GEN_0;
endmodule
