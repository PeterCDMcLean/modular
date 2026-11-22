module RuntimeFill(
  input  [63:0] count,
  input  [7:0]  wd,
  input         en,
                clk,
                rst,
  output [7:0]  out
);
  wire      [63:0] _GEN;
  wire             _GEN_0;
  wire             _GEN_1;
  wire             _GEN_2;
  wire             _GEN_3;
  var logic [63:0] _GEN_4 = 64'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_4 <= 64'h0;
    else
      _GEN_4 <= _GEN;
  end
  wire             _GEN_5 = _GEN_4 < count;
  var logic [7:0]  mem_0_0 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_0 <= 8'h0;
    else if (_GEN_3)
      mem_0_0 <= wd;
  end
  var logic [7:0]  mem_0_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_1 <= 8'h0;
    else if (_GEN_2)
      mem_0_1 <= wd;
  end
  var logic [7:0]  mem_0_2 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_2 <= 8'h0;
    else if (_GEN_1)
      mem_0_2 <= wd;
  end
  var logic [7:0]  mem_0_3 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_3 <= 8'h0;
    else if (_GEN_0)
      mem_0_3 <= wd;
  end
  assign _GEN_3 = _GEN_5 & en & _GEN_4 == 64'h0;
  assign _GEN_2 = _GEN_5 & en & _GEN_4 == 64'h1;
  assign _GEN_1 = _GEN_5 & en & _GEN_4 == 64'h2;
  assign _GEN_0 = _GEN_5 & en & _GEN_4 == 64'h3;
  var logic [7:0]  reg_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      reg_1 <= 8'h0;
    else if (_GEN_5)
      reg_1 <= wd;
  end
  assign _GEN = _GEN_5 ? _GEN_4 + 64'h1 : 64'h0;
  assign out = reg_1;
endmodule
