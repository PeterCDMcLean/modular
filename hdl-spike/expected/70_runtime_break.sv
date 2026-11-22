module RuntimeBreak(
  input  [63:0] count,
  input         stop,
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
  assign _GEN_2 = _GEN_4 ? (_GEN_6 ? _GEN_5 + wd : _GEN_5) : 8'h0;
  wire      [63:0] _GEN_7 = _GEN_3 + 64'h1;
  wire             _GEN_8 = _GEN_6 & stop;
  wire             _GEN_9 = _GEN_6 & _GEN_7 == count | _GEN_8;
  assign _GEN_1 = _GEN_6 ? (_GEN_8 ? count : _GEN_7) : 64'h0;
  var logic        _GEN_10 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_10 <= 1'h0;
    else
      _GEN_10 <= _GEN_9;
  end
  assign _GEN_0 = ~_GEN_4 | ~_GEN_9;
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
      reg_1 <= _GEN;
  end
  assign _GEN = reg_1 + 8'h1;
  assign out = reg_0;
endmodule
module RuntimeWhileBreak(
  input  [63:0] count,
  input         stop,
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
  assign _GEN_2 = _GEN_4 ? (_GEN_6 ? _GEN_5 + wd : _GEN_5) : 8'h0;
  wire      [63:0] _GEN_7 = _GEN_3 + 64'h1;
  wire             _GEN_8 = _GEN_6 & stop;
  wire             _GEN_9 = _GEN_6 & _GEN_7 == count | _GEN_8;
  assign _GEN_1 = _GEN_6 ? (_GEN_8 ? count : _GEN_7) : 64'h0;
  var logic        _GEN_10 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_10 <= 1'h0;
    else
      _GEN_10 <= _GEN_9;
  end
  assign _GEN_0 = ~_GEN_4 | ~_GEN_9;
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
      reg_1 <= _GEN;
  end
  assign _GEN = reg_1 + 8'h1;
  assign out = reg_0;
endmodule
