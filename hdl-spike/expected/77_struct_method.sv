module LogicStructMethodCarry(
  input  [63:0] count,
  input  [7:0]  init,
                init_xz,
                wd,
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
  wire      [3:0]  _GEN_3;
  wire      [7:0]  _GEN_4;
  wire      [7:0]  _GEN_5;
  var logic [63:0] _GEN_6 = 64'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_6 <= 64'h0;
    else
      _GEN_6 <= _GEN_2;
  end
  var logic        _GEN_7 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_7 <= 1'h0;
    else
      _GEN_7 <= _GEN_1;
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
  var logic [3:0]  _GEN_10 = 4'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_10 <= 4'h0;
    else
      _GEN_10 <= _GEN_3;
  end
  wire             _GEN_11 = _GEN_7 & _GEN_6 < count;
  assign _GEN_5 = _GEN_7 ? {8{_GEN_11}} & wd | _GEN_8 : init;
  assign _GEN_4 =
    _GEN_7
      ? (_GEN_11 ? (_GEN_9 | wd_xz) & (_GEN_9 | ~_GEN_8) & (wd_xz | ~wd) : _GEN_9)
      : init_xz;
  assign _GEN_3 = _GEN_7 ? (_GEN_11 ? _GEN_10 + 4'h1 : _GEN_10) : 4'h5;
  wire      [63:0] _GEN_12 = _GEN_6 + 64'h1;
  wire             _GEN_13 = _GEN_11 & _GEN_12 == count;
  assign _GEN_2 = _GEN_11 ? _GEN_12 : 64'h0;
  var logic        _GEN_14 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_14 <= 1'h0;
    else
      _GEN_14 <= _GEN_13;
  end
  assign _GEN_1 = ~_GEN_7 | ~_GEN_13;
  var logic [7:0]  _GEN_15 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_15 <= 8'h0;
    else
      _GEN_15 <= _GEN_0;
  end
  var logic [7:0]  _GEN_16 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_16 <= 8'h0;
    else
      _GEN_16 <= _GEN;
  end
  assign _GEN_0 = _GEN_14 ? _GEN_8 : _GEN_15;
  assign _GEN = _GEN_14 ? _GEN_9 : _GEN_16;
  var logic [3:0]  reg_1 = 4'h0;
  always @(posedge clk) begin
    if (rst)
      reg_1 <= 4'h0;
    else if (_GEN_14)
      reg_1 <= _GEN_10;
  end
  assign out = _GEN_15;
  assign out_xz = _GEN_16;
endmodule
module StructMethodCarry(
  input  [63:0] count,
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
      _GEN_5 <= _GEN_2;
  end
  var logic [7:0]  _GEN_6 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_6 <= 8'h0;
    else
      _GEN_6 <= _GEN_1;
  end
  wire             _GEN_7 = _GEN_4 & _GEN_3 < count;
  assign _GEN_2 = _GEN_4 ? (_GEN_7 ? _GEN_5 + wd : _GEN_5) : wd;
  assign _GEN_1 = _GEN_4 ? (_GEN_7 ? _GEN_6 + 8'h3 : _GEN_6) : 8'h2;
  wire      [63:0] _GEN_8 = _GEN_3 + 64'h1;
  wire             _GEN_9 = _GEN_7 & _GEN_8 == count;
  assign _GEN_0 = _GEN_7 ? _GEN_8 : 64'h0;
  var logic        _GEN_10 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_10 <= 1'h0;
    else
      _GEN_10 <= _GEN_9;
  end
  assign _GEN = ~_GEN_4 | ~_GEN_9;
  var logic [7:0]  reg_0 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      reg_0 <= 8'h0;
    else if (_GEN_10)
      reg_0 <= _GEN_5;
  end
  var logic [7:0]  reg_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      reg_1 <= 8'h0;
    else if (_GEN_10)
      reg_1 <= _GEN_6;
  end
  assign out = reg_0;
endmodule
