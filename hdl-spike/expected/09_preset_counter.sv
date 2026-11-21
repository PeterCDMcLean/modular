module PresetCounter(
  input         clk,
                rst,
  output [11:0] out
);
  wire      [11:0] _GEN;
  var logic [11:0] _GEN_0;
  always_ff @(posedge clk) begin
    if (rst)
      _GEN_0 <= 12'h5;
    else
      _GEN_0 <= _GEN;
  end
  assign _GEN = _GEN_0 + 12'h1;
  assign out = _GEN_0;
endmodule
