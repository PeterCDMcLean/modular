module SequencedAccum(
  input  [63:0] n,
                m,
  input  [7:0]  wd,
  input         clk,
                rst,
  output [7:0]  out
);
  wire      [7:0]  _GEN;
  wire             _GEN_0;
  wire             _GEN_1;
  wire      [63:0] _GEN_2;
  wire      [7:0]  _GEN_3;
  wire      [63:0] _GEN_4;
  wire             _GEN_5;
  wire             _GEN_6;
  wire             _GEN_7;
  wire             _GEN_8;
  var logic [63:0] _GEN_9 = 64'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_9 <= 64'h0;
    else
      _GEN_9 <= _GEN_4;
  end
  wire             _GEN_10 = _GEN_9 < n;
  var logic [7:0]  mem_0_0 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_0 <= 8'h0;
    else if (_GEN_8)
      mem_0_0 <= wd;
  end
  var logic [7:0]  mem_0_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_1 <= 8'h0;
    else if (_GEN_7)
      mem_0_1 <= wd;
  end
  var logic [7:0]  mem_0_2 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_2 <= 8'h0;
    else if (_GEN_6)
      mem_0_2 <= wd;
  end
  var logic [7:0]  mem_0_3 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_3 <= 8'h0;
    else if (_GEN_5)
      mem_0_3 <= wd;
  end
  assign _GEN_8 = _GEN_10 & _GEN_9 == 64'h0;
  assign _GEN_7 = _GEN_10 & _GEN_9 == 64'h1;
  assign _GEN_6 = _GEN_10 & _GEN_9 == 64'h2;
  assign _GEN_5 = _GEN_10 & _GEN_9 == 64'h3;
  wire      [63:0] _GEN_11 = _GEN_9 + 64'h1;
  assign _GEN_4 = _GEN_10 ? _GEN_11 : 64'h0;
  var logic        _GEN_12 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_12 <= 1'h0;
    else
      _GEN_12 <= _GEN_10 & _GEN_11 == n;
  end
  var logic [63:0] _GEN_13 = 64'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_13 <= 64'h0;
    else
      _GEN_13 <= _GEN_2;
  end
  var logic        _GEN_14 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_14 <= 1'h0;
    else
      _GEN_14 <= _GEN_1;
  end
  var logic        _GEN_15 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_15 <= 1'h0;
    else
      _GEN_15 <= _GEN_0;
  end
  var logic [7:0]  _GEN_16 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_16 <= 8'h0;
    else
      _GEN_16 <= _GEN_3;
  end
  wire             _GEN_17 = _GEN_14 & _GEN_15 & _GEN_13 < m;
  assign _GEN_3 = _GEN_15 ? (_GEN_17 ? _GEN_16 + wd : _GEN_16) : 8'h0;
  wire      [63:0] _GEN_18 = _GEN_13 + 64'h1;
  wire             _GEN_19 = _GEN_17 & _GEN_18 == m;
  assign _GEN_2 = _GEN_17 ? _GEN_18 : 64'h0;
  assign _GEN_1 = _GEN_12 | ~_GEN_19 & _GEN_14;
  var logic        _GEN_20 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_20 <= 1'h0;
    else
      _GEN_20 <= _GEN_19;
  end
  assign _GEN_0 = _GEN_14 & (~_GEN_15 | ~_GEN_19);
  var logic [7:0]  reg_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      reg_1 <= 8'h0;
    else if (_GEN_20)
      reg_1 <= _GEN_16;
  end
  var logic [7:0]  reg_2 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      reg_2 <= 8'h0;
    else if (_GEN_20)
      reg_2 <= _GEN;
  end
  assign _GEN = reg_2 + 8'h1;
  assign out = reg_1;
endmodule
module SequencedLogicAccum(
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
  wire             _GEN_2;
  wire             _GEN_3;
  wire      [63:0] _GEN_4;
  wire      [7:0]  _GEN_5;
  wire      [7:0]  _GEN_6;
  wire      [63:0] _GEN_7;
  wire      [7:0]  _GEN_8;
  var logic [63:0] _GEN_9 = 64'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_9 <= 64'h0;
    else
      _GEN_9 <= _GEN_7;
  end
  wire             _GEN_10 = _GEN_9 < n;
  var logic [7:0]  reg_0 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      reg_0 <= 8'h0;
    else if (_GEN_10)
      reg_0 <= _GEN_8;
  end
  assign _GEN_8 = reg_0 + 8'h1;
  wire      [63:0] _GEN_11 = _GEN_9 + 64'h1;
  assign _GEN_7 = _GEN_10 ? _GEN_11 : 64'h0;
  var logic        _GEN_12 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_12 <= 1'h0;
    else
      _GEN_12 <= _GEN_10 & _GEN_11 == n;
  end
  var logic [63:0] _GEN_13 = 64'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_13 <= 64'h0;
    else
      _GEN_13 <= _GEN_4;
  end
  var logic        _GEN_14 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_14 <= 1'h0;
    else
      _GEN_14 <= _GEN_3;
  end
  var logic        _GEN_15 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_15 <= 1'h0;
    else
      _GEN_15 <= _GEN_2;
  end
  var logic [7:0]  _GEN_16 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_16 <= 8'h0;
    else
      _GEN_16 <= _GEN_6;
  end
  var logic [7:0]  _GEN_17 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_17 <= 8'h0;
    else
      _GEN_17 <= _GEN_5;
  end
  wire             _GEN_18 = _GEN_14 & _GEN_15 & _GEN_13 < m;
  assign _GEN_6 = _GEN_15 ? {8{_GEN_18}} & wd | _GEN_16 : wd;
  assign _GEN_5 =
    _GEN_15
      ? (_GEN_18 ? (_GEN_17 | wd_xz) & (_GEN_17 | ~_GEN_16) & (wd_xz | ~wd) : _GEN_17)
      : wd_xz;
  wire      [63:0] _GEN_19 = _GEN_13 + 64'h1;
  wire             _GEN_20 = _GEN_18 & _GEN_19 == m;
  assign _GEN_4 = _GEN_18 ? _GEN_19 : 64'h0;
  assign _GEN_3 = _GEN_12 | ~_GEN_20 & _GEN_14;
  var logic        _GEN_21 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_21 <= 1'h0;
    else
      _GEN_21 <= _GEN_20;
  end
  assign _GEN_2 = _GEN_14 & (~_GEN_15 | ~_GEN_20);
  var logic [7:0]  _GEN_22 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_22 <= 8'h0;
    else
      _GEN_22 <= _GEN_1;
  end
  var logic [7:0]  _GEN_23 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_23 <= 8'h0;
    else
      _GEN_23 <= _GEN_0;
  end
  assign _GEN_1 = _GEN_21 ? _GEN_16 : _GEN_22;
  assign _GEN_0 = _GEN_21 ? _GEN_17 : _GEN_23;
  var logic [7:0]  reg_2 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      reg_2 <= 8'h0;
    else if (_GEN_21)
      reg_2 <= _GEN;
  end
  assign _GEN = reg_2 + 8'h1;
  assign out = _GEN_22;
  assign out_xz = _GEN_23;
endmodule
