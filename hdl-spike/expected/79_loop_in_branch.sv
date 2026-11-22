module LogicLoopInBranch(
  input  wire [63:0] count,
  input  wire        go,
  input  wire        stop,
  input  wire [7:0]  wd,
  input  wire [7:0]  wd_xz,
  input  wire        clk,
  input  wire        rst,
  output wire [7:0]  out,
  output wire [7:0]  out_xz
);
  wire      [7:0]  _GEN;
  wire      [7:0]  _GEN_0;
  wire             _GEN_1;
  wire      [63:0] _GEN_2;
  wire      [7:0]  _GEN_3;
  wire      [7:0]  _GEN_4;
  var logic [63:0] _GEN_5 = 64'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_5 <= 64'h0;
    end
    else begin
      _GEN_5 <= _GEN_2;
    end
  end
  var logic        _GEN_6 = 1'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_6 <= 1'h0;
    end
    else begin
      _GEN_6 <= _GEN_1;
    end
  end
  var logic [7:0]  _GEN_7 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_7 <= 8'h0;
    end
    else begin
      _GEN_7 <= _GEN_4;
    end
  end
  var logic [7:0]  _GEN_8 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_8 <= 8'h0;
    end
    else begin
      _GEN_8 <= _GEN_3;
    end
  end
  wire             _GEN_9 = _GEN_6 & _GEN_5 < count;
  wire             _GEN_10 = go & _GEN_9;
  assign _GEN_4 = _GEN_6 ? {8{_GEN_10}} & wd | _GEN_7 : wd;
  assign _GEN_3 =
    _GEN_6
      ? (_GEN_10 ? (_GEN_8 | wd_xz) & (_GEN_8 | ~_GEN_7) & (wd_xz | ~wd) : _GEN_8)
      : wd_xz;
  wire      [63:0] _GEN_11 = _GEN_5 + 64'h1;
  wire             _GEN_12 = go & _GEN_9;
  wire             _GEN_13 = _GEN_12 & stop;
  wire             _GEN_14 = _GEN_12 & _GEN_11 == count | _GEN_13;
  assign _GEN_2 = _GEN_12 ? (_GEN_13 ? count : _GEN_11) : 64'h0;
  var logic        _GEN_15 = 1'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_15 <= 1'h0;
    end
    else begin
      _GEN_15 <= _GEN_14;
    end
  end
  assign _GEN_1 = go & (~_GEN_6 | ~_GEN_14);
  var logic [7:0]  _GEN_16 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_16 <= 8'h0;
    end
    else begin
      _GEN_16 <= _GEN_0;
    end
  end
  var logic [7:0]  _GEN_17 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_17 <= 8'h0;
    end
    else begin
      _GEN_17 <= _GEN;
    end
  end
  assign _GEN_0 = _GEN_15 ? _GEN_7 : _GEN_16;
  assign _GEN = _GEN_15 ? _GEN_8 : _GEN_17;
  var logic [7:0]  _GEN_18 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_18 <= 8'h0;
    end
    else begin
      _GEN_18 <= go ? _GEN_7 : wd;
    end
  end
  var logic [7:0]  _GEN_19 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_19 <= 8'h0;
    end
    else begin
      _GEN_19 <= go ? _GEN_8 : ({8{go}} | (wd_xz | wd) & (wd_xz | wd)) & wd_xz;
    end
  end
  assign out = _GEN_18;
  assign out_xz = _GEN_19;
endmodule
module LoopInBranch(
  input  wire [63:0] count,
  input  wire        go,
  input  wire        stop,
  input  wire [7:0]  wd,
  input  wire        clk,
  input  wire        rst,
  output wire [7:0]  out
);
  wire             _GEN;
  wire      [63:0] _GEN_0;
  wire      [7:0]  _GEN_1;
  var logic [63:0] _GEN_2 = 64'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_2 <= 64'h0;
    end
    else begin
      _GEN_2 <= _GEN_0;
    end
  end
  var logic        _GEN_3 = 1'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_3 <= 1'h0;
    end
    else begin
      _GEN_3 <= _GEN;
    end
  end
  var logic [7:0]  _GEN_4 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_4 <= 8'h0;
    end
    else begin
      _GEN_4 <= _GEN_1;
    end
  end
  wire             _GEN_5 = _GEN_3 & _GEN_2 < count;
  assign _GEN_1 = _GEN_3 ? (go & _GEN_5 ? _GEN_4 + wd : _GEN_4) : 8'h0;
  wire      [63:0] _GEN_6 = _GEN_2 + 64'h1;
  wire             _GEN_7 = go & _GEN_5;
  wire             _GEN_8 = _GEN_7 & stop;
  wire             _GEN_9 = _GEN_7 & _GEN_6 == count | _GEN_8;
  assign _GEN_0 = _GEN_7 ? (_GEN_8 ? count : _GEN_6) : 64'h0;
  var logic        _GEN_10 = 1'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_10 <= 1'h0;
    end
    else begin
      _GEN_10 <= _GEN_9;
    end
  end
  assign _GEN = go & (~_GEN_3 | ~_GEN_9);
  var logic [7:0]  reg_0 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      reg_0 <= 8'h0;
    end
    else if (_GEN_10) begin
      reg_0 <= _GEN_4;
    end
  end
  var logic [7:0]  _GEN_11 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_11 <= 8'h0;
    end
    else begin
      _GEN_11 <= go ? _GEN_4 : ~go ? wd : 8'h0;
    end
  end
  assign out = _GEN_11;
endmodule
