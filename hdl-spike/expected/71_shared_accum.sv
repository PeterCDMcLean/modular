module SharedAccum(
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
  wire      [7:0]  _GEN_5;
  var logic [63:0] _GEN_6 = 64'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_6 <= 64'h0;
    else
      _GEN_6 <= _GEN_4;
  end
  var logic        _GEN_7 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_7 <= 1'h0;
    else
      _GEN_7 <= 1'h1;
  end
  var logic [7:0]  _GEN_8 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_8 <= 8'h0;
    else
      _GEN_8 <= _GEN_5;
  end
  wire             _GEN_9 = _GEN_7 & _GEN_6 < n;
  assign _GEN_5 = _GEN_7 ? (_GEN_9 ? _GEN_8 + wd : _GEN_8) : 8'h0;
  wire      [63:0] _GEN_10 = _GEN_6 + 64'h1;
  assign _GEN_4 = _GEN_9 ? _GEN_10 : _GEN_6;
  var logic        _GEN_11 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_11 <= 1'h0;
    else
      _GEN_11 <= _GEN_9 & _GEN_10 == n;
  end
  var logic [63:0] _GEN_12 = 64'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_12 <= 64'h0;
    else
      _GEN_12 <= _GEN_2;
  end
  var logic        _GEN_13 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_13 <= 1'h0;
    else
      _GEN_13 <= _GEN_1;
  end
  var logic        _GEN_14 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_14 <= 1'h0;
    else
      _GEN_14 <= _GEN_0;
  end
  var logic [7:0]  _GEN_15 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_15 <= 8'h0;
    else
      _GEN_15 <= _GEN_3;
  end
  wire             _GEN_16 = _GEN_13 & _GEN_14 & _GEN_12 < m;
  assign _GEN_3 = _GEN_14 ? (_GEN_16 ? _GEN_15 + wd : _GEN_15) : _GEN_8;
  wire      [63:0] _GEN_17 = _GEN_12 + 64'h1;
  wire             _GEN_18 = _GEN_16 & _GEN_17 == m;
  assign _GEN_2 = _GEN_16 ? _GEN_17 : 64'h0;
  assign _GEN_1 = _GEN_11 | ~_GEN_18 & _GEN_13;
  var logic        _GEN_19 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_19 <= 1'h0;
    else
      _GEN_19 <= _GEN_18;
  end
  assign _GEN_0 = _GEN_13 & (~_GEN_14 | ~_GEN_18);
  var logic [7:0]  reg_0 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      reg_0 <= 8'h0;
    else if (_GEN_19)
      reg_0 <= _GEN_15;
  end
  var logic [7:0]  reg_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      reg_1 <= 8'h0;
    else if (_GEN_19)
      reg_1 <= _GEN;
  end
  assign _GEN = reg_1 + 8'h1;
  assign out = reg_0;
endmodule
