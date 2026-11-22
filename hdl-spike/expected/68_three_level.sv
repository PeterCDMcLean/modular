module ThreeLevelFill(
  input  wire [63:0] a,
  input  wire [63:0] b,
  input  wire [63:0] c,
  input  wire [7:0]  wd,
  input  wire        en,
  input  wire        clk,
  input  wire        rst,
  output wire [7:0]  out
);
  wire      [7:0]  _GEN;
  wire      [63:0] _GEN_0;
  wire      [63:0] _GEN_1;
  wire      [63:0] _GEN_2;
  wire             _GEN_3;
  wire             _GEN_4;
  wire             _GEN_5;
  wire             _GEN_6;
  wire             _GEN_7;
  wire             _GEN_8;
  wire             _GEN_9;
  wire             _GEN_10;
  var logic [63:0] _GEN_11 = 64'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_11 <= 64'h0;
    end
    else begin
      _GEN_11 <= _GEN_0;
    end
  end
  var logic [63:0] _GEN_12 = 64'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_12 <= 64'h0;
    end
    else begin
      _GEN_12 <= _GEN_1;
    end
  end
  var logic [63:0] _GEN_13 = 64'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_13 <= 64'h0;
    end
    else begin
      _GEN_13 <= _GEN_2;
    end
  end
  wire             _GEN_14 = _GEN_11 < a & _GEN_12 < b & _GEN_13 < c;
  wire      [63:0] _GEN_15 = {_GEN_11[61:0], 2'h0} + {_GEN_12[62:0], 1'h0} + _GEN_13;
  var logic [7:0]  mem_0_0 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_0 <= 8'h0;
    end
    else if (_GEN_10) begin
      mem_0_0 <= wd;
    end
  end
  var logic [7:0]  mem_0_1 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_1 <= 8'h0;
    end
    else if (_GEN_9) begin
      mem_0_1 <= wd;
    end
  end
  var logic [7:0]  mem_0_2 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_2 <= 8'h0;
    end
    else if (_GEN_8) begin
      mem_0_2 <= wd;
    end
  end
  var logic [7:0]  mem_0_3 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_3 <= 8'h0;
    end
    else if (_GEN_7) begin
      mem_0_3 <= wd;
    end
  end
  var logic [7:0]  mem_0_4 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_4 <= 8'h0;
    end
    else if (_GEN_6) begin
      mem_0_4 <= wd;
    end
  end
  var logic [7:0]  mem_0_5 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_5 <= 8'h0;
    end
    else if (_GEN_5) begin
      mem_0_5 <= wd;
    end
  end
  var logic [7:0]  mem_0_6 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_6 <= 8'h0;
    end
    else if (_GEN_4) begin
      mem_0_6 <= wd;
    end
  end
  var logic [7:0]  mem_0_7 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_7 <= 8'h0;
    end
    else if (_GEN_3) begin
      mem_0_7 <= wd;
    end
  end
  assign _GEN_10 = _GEN_14 & en & _GEN_15 == 64'h0;
  assign _GEN_9 = _GEN_14 & en & _GEN_15 == 64'h1;
  assign _GEN_8 = _GEN_14 & en & _GEN_15 == 64'h2;
  assign _GEN_7 = _GEN_14 & en & _GEN_15 == 64'h3;
  assign _GEN_6 = _GEN_14 & en & _GEN_15 == 64'h4;
  assign _GEN_5 = _GEN_14 & en & _GEN_15 == 64'h5;
  assign _GEN_4 = _GEN_14 & en & _GEN_15 == 64'h6;
  assign _GEN_3 = _GEN_14 & en & _GEN_15 == 64'h7;
  var logic [7:0]  reg_1 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      reg_1 <= 8'h0;
    end
    else if (_GEN_14) begin
      reg_1 <= wd;
    end
  end
  wire      [63:0] _GEN_16 = _GEN_13 + 64'h1;
  wire             _GEN_17 = _GEN_14 & _GEN_16 == c;
  assign _GEN_2 = ~_GEN_14 | _GEN_17 ? 64'h0 : _GEN_16;
  wire      [63:0] _GEN_18 = _GEN_12 + 64'h1;
  wire             _GEN_19 = _GEN_17 & _GEN_18 == b;
  assign _GEN_1 = _GEN_17 ? (_GEN_19 ? 64'h0 : _GEN_18) : _GEN_12;
  wire      [63:0] _GEN_20 = _GEN_11 + 64'h1;
  wire             _GEN_21 = _GEN_19 & _GEN_20 == a;
  assign _GEN_0 = _GEN_19 ? (_GEN_21 ? 64'h0 : _GEN_20) : _GEN_11;
  var logic        _GEN_22 = 1'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_22 <= 1'h0;
    end
    else begin
      _GEN_22 <= _GEN_21;
    end
  end
  var logic [7:0]  reg_2 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      reg_2 <= 8'h0;
    end
    else if (_GEN_22) begin
      reg_2 <= _GEN;
    end
  end
  assign _GEN = reg_2 + 8'h1;
  assign out = reg_1;
endmodule
