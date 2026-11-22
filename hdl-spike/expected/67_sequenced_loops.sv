module SequencedLoops(
  input  [63:0] n,
                m,
  input  [7:0]  wd,
  input         en,
                clk,
                rst,
  output [7:0]  out
);
  wire      [7:0]  _GEN;
  wire             _GEN_0;
  wire      [63:0] _GEN_1;
  wire      [7:0]  _GEN_2;
  wire             _GEN_3;
  wire             _GEN_4;
  wire             _GEN_5;
  wire             _GEN_6;
  wire             _GEN_7;
  wire             _GEN_8;
  wire             _GEN_9;
  wire             _GEN_10;
  wire      [63:0] _GEN_11;
  var logic [63:0] _GEN_12 = 64'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_12 <= 64'h0;
    else
      _GEN_12 <= _GEN_11;
  end
  wire             _GEN_13 = _GEN_12 < n;
  var logic [7:0]  mem_0_0 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_0 <= 8'h0;
    else if (_GEN_10)
      mem_0_0 <= wd;
  end
  var logic [7:0]  mem_0_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_1 <= 8'h0;
    else if (_GEN_9)
      mem_0_1 <= wd;
  end
  var logic [7:0]  mem_0_2 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_2 <= 8'h0;
    else if (_GEN_8)
      mem_0_2 <= wd;
  end
  var logic [7:0]  mem_0_3 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_3 <= 8'h0;
    else if (_GEN_7)
      mem_0_3 <= wd;
  end
  var logic [7:0]  mem_0_4 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_4 <= 8'h0;
    else if (_GEN_6)
      mem_0_4 <= wd;
  end
  var logic [7:0]  mem_0_5 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_5 <= 8'h0;
    else if (_GEN_5)
      mem_0_5 <= wd;
  end
  var logic [7:0]  mem_0_6 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_6 <= 8'h0;
    else if (_GEN_4)
      mem_0_6 <= wd;
  end
  var logic [7:0]  mem_0_7 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_7 <= 8'h0;
    else if (_GEN_3)
      mem_0_7 <= wd;
  end
  var logic [7:0]  _GEN_14 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_14 <= 8'h0;
    else
      _GEN_14 <= _GEN_2;
  end
  wire      [63:0] _GEN_15 = _GEN_12 + 64'h1;
  assign _GEN_11 = _GEN_13 ? _GEN_15 : _GEN_12;
  var logic        _GEN_16 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_16 <= 1'h0;
    else
      _GEN_16 <= _GEN_13 & _GEN_15 == n;
  end
  var logic [63:0] _GEN_17 = 64'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_17 <= 64'h0;
    else
      _GEN_17 <= _GEN_1;
  end
  var logic        _GEN_18 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_18 <= 1'h0;
    else
      _GEN_18 <= _GEN_0;
  end
  wire             _GEN_19 = _GEN_18 & _GEN_17 < m;
  assign _GEN_10 = _GEN_13 & en & _GEN_12 == 64'h0 | _GEN_19 & en & _GEN_17 == 64'h0;
  assign _GEN_9 = _GEN_13 & en & _GEN_12 == 64'h1 | _GEN_19 & en & _GEN_17 == 64'h1;
  assign _GEN_8 = _GEN_13 & en & _GEN_12 == 64'h2 | _GEN_19 & en & _GEN_17 == 64'h2;
  assign _GEN_7 = _GEN_13 & en & _GEN_12 == 64'h3 | _GEN_19 & en & _GEN_17 == 64'h3;
  assign _GEN_6 = _GEN_13 & en & _GEN_12 == 64'h4 | _GEN_19 & en & _GEN_17 == 64'h4;
  assign _GEN_5 = _GEN_13 & en & _GEN_12 == 64'h5 | _GEN_19 & en & _GEN_17 == 64'h5;
  assign _GEN_4 = _GEN_13 & en & _GEN_12 == 64'h6 | _GEN_19 & en & _GEN_17 == 64'h6;
  assign _GEN_3 = _GEN_13 & en & _GEN_12 == 64'h7 | _GEN_19 & en & _GEN_17 == 64'h7;
  assign _GEN_2 = _GEN_19 | _GEN_13 ? wd : _GEN_14;
  wire      [63:0] _GEN_20 = _GEN_17 + 64'h1;
  wire             _GEN_21 = _GEN_19 & _GEN_20 == m;
  assign _GEN_1 = _GEN_19 ? _GEN_20 : 64'h0;
  assign _GEN_0 = _GEN_16 | ~_GEN_21 & _GEN_18;
  var logic        _GEN_22 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_22 <= 1'h0;
    else
      _GEN_22 <= _GEN_21;
  end
  var logic [7:0]  reg_2 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      reg_2 <= 8'h0;
    else if (_GEN_22)
      reg_2 <= _GEN;
  end
  assign _GEN = reg_2 + 8'h1;
  assign out = _GEN_14;
endmodule
module SequencedWhile(
  input  [63:0] n,
                m,
  input  [7:0]  wd,
  input         en,
                clk,
                rst,
  output [7:0]  out
);
  wire      [7:0]  _GEN;
  wire             _GEN_0;
  wire      [63:0] _GEN_1;
  wire      [7:0]  _GEN_2;
  wire             _GEN_3;
  wire             _GEN_4;
  wire             _GEN_5;
  wire             _GEN_6;
  wire             _GEN_7;
  wire             _GEN_8;
  wire             _GEN_9;
  wire             _GEN_10;
  wire      [63:0] _GEN_11;
  var logic [63:0] _GEN_12 = 64'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_12 <= 64'h0;
    else
      _GEN_12 <= _GEN_11;
  end
  wire             _GEN_13 = _GEN_12 < n;
  var logic [7:0]  mem_0_0 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_0 <= 8'h0;
    else if (_GEN_10)
      mem_0_0 <= wd;
  end
  var logic [7:0]  mem_0_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_1 <= 8'h0;
    else if (_GEN_9)
      mem_0_1 <= wd;
  end
  var logic [7:0]  mem_0_2 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_2 <= 8'h0;
    else if (_GEN_8)
      mem_0_2 <= wd;
  end
  var logic [7:0]  mem_0_3 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_3 <= 8'h0;
    else if (_GEN_7)
      mem_0_3 <= wd;
  end
  var logic [7:0]  mem_0_4 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_4 <= 8'h0;
    else if (_GEN_6)
      mem_0_4 <= wd;
  end
  var logic [7:0]  mem_0_5 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_5 <= 8'h0;
    else if (_GEN_5)
      mem_0_5 <= wd;
  end
  var logic [7:0]  mem_0_6 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_6 <= 8'h0;
    else if (_GEN_4)
      mem_0_6 <= wd;
  end
  var logic [7:0]  mem_0_7 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_7 <= 8'h0;
    else if (_GEN_3)
      mem_0_7 <= wd;
  end
  var logic [7:0]  _GEN_14 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_14 <= 8'h0;
    else
      _GEN_14 <= _GEN_2;
  end
  wire      [63:0] _GEN_15 = _GEN_12 + 64'h1;
  assign _GEN_11 = _GEN_13 ? _GEN_15 : _GEN_12;
  var logic        _GEN_16 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_16 <= 1'h0;
    else
      _GEN_16 <= _GEN_13 & _GEN_15 == n;
  end
  var logic [63:0] _GEN_17 = 64'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_17 <= 64'h0;
    else
      _GEN_17 <= _GEN_1;
  end
  var logic        _GEN_18 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_18 <= 1'h0;
    else
      _GEN_18 <= _GEN_0;
  end
  wire             _GEN_19 = _GEN_18 & _GEN_17 < m;
  assign _GEN_10 = _GEN_13 & en & _GEN_12 == 64'h0 | _GEN_19 & en & _GEN_17 == 64'h0;
  assign _GEN_9 = _GEN_13 & en & _GEN_12 == 64'h1 | _GEN_19 & en & _GEN_17 == 64'h1;
  assign _GEN_8 = _GEN_13 & en & _GEN_12 == 64'h2 | _GEN_19 & en & _GEN_17 == 64'h2;
  assign _GEN_7 = _GEN_13 & en & _GEN_12 == 64'h3 | _GEN_19 & en & _GEN_17 == 64'h3;
  assign _GEN_6 = _GEN_13 & en & _GEN_12 == 64'h4 | _GEN_19 & en & _GEN_17 == 64'h4;
  assign _GEN_5 = _GEN_13 & en & _GEN_12 == 64'h5 | _GEN_19 & en & _GEN_17 == 64'h5;
  assign _GEN_4 = _GEN_13 & en & _GEN_12 == 64'h6 | _GEN_19 & en & _GEN_17 == 64'h6;
  assign _GEN_3 = _GEN_13 & en & _GEN_12 == 64'h7 | _GEN_19 & en & _GEN_17 == 64'h7;
  assign _GEN_2 = _GEN_19 | _GEN_13 ? wd : _GEN_14;
  wire      [63:0] _GEN_20 = _GEN_17 + 64'h1;
  wire             _GEN_21 = _GEN_19 & _GEN_20 == m;
  assign _GEN_1 = _GEN_19 ? _GEN_20 : 64'h0;
  assign _GEN_0 = _GEN_16 | ~_GEN_21 & _GEN_18;
  var logic        _GEN_22 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_22 <= 1'h0;
    else
      _GEN_22 <= _GEN_21;
  end
  var logic [7:0]  reg_2 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      reg_2 <= 8'h0;
    else if (_GEN_22)
      reg_2 <= _GEN;
  end
  assign _GEN = reg_2 + 8'h1;
  assign out = _GEN_14;
endmodule
