module ConditionalReturnMethod(
  input  wire [63:0] count,
  input  wire        en,
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
      _GEN_5 <= _GEN_2;
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
  wire             _GEN_7 = _GEN_4 & _GEN_3 < count;
  wire      [7:0]  _GEN_8 = _GEN_7 ? _GEN_6 + wd : _GEN_6;
  assign _GEN_2 =
    _GEN_4
      ? (_GEN_7
           ? (_GEN_7 ? _GEN_5 + (_GEN_7 & en ? wd : _GEN_6) : _GEN_5) + _GEN_8
           : _GEN_5)
      : 8'h0;
  assign _GEN_1 = _GEN_4 ? _GEN_8 : wd;
  wire      [63:0] _GEN_9 = _GEN_3 + 64'h1;
  wire             _GEN_10 = _GEN_7 & _GEN_9 == count;
  assign _GEN_0 = _GEN_7 ? _GEN_9 : 64'h0;
  var logic        _GEN_11 = 1'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_11 <= 1'h0;
    end
    else begin
      _GEN_11 <= _GEN_10;
    end
  end
  assign _GEN = ~_GEN_4 | ~_GEN_10;
  var logic [7:0]  reg_0 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      reg_0 <= 8'h0;
    end
    else if (_GEN_11) begin
      reg_0 <= _GEN_5;
    end
  end
  assign out = reg_0;
endmodule
module LogicValueMethod(
  input  wire [63:0] count,
  input  wire [7:0]  init,
  input  wire [7:0]  init_xz,
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
  wire      [7:0]  _GEN_5;
  wire      [7:0]  _GEN_6;
  var logic [63:0] _GEN_7 = 64'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_7 <= 64'h0;
    end
    else begin
      _GEN_7 <= _GEN_2;
    end
  end
  var logic        _GEN_8 = 1'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_8 <= 1'h0;
    end
    else begin
      _GEN_8 <= _GEN_1;
    end
  end
  var logic [7:0]  _GEN_9 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_9 <= 8'h0;
    end
    else begin
      _GEN_9 <= _GEN_6;
    end
  end
  var logic [7:0]  _GEN_10 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_10 <= 8'h0;
    end
    else begin
      _GEN_10 <= _GEN_5;
    end
  end
  var logic [7:0]  _GEN_11 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_11 <= 8'h0;
    end
    else begin
      _GEN_11 <= _GEN_4;
    end
  end
  var logic [7:0]  _GEN_12 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_12 <= 8'h0;
    end
    else begin
      _GEN_12 <= _GEN_3;
    end
  end
  wire             _GEN_13 = _GEN_8 & _GEN_7 < count;
  wire      [7:0]  _GEN_14 = {8{_GEN_13}} & wd | _GEN_9;
  wire      [7:0]  _GEN_15 =
    _GEN_13 ? (_GEN_10 | wd_xz) & (_GEN_10 | ~_GEN_9) & (wd_xz | ~wd) : _GEN_10;
  assign _GEN_6 = _GEN_8 ? _GEN_14 : init;
  assign _GEN_5 = _GEN_8 ? _GEN_15 : init_xz;
  assign _GEN_4 = _GEN_8 ? {8{_GEN_13}} & _GEN_14 | _GEN_11 : init;
  assign _GEN_3 =
    _GEN_8
      ? (_GEN_13
           ? (_GEN_12 | _GEN_15) & (_GEN_12 | ~_GEN_11) & (_GEN_15 | ~_GEN_14)
           : _GEN_12)
      : init_xz;
  wire      [63:0] _GEN_16 = _GEN_7 + 64'h1;
  wire             _GEN_17 = _GEN_13 & _GEN_16 == count;
  assign _GEN_2 = _GEN_13 ? _GEN_16 : 64'h0;
  var logic        _GEN_18 = 1'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_18 <= 1'h0;
    end
    else begin
      _GEN_18 <= _GEN_17;
    end
  end
  assign _GEN_1 = ~_GEN_8 | ~_GEN_17;
  var logic [7:0]  _GEN_19 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_19 <= 8'h0;
    end
    else begin
      _GEN_19 <= _GEN_0;
    end
  end
  var logic [7:0]  _GEN_20 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_20 <= 8'h0;
    end
    else begin
      _GEN_20 <= _GEN;
    end
  end
  assign _GEN_0 = _GEN_18 ? _GEN_11 : _GEN_19;
  assign _GEN = _GEN_18 ? _GEN_12 : _GEN_20;
  assign out = _GEN_19;
  assign out_xz = _GEN_20;
endmodule
