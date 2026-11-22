module LogicLoopInBranch(
  input  [63:0] count,
  input         go,
                stop,
  input  [7:0]  wd,
                wd_xz,
  input         clk,
                rst,
  output [7:0]  out,
                out_xz
);
  wire      [7:0]  _GEN;
  wire      [7:0]  _GEN_0;
  wire             _GEN_1;
  wire      [63:0] _GEN_2;
  wire      [7:0]  _GEN_3;
  wire      [7:0]  _GEN_4;
  var logic [63:0] _GEN_5 = 64'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_5 <= 64'h0;
    else
      _GEN_5 <= _GEN_2;
  end
  var logic        _GEN_6 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_6 <= 1'h0;
    else
      _GEN_6 <= _GEN_1;
  end
  var logic [7:0]  _GEN_7 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_7 <= 8'h0;
    else
      _GEN_7 <= _GEN_4;
  end
  var logic [7:0]  _GEN_8 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_8 <= 8'h0;
    else
      _GEN_8 <= _GEN_3;
  end
  wire             _GEN_9 = _GEN_6 & _GEN_5 < count;
  wire             _GEN_10 = go & _GEN_9;
  assign _GEN_4 = _GEN_6 ? {8{_GEN_10}} & wd | _GEN_7 : wd;
  assign _GEN_3 =
    _GEN_6
      ? (_GEN_10 ? (_GEN_8 | wd_xz) & (_GEN_8 | ~_GEN_7) & (wd_xz | ~wd) : _GEN_8)
      : wd_xz;
  wire      [63:0] _GEN_11 = _GEN_5 + 64'h1;
  wire             _GEN_12 = go & _GEN_9;
  wire             _GEN_13 = _GEN_12 & stop;
  wire             _GEN_14 = _GEN_12 & _GEN_11 == count | _GEN_13;
  assign _GEN_2 = _GEN_12 ? (_GEN_13 ? count : _GEN_11) : 64'h0;
  var logic        _GEN_15 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_15 <= 1'h0;
    else
      _GEN_15 <= _GEN_14;
  end
  assign _GEN_1 = go & (~_GEN_6 | ~_GEN_14);
  var logic [7:0]  _GEN_16 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_16 <= 8'h0;
    else
      _GEN_16 <= _GEN_0;
  end
  var logic [7:0]  _GEN_17 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_17 <= 8'h0;
    else
      _GEN_17 <= _GEN;
  end
  assign _GEN_0 = _GEN_15 ? _GEN_7 : _GEN_16;
  assign _GEN = _GEN_15 ? _GEN_8 : _GEN_17;
  var logic [7:0]  _GEN_18 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_18 <= 8'h0;
    else
      _GEN_18 <= go ? _GEN_7 : wd;
  end
  var logic [7:0]  _GEN_19 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_19 <= 8'h0;
    else
      _GEN_19 <= go ? _GEN_8 : ({8{go}} | (wd_xz | wd) & (wd_xz | wd)) & wd_xz;
  end
  assign out = _GEN_18;
  assign out_xz = _GEN_19;
endmodule
module LoopInBranch(
  input  [63:0] count,
  input         go,
                stop,
  input  [7:0]  wd,
  input         clk,
                rst,
  output [7:0]  out
);
  wire             _GEN;
  wire      [63:0] _GEN_0;
  wire      [7:0]  _GEN_1;
  var logic [63:0] _GEN_2 = 64'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_2 <= 64'h0;
    else
      _GEN_2 <= _GEN_0;
  end
  var logic        _GEN_3 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_3 <= 1'h0;
    else
      _GEN_3 <= _GEN;
  end
  var logic [7:0]  _GEN_4 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_4 <= 8'h0;
    else
      _GEN_4 <= _GEN_1;
  end
  wire             _GEN_5 = _GEN_3 & _GEN_2 < count;
  assign _GEN_1 = _GEN_3 ? (go & _GEN_5 ? _GEN_4 + wd : _GEN_4) : 8'h0;
  wire      [63:0] _GEN_6 = _GEN_2 + 64'h1;
  wire             _GEN_7 = go & _GEN_5;
  wire             _GEN_8 = _GEN_7 & stop;
  wire             _GEN_9 = _GEN_7 & _GEN_6 == count | _GEN_8;
  assign _GEN_0 = _GEN_7 ? (_GEN_8 ? count : _GEN_6) : 64'h0;
  var logic        _GEN_10 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_10 <= 1'h0;
    else
      _GEN_10 <= _GEN_9;
  end
  assign _GEN = go & (~_GEN_3 | ~_GEN_9);
  var logic [7:0]  reg_0 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      reg_0 <= 8'h0;
    else if (_GEN_10)
      reg_0 <= _GEN_4;
  end
  var logic [7:0]  _GEN_11 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_11 <= 8'h0;
    else
      _GEN_11 <= go ? _GEN_4 : ~go ? wd : 8'h0;
  end
  assign out = _GEN_11;
endmodule
