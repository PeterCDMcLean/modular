module RuntimeArrayCarry(
  input  wire [63:0] count,
  input  wire [7:0]  wd,
  input  wire        clk,
  input  wire        rst,
  output wire [7:0]  out
);
  wire      [7:0]  _GEN;
  wire             _GEN_0;
  wire      [63:0] _GEN_1;
  wire      [31:0] _GEN_2;
  var logic [63:0] _GEN_3 = 64'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_3 <= 64'h0;
    end
    else begin
      _GEN_3 <= _GEN_1;
    end
  end
  var logic        _GEN_4 = 1'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_4 <= 1'h0;
    end
    else begin
      _GEN_4 <= _GEN_0;
    end
  end
  var logic [31:0] _GEN_5 = 32'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_5 <= 32'h0;
    end
    else begin
      _GEN_5 <= _GEN_2;
    end
  end
  wire             _GEN_6 = _GEN_4 & _GEN_3 < count;
  wire      [31:0] _GEN_7 = {_GEN_3[28:0], 3'h0};
  assign _GEN_2 =
    _GEN_4
      ? (_GEN_6 ? _GEN_5 & ~(32'hFF << _GEN_7) | {24'h0, wd} << _GEN_7 : _GEN_5)
      : 32'h0;
  wire      [63:0] _GEN_8 = _GEN_3 + 64'h1;
  wire             _GEN_9 = _GEN_6 & _GEN_8 == count;
  assign _GEN_1 = _GEN_6 ? _GEN_8 : 64'h0;
  var logic        _GEN_10 = 1'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_10 <= 1'h0;
    end
    else begin
      _GEN_10 <= _GEN_9;
    end
  end
  assign _GEN_0 = ~_GEN_4 | ~_GEN_9;
  var logic [7:0]  reg_0 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      reg_0 <= 8'h0;
    end
    else if (_GEN_10) begin
      reg_0 <= _GEN_5[7:0];
    end
  end
  var logic [7:0]  reg_1 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      reg_1 <= 8'h0;
    end
    else if (_GEN_10) begin
      reg_1 <= _GEN;
    end
  end
  assign _GEN = reg_1 + 8'h1;
  assign out = reg_0;
endmodule
module RuntimeLogicArrayCarry(
  input  wire [63:0] count,
  input  wire [31:0] init,
  input  wire [31:0] init_xz,
  input  wire [7:0]  wd,
  input  wire [7:0]  wd_xz,
  input  wire        clk,
  input  wire        rst,
  output wire [7:0]  out,
  output wire [7:0]  out_xz
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
    if (rst) begin
      _GEN_6 <= 64'h0;
    end
    else begin
      _GEN_6 <= _GEN_3;
    end
  end
  var logic        _GEN_7 = 1'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_7 <= 1'h0;
    end
    else begin
      _GEN_7 <= _GEN_2;
    end
  end
  var logic [31:0] _GEN_8 = 32'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_8 <= 32'h0;
    end
    else begin
      _GEN_8 <= _GEN_5;
    end
  end
  var logic [31:0] _GEN_9 = 32'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_9 <= 32'h0;
    end
    else begin
      _GEN_9 <= _GEN_4;
    end
  end
  wire             _GEN_10 = _GEN_7 & _GEN_6 < count;
  wire      [31:0] _GEN_11 = {_GEN_6[28:0], 3'h0};
  wire      [31:0] _GEN_12 = 32'hFF << _GEN_11;
  assign _GEN_5 =
    _GEN_7 ? (_GEN_10 ? _GEN_8 & ~_GEN_12 | {24'h0, wd} << _GEN_11 : _GEN_8) : init;
  assign _GEN_4 =
    _GEN_7 ? (_GEN_10 ? _GEN_9 & ~_GEN_12 | {24'h0, wd_xz} << _GEN_11 : _GEN_9) : init_xz;
  wire      [63:0] _GEN_13 = _GEN_6 + 64'h1;
  wire             _GEN_14 = _GEN_10 & _GEN_13 == count;
  assign _GEN_3 = _GEN_10 ? _GEN_13 : 64'h0;
  var logic        _GEN_15 = 1'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_15 <= 1'h0;
    end
    else begin
      _GEN_15 <= _GEN_14;
    end
  end
  assign _GEN_2 = ~_GEN_7 | ~_GEN_14;
  var logic [7:0]  _GEN_16 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_16 <= 8'h0;
    end
    else begin
      _GEN_16 <= _GEN_1;
    end
  end
  var logic [7:0]  _GEN_17 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_17 <= 8'h0;
    end
    else begin
      _GEN_17 <= _GEN_0;
    end
  end
  assign _GEN_1 = _GEN_15 ? _GEN_8[7:0] : _GEN_16;
  assign _GEN_0 = _GEN_15 ? _GEN_9[7:0] : _GEN_17;
  var logic [7:0]  reg_1 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      reg_1 <= 8'h0;
    end
    else if (_GEN_15) begin
      reg_1 <= _GEN;
    end
  end
  assign _GEN = reg_1 + 8'h1;
  assign out = _GEN_16;
  assign out_xz = _GEN_17;
endmodule
