module RuntimeForLogicAccum(
  input  [63:0] count,
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
  assign _GEN_5 = _GEN_7 ? {8{_GEN_10}} & wd | _GEN_8 : wd;
  assign _GEN_4 =
    _GEN_7
      ? (_GEN_10 ? (_GEN_9 | wd_xz) & (_GEN_9 | ~_GEN_8) & (wd_xz | ~wd) : _GEN_9)
      : wd_xz;
  wire      [63:0] _GEN_11 = _GEN_6 + 64'h1;
  wire             _GEN_12 = _GEN_10 & _GEN_11 == count;
  assign _GEN_3 = _GEN_10 ? _GEN_11 : 64'h0;
  var logic        _GEN_13 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_13 <= 1'h0;
    else
      _GEN_13 <= _GEN_12;
  end
  assign _GEN_2 = ~_GEN_7 | ~_GEN_12;
  var logic [7:0]  _GEN_14 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_14 <= 8'h0;
    else
      _GEN_14 <= _GEN_1;
  end
  var logic [7:0]  _GEN_15 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_15 <= 8'h0;
    else
      _GEN_15 <= _GEN_0;
  end
  assign _GEN_1 = _GEN_13 ? _GEN_8 : _GEN_14;
  assign _GEN_0 = _GEN_13 ? _GEN_9 : _GEN_15;
  var logic [7:0]  reg_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      reg_1 <= 8'h0;
    else if (_GEN_13)
      reg_1 <= _GEN;
  end
  assign _GEN = reg_1 + 8'h1;
  assign out = _GEN_14;
  assign out_xz = _GEN_15;
endmodule
module RuntimeWhileLogicAccum(
  input  [63:0] count,
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
  assign _GEN_5 = _GEN_7 ? {8{_GEN_10}} & wd | _GEN_8 : wd;
  assign _GEN_4 =
    _GEN_7
      ? (_GEN_10 ? (_GEN_9 | wd_xz) & (_GEN_9 | ~_GEN_8) & (wd_xz | ~wd) : _GEN_9)
      : wd_xz;
  wire      [63:0] _GEN_11 = _GEN_6 + 64'h1;
  wire             _GEN_12 = _GEN_10 & _GEN_11 == count;
  assign _GEN_3 = _GEN_10 ? _GEN_11 : 64'h0;
  var logic        _GEN_13 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_13 <= 1'h0;
    else
      _GEN_13 <= _GEN_12;
  end
  assign _GEN_2 = ~_GEN_7 | ~_GEN_12;
  var logic [7:0]  _GEN_14 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_14 <= 8'h0;
    else
      _GEN_14 <= _GEN_1;
  end
  var logic [7:0]  _GEN_15 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_15 <= 8'h0;
    else
      _GEN_15 <= _GEN_0;
  end
  assign _GEN_1 = _GEN_13 ? _GEN_8 : _GEN_14;
  assign _GEN_0 = _GEN_13 ? _GEN_9 : _GEN_15;
  var logic [7:0]  reg_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      reg_1 <= 8'h0;
    else if (_GEN_13)
      reg_1 <= _GEN;
  end
  assign _GEN = reg_1 + 8'h1;
  assign out = _GEN_14;
  assign out_xz = _GEN_15;
endmodule
