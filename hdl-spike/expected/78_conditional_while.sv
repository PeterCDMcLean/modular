module LogicWhileConditional(
  input  [63:0] count,
  input         a,
                b,
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
  wire             _GEN_2;
  wire      [63:0] _GEN_3;
  wire      [7:0]  _GEN_4;
  wire      [7:0]  _GEN_5;
  var logic [63:0] _GEN_6 = 64'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_6 <= 64'h0;
    else
      _GEN_6 <= _GEN_3;
  end
  var logic        _GEN_7 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_7 <= 1'h0;
    else
      _GEN_7 <= _GEN_2;
  end
  var logic [7:0]  _GEN_8 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_8 <= 8'h0;
    else
      _GEN_8 <= _GEN_5;
  end
  var logic [7:0]  _GEN_9 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_9 <= 8'h0;
    else
      _GEN_9 <= _GEN_4;
  end
  wire             _GEN_10 = _GEN_7 & _GEN_6 < count;
  wire             _GEN_11 = _GEN_10 & a;
  wire      [7:0]  _GEN_12 = {8{_GEN_11}} & wd | _GEN_8;
  wire      [7:0]  _GEN_13 =
    _GEN_11 ? (_GEN_9 | wd_xz) & (_GEN_9 | ~_GEN_8) & (wd_xz | ~wd) : _GEN_9;
  wire             _GEN_14 = _GEN_10 & ~a;
  assign _GEN_5 = _GEN_7 ? ({8{~_GEN_14}} | wd) & _GEN_12 : wd;
  assign _GEN_4 =
    _GEN_7
      ? (_GEN_14 ? (_GEN_13 | wd_xz) & (_GEN_13 | _GEN_12) & (wd_xz | wd) : _GEN_13)
      : wd_xz;
  wire      [63:0] _GEN_15 = _GEN_6 + 64'h1;
  wire             _GEN_16 = _GEN_10 & a & b;
  wire             _GEN_17 = _GEN_10 & _GEN_15 == count | _GEN_16;
  assign _GEN_3 = _GEN_10 ? (_GEN_16 ? count : _GEN_15) : 64'h0;
  var logic        _GEN_18 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_18 <= 1'h0;
    else
      _GEN_18 <= _GEN_17;
  end
  assign _GEN_2 = ~_GEN_7 | ~_GEN_17;
  var logic [7:0]  _GEN_19 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_19 <= 8'h0;
    else
      _GEN_19 <= _GEN_1;
  end
  var logic [7:0]  _GEN_20 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_20 <= 8'h0;
    else
      _GEN_20 <= _GEN_0;
  end
  assign _GEN_1 = _GEN_18 ? _GEN_8 : _GEN_19;
  assign _GEN_0 = _GEN_18 ? _GEN_9 : _GEN_20;
  var logic [7:0]  reg_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      reg_1 <= 8'h0;
    else if (_GEN_18)
      reg_1 <= _GEN;
  end
  assign _GEN = reg_1 + 8'h1;
  assign out = _GEN_19;
  assign out_xz = _GEN_20;
endmodule
module WhileConditionalCarry(
  input  [63:0] count,
  input         a,
                b,
  input  [7:0]  wd,
  input         clk,
                rst,
  output [7:0]  out
);
  wire      [7:0]  _GEN;
  wire             _GEN_0;
  wire      [63:0] _GEN_1;
  wire      [7:0]  _GEN_2;
  var logic [63:0] _GEN_3 = 64'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_3 <= 64'h0;
    else
      _GEN_3 <= _GEN_1;
  end
  var logic        _GEN_4 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_4 <= 1'h0;
    else
      _GEN_4 <= _GEN_0;
  end
  var logic [7:0]  _GEN_5 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_5 <= 8'h0;
    else
      _GEN_5 <= _GEN_2;
  end
  wire             _GEN_6 = _GEN_4 & _GEN_3 < count;
  wire      [7:0]  _GEN_7 = _GEN_6 ? _GEN_5 + wd : _GEN_5;
  wire      [7:0]  _GEN_8 = _GEN_6 & a ? _GEN_7 + 8'h1 : _GEN_7;
  assign _GEN_2 = _GEN_4 ? (_GEN_6 & ~a ? _GEN_8 + 8'h2 : _GEN_8) : 8'h0;
  wire      [63:0] _GEN_9 = _GEN_3 + 64'h1;
  wire             _GEN_10 = _GEN_6 & a & b;
  wire             _GEN_11 = _GEN_6 & _GEN_9 == count | _GEN_10;
  assign _GEN_1 = _GEN_6 ? (_GEN_10 ? count : _GEN_9) : 64'h0;
  var logic        _GEN_12 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_12 <= 1'h0;
    else
      _GEN_12 <= _GEN_11;
  end
  assign _GEN_0 = ~_GEN_4 | ~_GEN_11;
  var logic [7:0]  reg_0 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      reg_0 <= 8'h0;
    else if (_GEN_12)
      reg_0 <= _GEN_5;
  end
  var logic [7:0]  reg_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      reg_1 <= 8'h0;
    else if (_GEN_12)
      reg_1 <= _GEN;
  end
  assign _GEN = reg_1 + 8'h1;
  assign out = reg_0;
endmodule
