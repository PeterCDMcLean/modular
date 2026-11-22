module SharedLogicAccum(
  input  [63:0] n,
                m,
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
  wire      [63:0] _GEN_4;
  wire             _GEN_5;
  wire             _GEN_6;
  wire             _GEN_7;
  wire      [63:0] _GEN_8;
  wire      [7:0]  _GEN_9;
  wire      [7:0]  _GEN_10;
  var logic [63:0] _GEN_11 = 64'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_11 <= 64'h0;
    else
      _GEN_11 <= _GEN_4;
  end
  var logic        _GEN_12 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_12 <= 1'h0;
    else
      _GEN_12 <= _GEN_5;
  end
  var logic [7:0]  _GEN_13 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_13 <= 8'h0;
    else
      _GEN_13 <= _GEN_3;
  end
  var logic [7:0]  _GEN_14 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_14 <= 8'h0;
    else
      _GEN_14 <= _GEN_2;
  end
  wire             _GEN_15 = _GEN_12 & _GEN_11 < n;
  wire      [63:0] _GEN_16 = _GEN_11 + 64'h1;
  var logic        _GEN_17 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_17 <= 1'h0;
    else
      _GEN_17 <= _GEN_15 & _GEN_16 == n;
  end
  var logic [63:0] _GEN_18 = 64'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_18 <= 64'h0;
    else
      _GEN_18 <= _GEN_8;
  end
  var logic        _GEN_19 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_19 <= 1'h0;
    else
      _GEN_19 <= _GEN_7;
  end
  var logic        _GEN_20 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_20 <= 1'h0;
    else
      _GEN_20 <= _GEN_6;
  end
  var logic [7:0]  _GEN_21 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_21 <= 8'h0;
    else
      _GEN_21 <= _GEN_10;
  end
  var logic [7:0]  _GEN_22 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_22 <= 8'h0;
    else
      _GEN_22 <= _GEN_9;
  end
  wire             _GEN_23 = _GEN_19 & _GEN_20 & _GEN_18 < m;
  assign _GEN_10 = _GEN_20 ? {8{_GEN_23}} & wd | _GEN_21 : _GEN_13;
  assign _GEN_9 =
    _GEN_20
      ? (_GEN_23 ? (_GEN_22 | wd_xz) & (_GEN_22 | ~_GEN_21) & (wd_xz | ~wd) : _GEN_22)
      : _GEN_14;
  wire      [63:0] _GEN_24 = _GEN_18 + 64'h1;
  wire             _GEN_25 = _GEN_23 & _GEN_24 == m;
  assign _GEN_8 = _GEN_23 ? _GEN_24 : 64'h0;
  assign _GEN_7 = _GEN_17 | ~_GEN_25 & _GEN_19;
  var logic        _GEN_26 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_26 <= 1'h0;
    else
      _GEN_26 <= _GEN_25;
  end
  assign _GEN_6 = _GEN_19 & (~_GEN_20 | ~_GEN_25);
  assign _GEN_5 = ~_GEN_26;
  assign _GEN_4 = _GEN_26 ? 64'h0 : _GEN_15 ? _GEN_16 : _GEN_11;
  assign _GEN_3 = _GEN_26 | ~_GEN_12 ? wd : {8{_GEN_15}} & wd | _GEN_13;
  assign _GEN_2 =
    _GEN_26 | ~_GEN_12
      ? wd_xz
      : _GEN_15 ? (_GEN_14 | wd_xz) & (_GEN_14 | ~_GEN_13) & (wd_xz | ~wd) : _GEN_14;
  var logic [7:0]  _GEN_27 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_27 <= 8'h0;
    else
      _GEN_27 <= _GEN_1;
  end
  var logic [7:0]  _GEN_28 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_28 <= 8'h0;
    else
      _GEN_28 <= _GEN_0;
  end
  assign _GEN_1 = _GEN_26 ? _GEN_21 : _GEN_27;
  assign _GEN_0 = _GEN_26 ? _GEN_22 : _GEN_28;
  var logic [7:0]  reg_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      reg_1 <= 8'h0;
    else if (_GEN_26)
      reg_1 <= _GEN;
  end
  assign _GEN = reg_1 + 8'h1;
  assign out = _GEN_27;
  assign out_xz = _GEN_28;
endmodule
