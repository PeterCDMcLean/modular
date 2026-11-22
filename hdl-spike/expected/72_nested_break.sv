module ElseIfBreak(
  input  wire [63:0] count,
  input  wire        a,
  input  wire        b,
  input  wire [7:0]  wd,
  input  wire        clk,
  input  wire        rst,
  output wire [7:0]  out
);
  wire             _GEN;
  wire      [63:0] _GEN_0;
  wire      [7:0]  _GEN_1;
  wire      [7:0]  _GEN_2;
  var logic [63:0] _GEN_3 = 64'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_3 <= 64'h0;
    end
    else begin
      _GEN_3 <= _GEN_0;
    end
  end
  var logic        _GEN_4 = 1'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_4 <= 1'h0;
    end
    else begin
      _GEN_4 <= _GEN;
    end
  end
  var logic [7:0]  _GEN_5 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_5 <= 8'h0;
    end
    else begin
      _GEN_5 <= _GEN_1;
    end
  end
  wire             _GEN_6 = _GEN_4 & _GEN_3 < count;
  var logic [7:0]  reg_0 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      reg_0 <= 8'h0;
    end
    else if (_GEN_6 & ~a) begin
      reg_0 <= _GEN_2;
    end
  end
  assign _GEN_2 = reg_0 + 8'h1;
  assign _GEN_1 = _GEN_4 ? (_GEN_6 & a ? _GEN_5 + wd : _GEN_5) : 8'h0;
  wire      [63:0] _GEN_7 = _GEN_3 + 64'h1;
  wire             _GEN_8 = _GEN_6 & ~a & b;
  wire             _GEN_9 = _GEN_6 & _GEN_7 == count | _GEN_8;
  assign _GEN_0 = _GEN_6 ? (_GEN_8 ? count : _GEN_7) : 64'h0;
  var logic        _GEN_10 = 1'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_10 <= 1'h0;
    end
    else begin
      _GEN_10 <= _GEN_9;
    end
  end
  assign _GEN = ~_GEN_4 | ~_GEN_9;
  var logic [7:0]  reg_1 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      reg_1 <= 8'h0;
    end
    else if (_GEN_10) begin
      reg_1 <= _GEN_5;
    end
  end
  assign out = reg_1;
endmodule
module NestedIfBreak(
  input  wire [63:0] count,
  input  wire        a,
  input  wire        b,
  input  wire [7:0]  wd,
  input  wire        clk,
  input  wire        rst,
  output wire [7:0]  out
);
  wire             _GEN;
  wire      [63:0] _GEN_0;
  wire      [7:0]  _GEN_1;
  wire      [7:0]  _GEN_2;
  var logic [63:0] _GEN_3 = 64'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_3 <= 64'h0;
    end
    else begin
      _GEN_3 <= _GEN_0;
    end
  end
  var logic        _GEN_4 = 1'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_4 <= 1'h0;
    end
    else begin
      _GEN_4 <= _GEN;
    end
  end
  var logic [7:0]  _GEN_5 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_5 <= 8'h0;
    end
    else begin
      _GEN_5 <= _GEN_1;
    end
  end
  wire             _GEN_6 = _GEN_4 & _GEN_3 < count;
  var logic [7:0]  reg_0 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      reg_0 <= 8'h0;
    end
    else if (_GEN_6 & a) begin
      reg_0 <= _GEN_2;
    end
  end
  assign _GEN_2 = reg_0 + 8'h1;
  assign _GEN_1 = _GEN_4 ? (_GEN_6 ? _GEN_5 + wd : _GEN_5) : 8'h0;
  wire      [63:0] _GEN_7 = _GEN_3 + 64'h1;
  wire             _GEN_8 = _GEN_6 & a & b;
  wire             _GEN_9 = _GEN_6 & _GEN_7 == count | _GEN_8;
  assign _GEN_0 = _GEN_6 ? (_GEN_8 ? count : _GEN_7) : 64'h0;
  var logic        _GEN_10 = 1'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_10 <= 1'h0;
    end
    else begin
      _GEN_10 <= _GEN_9;
    end
  end
  assign _GEN = ~_GEN_4 | ~_GEN_9;
  var logic [7:0]  reg_1 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      reg_1 <= 8'h0;
    end
    else if (_GEN_10) begin
      reg_1 <= _GEN_5;
    end
  end
  assign out = reg_1;
endmodule
module NestedLoopBreak(
  input  wire [63:0] n,
  input  wire [63:0] m,
  input  wire        a,
  input  wire        b,
  input  wire [7:0]  wd,
  input  wire        clk,
  input  wire        rst,
  output wire [7:0]  out
);
  wire             _GEN;
  wire      [63:0] _GEN_0;
  wire      [7:0]  _GEN_1;
  wire      [63:0] _GEN_2;
  wire      [7:0]  _GEN_3;
  var logic [63:0] _GEN_4 = 64'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_4 <= 64'h0;
    end
    else begin
      _GEN_4 <= _GEN_0;
    end
  end
  var logic        _GEN_5 = 1'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_5 <= 1'h0;
    end
    else begin
      _GEN_5 <= _GEN;
    end
  end
  var logic [7:0]  _GEN_6 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_6 <= 8'h0;
    end
    else begin
      _GEN_6 <= _GEN_1;
    end
  end
  var logic [63:0] _GEN_7 = 64'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_7 <= 64'h0;
    end
    else begin
      _GEN_7 <= _GEN_2;
    end
  end
  wire             _GEN_8 = _GEN_5 & _GEN_4 < n & _GEN_7 < m;
  var logic [7:0]  reg_0 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      reg_0 <= 8'h0;
    end
    else if (_GEN_8 & a) begin
      reg_0 <= _GEN_3;
    end
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
    if (rst) begin
      _GEN_14 <= 1'h0;
    end
    else begin
      _GEN_14 <= _GEN_13;
    end
  end
  assign _GEN = ~_GEN_5 | ~_GEN_13;
  var logic [7:0]  reg_1 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      reg_1 <= 8'h0;
    end
    else if (_GEN_14) begin
      reg_1 <= _GEN_6;
    end
  end
  assign out = reg_1;
endmodule
