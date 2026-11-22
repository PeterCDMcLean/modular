module RuntimeArrayCarry(
  input  [63:0] count,
  input  [7:0]  wd,
  input         clk,
                rst,
  output [7:0]  out
);
  wire      [7:0]  _GEN;
  wire             _GEN_0;
  wire      [63:0] _GEN_1;
  wire      [31:0] _GEN_2;
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
  var logic [31:0] _GEN_5 = 32'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_5 <= 32'h0;
    else
      _GEN_5 <= _GEN_2;
  end
  wire             _GEN_6 = _GEN_4 & _GEN_3 < count;
  wire      [31:0] _GEN_7 = {_GEN_3[28:0], 3'h0};
  assign _GEN_2 =
    _GEN_4
      ? (_GEN_6 ? _GEN_5 & ~(32'hFF << _GEN_7) | {24'h0, wd} << _GEN_7 : _GEN_5)
      : 32'h0;
  wire      [63:0] _GEN_8 = _GEN_3 + 64'h1;
  assign _GEN_1 = _GEN_6 ? _GEN_8 : 64'h0;
  wire             _GEN_9 = _GEN_6 & _GEN_8 == count;
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
      reg_0 <= _GEN_5[7:0];
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
module RuntimeLogicArrayCarry(
  input  [63:0] count,
  input  [31:0] init,
                init_xz,
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
  wire      [31:0] _GEN_4;
  wire      [31:0] _GEN_5;
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
  var logic [31:0] _GEN_8 = 32'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_8 <= 32'h0;
    else
      _GEN_8 <= _GEN_5;
  end
  var logic [31:0] _GEN_9 = 32'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_9 <= 32'h0;
    else
      _GEN_9 <= _GEN_4;
  end
  wire             _GEN_10 = _GEN_7 & _GEN_6 < count;
  wire      [31:0] _GEN_11 = {_GEN_6[28:0], 3'h0};
  wire      [31:0] _GEN_12 = 32'hFF << _GEN_11;
  assign _GEN_5 =
    _GEN_7 ? (_GEN_10 ? _GEN_8 & ~_GEN_12 | {24'h0, wd} << _GEN_11 : _GEN_8) : init;
  assign _GEN_4 =
    _GEN_7 ? (_GEN_10 ? _GEN_9 & ~_GEN_12 | {24'h0, wd_xz} << _GEN_11 : _GEN_9) : init_xz;
  wire      [63:0] _GEN_13 = _GEN_6 + 64'h1;
  assign _GEN_3 = _GEN_10 ? _GEN_13 : 64'h0;
  wire             _GEN_14 = _GEN_10 & _GEN_13 == count;
  var logic        _GEN_15 = 1'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_15 <= 1'h0;
    else
      _GEN_15 <= _GEN_14;
  end
  assign _GEN_2 = ~_GEN_7 | ~_GEN_14;
  var logic [7:0]  _GEN_16 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_16 <= 8'h0;
    else
      _GEN_16 <= _GEN_1;
  end
  var logic [7:0]  _GEN_17 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_17 <= 8'h0;
    else
      _GEN_17 <= _GEN_0;
  end
  assign _GEN_1 = _GEN_15 ? _GEN_8[7:0] : _GEN_16;
  assign _GEN_0 = _GEN_15 ? _GEN_9[7:0] : _GEN_17;
  var logic [7:0]  reg_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      reg_1 <= 8'h0;
    else if (_GEN_15)
      reg_1 <= _GEN;
  end
  assign _GEN = reg_1 + 8'h1;
  assign out = _GEN_16;
  assign out_xz = _GEN_17;
endmodule
