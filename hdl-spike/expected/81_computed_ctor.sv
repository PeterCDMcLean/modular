module ComputedCtorCarry(
  input  wire [63:0] count,
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
  assign _GEN_2 = _GEN_4 ? (_GEN_7 ? _GEN_5 + wd : _GEN_5) : wd + 8'h3;
  assign _GEN_1 = _GEN_4 ? (_GEN_7 ? _GEN_6 + 8'h1 : _GEN_6) : 8'h8;
  wire      [63:0] _GEN_8 = _GEN_3 + 64'h1;
  wire             _GEN_9 = _GEN_7 & _GEN_8 == count;
  assign _GEN_0 = _GEN_7 ? _GEN_8 : 64'h0;
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
  var logic [7:0]  reg_0 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      reg_0 <= 8'h0;
    end
    else if (_GEN_10) begin
      reg_0 <= _GEN_5;
    end
  end
  var logic [7:0]  reg_1 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      reg_1 <= 8'h0;
    end
    else if (_GEN_10) begin
      reg_1 <= _GEN_6;
    end
  end
  assign out = reg_0;
endmodule
module LogicComputedCtor(
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
  wire      [3:0]  _GEN_3;
  wire      [7:0]  _GEN_4;
  wire      [7:0]  _GEN_5;
  var logic [63:0] _GEN_6 = 64'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_6 <= 64'h0;
    end
    else begin
      _GEN_6 <= _GEN_2;
    end
  end
  var logic        _GEN_7 = 1'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_7 <= 1'h0;
    end
    else begin
      _GEN_7 <= _GEN_1;
    end
  end
  var logic [7:0]  _GEN_8 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_8 <= 8'h0;
    end
    else begin
      _GEN_8 <= _GEN_5;
    end
  end
  var logic [7:0]  _GEN_9 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_9 <= 8'h0;
    end
    else begin
      _GEN_9 <= _GEN_4;
    end
  end
  var logic [3:0]  _GEN_10 = 4'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_10 <= 4'h0;
    end
    else begin
      _GEN_10 <= _GEN_3;
    end
  end
  wire             _GEN_11 = _GEN_7 & _GEN_6 < count;
  assign _GEN_5 = _GEN_7 ? _GEN_8 : init;
  assign _GEN_4 = _GEN_7 ? _GEN_9 : init_xz & (init_xz | ~init) & (init_xz | ~init);
  assign _GEN_3 = _GEN_7 ? (_GEN_11 ? _GEN_10 + 4'h1 : _GEN_10) : 4'h5;
  wire      [63:0] _GEN_12 = _GEN_6 + 64'h1;
  wire             _GEN_13 = _GEN_11 & _GEN_12 == count;
  assign _GEN_2 = _GEN_11 ? _GEN_12 : 64'h0;
  var logic        _GEN_14 = 1'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_14 <= 1'h0;
    end
    else begin
      _GEN_14 <= _GEN_13;
    end
  end
  assign _GEN_1 = ~_GEN_7 | ~_GEN_13;
  var logic [7:0]  _GEN_15 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_15 <= 8'h0;
    end
    else begin
      _GEN_15 <= _GEN_0;
    end
  end
  var logic [7:0]  _GEN_16 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_16 <= 8'h0;
    end
    else begin
      _GEN_16 <= _GEN;
    end
  end
  assign _GEN_0 = _GEN_14 ? _GEN_8 : _GEN_15;
  assign _GEN = _GEN_14 ? _GEN_9 : _GEN_16;
  var logic [3:0]  reg_1 = 4'h0;
  always @(posedge clk) begin
    if (rst) begin
      reg_1 <= 4'h0;
    end
    else if (_GEN_14) begin
      reg_1 <= _GEN_10;
    end
  end
  assign out = _GEN_15;
  assign out_xz = _GEN_16;
endmodule
