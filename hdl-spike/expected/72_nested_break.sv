module ElseIfBreak(
  input  [63:0] count,
  input         a,
                b,
  input  [7:0]  wd,
  input         clk,
                rst,
  output [7:0]  out
);
  wire             _GEN;
  wire      [63:0] _GEN_0;
  wire      [7:0]  _GEN_1;
  wire      [7:0]  _GEN_2;
  var logic [63:0] _GEN_3 = 64'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_3 <= 64'h0;
    else
      _GEN_3 <= _GEN_0;
  end
  var logic        _GEN_4 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_4 <= 1'h0;
    else
      _GEN_4 <= _GEN;
  end
  var logic [7:0]  _GEN_5 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_5 <= 8'h0;
    else
      _GEN_5 <= _GEN_1;
  end
  wire             _GEN_6 = _GEN_4 & _GEN_3 < count;
  var logic [7:0]  reg_0 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      reg_0 <= 8'h0;
    else if (_GEN_6 & ~a)
      reg_0 <= _GEN_2;
  end
  assign _GEN_2 = reg_0 + 8'h1;
  assign _GEN_1 = _GEN_4 ? (_GEN_6 & a ? _GEN_5 + wd : _GEN_5) : 8'h0;
  wire      [63:0] _GEN_7 = _GEN_3 + 64'h1;
  wire             _GEN_8 = _GEN_6 & ~a & b;
  wire             _GEN_9 = _GEN_6 & _GEN_7 == count | _GEN_8;
  assign _GEN_0 = _GEN_6 ? (_GEN_8 ? count : _GEN_7) : 64'h0;
  var logic        _GEN_10 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_10 <= 1'h0;
    else
      _GEN_10 <= _GEN_9;
  end
  assign _GEN = ~_GEN_4 | ~_GEN_9;
  var logic [7:0]  reg_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      reg_1 <= 8'h0;
    else if (_GEN_10)
      reg_1 <= _GEN_5;
  end
  assign out = reg_1;
endmodule
module NestedIfBreak(
  input  [63:0] count,
  input         a,
                b,
  input  [7:0]  wd,
  input         clk,
                rst,
  output [7:0]  out
);
  wire             _GEN;
  wire      [63:0] _GEN_0;
  wire      [7:0]  _GEN_1;
  wire      [7:0]  _GEN_2;
  var logic [63:0] _GEN_3 = 64'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_3 <= 64'h0;
    else
      _GEN_3 <= _GEN_0;
  end
  var logic        _GEN_4 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_4 <= 1'h0;
    else
      _GEN_4 <= _GEN;
  end
  var logic [7:0]  _GEN_5 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_5 <= 8'h0;
    else
      _GEN_5 <= _GEN_1;
  end
  wire             _GEN_6 = _GEN_4 & _GEN_3 < count;
  var logic [7:0]  reg_0 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      reg_0 <= 8'h0;
    else if (_GEN_6 & a)
      reg_0 <= _GEN_2;
  end
  assign _GEN_2 = reg_0 + 8'h1;
  assign _GEN_1 = _GEN_4 ? (_GEN_6 ? _GEN_5 + wd : _GEN_5) : 8'h0;
  wire      [63:0] _GEN_7 = _GEN_3 + 64'h1;
  wire             _GEN_8 = _GEN_6 & a & b;
  wire             _GEN_9 = _GEN_6 & _GEN_7 == count | _GEN_8;
  assign _GEN_0 = _GEN_6 ? (_GEN_8 ? count : _GEN_7) : 64'h0;
  var logic        _GEN_10 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_10 <= 1'h0;
    else
      _GEN_10 <= _GEN_9;
  end
  assign _GEN = ~_GEN_4 | ~_GEN_9;
  var logic [7:0]  reg_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      reg_1 <= 8'h0;
    else if (_GEN_10)
      reg_1 <= _GEN_5;
  end
  assign out = reg_1;
endmodule
module NestedLoopBreak(
  input  [63:0] n,
                m,
  input         a,
                b,
  input  [7:0]  wd,
  input         clk,
                rst,
  output [7:0]  out
);
  wire             _GEN;
  wire      [63:0] _GEN_0;
  wire      [7:0]  _GEN_1;
  wire      [63:0] _GEN_2;
  wire      [7:0]  _GEN_3;
  var logic [63:0] _GEN_4 = 64'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_4 <= 64'h0;
    else
      _GEN_4 <= _GEN_0;
  end
  var logic        _GEN_5 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_5 <= 1'h0;
    else
      _GEN_5 <= _GEN;
  end
  var logic [7:0]  _GEN_6 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_6 <= 8'h0;
    else
      _GEN_6 <= _GEN_1;
  end
  var logic [63:0] _GEN_7 = 64'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_7 <= 64'h0;
    else
      _GEN_7 <= _GEN_2;
  end
  wire             _GEN_8 = _GEN_5 & _GEN_4 < n & _GEN_7 < m;
  var logic [7:0]  reg_0 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      reg_0 <= 8'h0;
    else if (_GEN_8 & a)
      reg_0 <= _GEN_3;
  end
  assign _GEN_3 = reg_0 + 8'h1;
  wire             _GEN_9 = _GEN_8 & a & b;
  wire      [63:0] _GEN_10 = _GEN_7 + 64'h1;
  wire             _GEN_11 = _GEN_8 & _GEN_10 == m | _GEN_9;
  assign _GEN_2 = _GEN_8 ? (_GEN_9 ? m : _GEN_11 ? 64'h0 : _GEN_10) : 64'h0;
  assign _GEN_1 = _GEN_5 ? (_GEN_8 ? _GEN_6 + wd : _GEN_6) : 8'h0;
  wire      [63:0] _GEN_12 = _GEN_4 + 64'h1;
  wire             _GEN_13 = _GEN_11 & _GEN_12 == n;
  assign _GEN_0 = _GEN_11 ? (_GEN_13 ? 64'h0 : _GEN_12) : _GEN_4;
  var logic        _GEN_14 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_14 <= 1'h0;
    else
      _GEN_14 <= _GEN_13;
  end
  assign _GEN = ~_GEN_5 | ~_GEN_13;
  var logic [7:0]  reg_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      reg_1 <= 8'h0;
    else if (_GEN_14)
      reg_1 <= _GEN_6;
  end
  assign out = reg_1;
endmodule
