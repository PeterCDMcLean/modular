module NestedAccum(
  input  [63:0] outer,
                inner,
  input  [7:0]  wd,
  input         clk,
                rst,
  output [7:0]  out
);
  wire      [7:0]  _GEN;
  wire      [7:0]  _GEN_0;
  wire             _GEN_1;
  wire      [63:0] _GEN_2;
  wire      [63:0] _GEN_3;
  var logic [63:0] _GEN_4 = 64'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_4 <= 64'h0;
    else
      _GEN_4 <= _GEN_2;
  end
  var logic        _GEN_5 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_5 <= 1'h0;
    else
      _GEN_5 <= _GEN_1;
  end
  var logic [7:0]  _GEN_6 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_6 <= 8'h0;
    else
      _GEN_6 <= _GEN_0;
  end
  var logic [63:0] _GEN_7 = 64'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_7 <= 64'h0;
    else
      _GEN_7 <= _GEN_3;
  end
  wire             _GEN_8 = _GEN_5 & _GEN_4 < outer & _GEN_7 < inner;
  wire      [63:0] _GEN_9 = _GEN_7 + 64'h1;
  wire             _GEN_10 = _GEN_8 & _GEN_9 == inner;
  assign _GEN_3 = ~_GEN_8 | _GEN_10 ? 64'h0 : _GEN_9;
  wire      [63:0] _GEN_11 = _GEN_4 + 64'h1;
  wire             _GEN_12 = _GEN_10 & _GEN_11 == outer;
  assign _GEN_2 = _GEN_10 ? (_GEN_12 ? 64'h0 : _GEN_11) : _GEN_4;
  var logic        _GEN_13 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_13 <= 1'h0;
    else
      _GEN_13 <= _GEN_12;
  end
  assign _GEN_1 = ~_GEN_5 | ~_GEN_12;
  assign _GEN_0 = _GEN_5 ? (_GEN_8 ? _GEN_6 + wd : _GEN_6) : 8'h0;
  var logic [7:0]  reg_0 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      reg_0 <= 8'h0;
    else if (_GEN_13)
      reg_0 <= _GEN_6;
  end
  var logic [7:0]  reg_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      reg_1 <= 8'h0;
    else if (_GEN_13)
      reg_1 <= _GEN;
  end
  assign _GEN = reg_1 + 8'h1;
  assign out = reg_0;
endmodule
module NestedLogicAccum(
  input  [63:0] outer,
                inner,
  input  [7:0]  wd,
                wd_xz,
  input         clk,
                rst,
  output [7:0]  out,
                out_xz
);
  wire      [7:0]  _GEN;
  wire      [7:0]  _GEN_0;
  wire      [7:0]  _GEN_1;
  wire      [7:0]  _GEN_2;
  wire      [7:0]  _GEN_3;
  wire             _GEN_4;
  wire      [63:0] _GEN_5;
  wire      [63:0] _GEN_6;
  var logic [63:0] _GEN_7 = 64'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_7 <= 64'h0;
    else
      _GEN_7 <= _GEN_5;
  end
  var logic        _GEN_8 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_8 <= 1'h0;
    else
      _GEN_8 <= _GEN_4;
  end
  var logic [7:0]  _GEN_9 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_9 <= 8'h0;
    else
      _GEN_9 <= _GEN_3;
  end
  var logic [7:0]  _GEN_10 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_10 <= 8'h0;
    else
      _GEN_10 <= _GEN_2;
  end
  var logic [63:0] _GEN_11 = 64'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_11 <= 64'h0;
    else
      _GEN_11 <= _GEN_6;
  end
  wire             _GEN_12 = _GEN_8 & _GEN_7 < outer & _GEN_11 < inner;
  wire      [63:0] _GEN_13 = _GEN_11 + 64'h1;
  wire             _GEN_14 = _GEN_12 & _GEN_13 == inner;
  assign _GEN_6 = ~_GEN_12 | _GEN_14 ? 64'h0 : _GEN_13;
  wire      [63:0] _GEN_15 = _GEN_7 + 64'h1;
  wire             _GEN_16 = _GEN_14 & _GEN_15 == outer;
  assign _GEN_5 = _GEN_14 ? (_GEN_16 ? 64'h0 : _GEN_15) : _GEN_7;
  var logic        _GEN_17 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_17 <= 1'h0;
    else
      _GEN_17 <= _GEN_16;
  end
  assign _GEN_4 = ~_GEN_8 | ~_GEN_16;
  assign _GEN_3 = _GEN_8 ? {8{_GEN_12}} & wd | _GEN_9 : wd;
  assign _GEN_2 =
    _GEN_8
      ? (_GEN_12 ? (_GEN_10 | wd_xz) & (_GEN_10 | ~_GEN_9) & (wd_xz | ~wd) : _GEN_10)
      : wd_xz;
  var logic [7:0]  _GEN_18 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_18 <= 8'h0;
    else
      _GEN_18 <= _GEN_1;
  end
  var logic [7:0]  _GEN_19 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_19 <= 8'h0;
    else
      _GEN_19 <= _GEN_0;
  end
  assign _GEN_1 = _GEN_17 ? _GEN_9 : _GEN_18;
  assign _GEN_0 = _GEN_17 ? _GEN_10 : _GEN_19;
  var logic [7:0]  reg_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      reg_1 <= 8'h0;
    else if (_GEN_17)
      reg_1 <= _GEN;
  end
  assign _GEN = reg_1 + 8'h1;
  assign out = _GEN_18;
  assign out_xz = _GEN_19;
endmodule
