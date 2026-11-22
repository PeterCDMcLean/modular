module MixedEnable(
  input        en,
               other,
               clk,
               rst,
  output [7:0] out
);
  wire      [7:0] _GEN;
  wire      [7:0] _GEN_0;
  var logic [7:0] _GEN_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_1 <= 8'h0;
    else
      _GEN_1 <= _GEN;
  end
  assign _GEN_0 = _GEN_1 + 8'h1;
  assign _GEN = other ? _GEN_1 + 8'h2 : en ? _GEN_0 : _GEN_1;
  assign out = _GEN_1;
endmodule
module NestedMixedEnable(
  input        en,
               mode,
               other,
               clk,
               rst,
  output [7:0] out
);
  wire      [7:0] _GEN;
  wire      [7:0] _GEN_0;
  var logic [7:0] _GEN_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_1 <= 8'h0;
    else
      _GEN_1 <= _GEN;
  end
  assign _GEN_0 = _GEN_1 + 8'h1;
  assign _GEN = mode & other ? _GEN_1 + 8'h3 : en ? _GEN_0 : _GEN_1;
  assign out = _GEN_1;
endmodule
