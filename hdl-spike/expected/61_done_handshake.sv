module RuntimeForDone(
  input  wire [63:0] count,
  input  wire [7:0]  wd,
  input  wire        en,
  input  wire        clk,
  input  wire        rst,
  output wire [7:0]  out
);
  wire      [7:0]  _GEN;
  wire      [63:0] _GEN_0;
  wire             _GEN_1;
  wire             _GEN_2;
  wire             _GEN_3;
  wire             _GEN_4;
  var logic [63:0] _GEN_5 = 64'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_5 <= 64'h0;
    end
    else begin
      _GEN_5 <= _GEN_0;
    end
  end
  wire             _GEN_6 = _GEN_5 < count;
  var logic [7:0]  mem_0_0 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_0 <= 8'h0;
    end
    else if (_GEN_4) begin
      mem_0_0 <= wd;
    end
  end
  var logic [7:0]  mem_0_1 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_1 <= 8'h0;
    end
    else if (_GEN_3) begin
      mem_0_1 <= wd;
    end
  end
  var logic [7:0]  mem_0_2 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_2 <= 8'h0;
    end
    else if (_GEN_2) begin
      mem_0_2 <= wd;
    end
  end
  var logic [7:0]  mem_0_3 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_3 <= 8'h0;
    end
    else if (_GEN_1) begin
      mem_0_3 <= wd;
    end
  end
  assign _GEN_4 = _GEN_6 & en & _GEN_5 == 64'h0;
  assign _GEN_3 = _GEN_6 & en & _GEN_5 == 64'h1;
  assign _GEN_2 = _GEN_6 & en & _GEN_5 == 64'h2;
  assign _GEN_1 = _GEN_6 & en & _GEN_5 == 64'h3;
  var logic [7:0]  reg_1 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      reg_1 <= 8'h0;
    end
    else if (_GEN_6) begin
      reg_1 <= wd;
    end
  end
  wire      [63:0] _GEN_7 = _GEN_5 + 64'h1;
  assign _GEN_0 = _GEN_6 ? _GEN_7 : 64'h0;
  var logic        _GEN_8 = 1'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_8 <= 1'h0;
    end
    else begin
      _GEN_8 <= _GEN_6 & _GEN_7 == count;
    end
  end
  var logic [7:0]  reg_2 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      reg_2 <= 8'h0;
    end
    else if (_GEN_8) begin
      reg_2 <= _GEN;
    end
  end
  assign _GEN = reg_2 + 8'h1;
  assign out = reg_2;
endmodule
module RuntimeWhileDone(
  input  wire [63:0] count,
  input  wire [7:0]  wd,
  input  wire        en,
  input  wire        clk,
  input  wire        rst,
  output wire [7:0]  out
);
  wire      [7:0]  _GEN;
  wire      [63:0] _GEN_0;
  wire             _GEN_1;
  wire             _GEN_2;
  wire             _GEN_3;
  wire             _GEN_4;
  var logic [63:0] _GEN_5 = 64'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_5 <= 64'h0;
    end
    else begin
      _GEN_5 <= _GEN_0;
    end
  end
  wire             _GEN_6 = _GEN_5 < count;
  var logic [7:0]  mem_0_0 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_0 <= 8'h0;
    end
    else if (_GEN_4) begin
      mem_0_0 <= wd;
    end
  end
  var logic [7:0]  mem_0_1 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_1 <= 8'h0;
    end
    else if (_GEN_3) begin
      mem_0_1 <= wd;
    end
  end
  var logic [7:0]  mem_0_2 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_2 <= 8'h0;
    end
    else if (_GEN_2) begin
      mem_0_2 <= wd;
    end
  end
  var logic [7:0]  mem_0_3 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_3 <= 8'h0;
    end
    else if (_GEN_1) begin
      mem_0_3 <= wd;
    end
  end
  assign _GEN_4 = _GEN_6 & en & _GEN_5 == 64'h0;
  assign _GEN_3 = _GEN_6 & en & _GEN_5 == 64'h1;
  assign _GEN_2 = _GEN_6 & en & _GEN_5 == 64'h2;
  assign _GEN_1 = _GEN_6 & en & _GEN_5 == 64'h3;
  var logic [7:0]  reg_1 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      reg_1 <= 8'h0;
    end
    else if (_GEN_6) begin
      reg_1 <= wd;
    end
  end
  wire      [63:0] _GEN_7 = _GEN_5 + 64'h1;
  assign _GEN_0 = _GEN_6 ? _GEN_7 : 64'h0;
  var logic        _GEN_8 = 1'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_8 <= 1'h0;
    end
    else begin
      _GEN_8 <= _GEN_6 & _GEN_7 == count;
    end
  end
  var logic [7:0]  reg_2 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      reg_2 <= 8'h0;
    end
    else if (_GEN_8) begin
      reg_2 <= _GEN;
    end
  end
  assign _GEN = reg_2 + 8'h1;
  assign out = reg_2;
endmodule
