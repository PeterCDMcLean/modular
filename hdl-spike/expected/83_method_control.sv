module ConditionalMethodCarry(
  input  [63:0] count,
  input         en,
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
  wire             _GEN_8 = _GEN_7 & en;
  wire      [7:0]  _GEN_9 = _GEN_8 ? _GEN_5 + wd : _GEN_5;
  assign _GEN_2 = _GEN_4 ? (_GEN_7 & ~en ? _GEN_9 - 8'h1 : _GEN_9) : wd;
  assign _GEN_1 = _GEN_4 ? (_GEN_8 ? _GEN_6 + 8'h1 : _GEN_6) : 8'h0;
  wire      [63:0] _GEN_10 = _GEN_3 + 64'h1;
  wire             _GEN_11 = _GEN_7 & _GEN_10 == count;
  assign _GEN_0 = _GEN_7 ? _GEN_10 : 64'h0;
  var logic        _GEN_12 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_12 <= 1'h0;
    else
      _GEN_12 <= _GEN_11;
  end
  assign _GEN = ~_GEN_4 | ~_GEN_11;
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
      reg_1 <= _GEN_6;
  end
  assign out = reg_0;
endmodule
module LocalStepCarry(
  input  [63:0] count,
  input         en,
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
  wire      [7:0]  _GEN_8 = wd + 8'h2;
  wire             _GEN_9 = _GEN_7 & en;
  wire      [7:0]  _GEN_10 = _GEN_9 ? _GEN_5 + _GEN_8 : _GEN_5;
  assign _GEN_2 = _GEN_4 ? (_GEN_7 & ~en ? _GEN_10 - _GEN_8 : _GEN_10) : wd;
  assign _GEN_1 = _GEN_4 ? (_GEN_9 ? _GEN_6 + 8'h1 : _GEN_6) : 8'h0;
  wire      [63:0] _GEN_11 = _GEN_3 + 64'h1;
  wire             _GEN_12 = _GEN_7 & _GEN_11 == count;
  assign _GEN_0 = _GEN_7 ? _GEN_11 : 64'h0;
  var logic        _GEN_13 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_13 <= 1'h0;
    else
      _GEN_13 <= _GEN_12;
  end
  assign _GEN = ~_GEN_4 | ~_GEN_12;
  var logic [7:0]  reg_0 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      reg_0 <= 8'h0;
    else if (_GEN_13)
      reg_0 <= _GEN_5;
  end
  var logic [7:0]  reg_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      reg_1 <= 8'h0;
    else if (_GEN_13)
      reg_1 <= _GEN_6;
  end
  assign out = reg_0;
endmodule
