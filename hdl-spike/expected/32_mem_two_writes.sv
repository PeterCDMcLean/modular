module MemTwoWrites(
  input  [63:0] wa,
  input  [7:0]  wd,
  input         we,
  input  [63:0] wb,
  input  [7:0]  wd2,
  input         we2,
  input  [63:0] ra,
  input         clk,
                rst,
  output [7:0]  out
);
  wire            _GEN;
  wire      [7:0] _GEN_0;
  wire            _GEN_1;
  wire      [7:0] _GEN_2;
  wire            _GEN_3;
  wire      [7:0] _GEN_4;
  wire            _GEN_5;
  wire      [7:0] _GEN_6;
  var logic [7:0] mem_0_0 = 8'h1;
  always @(posedge clk) begin
    if (rst)
      mem_0_0 <= 8'h1;
    else if (_GEN_5)
      mem_0_0 <= _GEN_6;
  end
  var logic [7:0] mem_0_1 = 8'h2;
  always @(posedge clk) begin
    if (rst)
      mem_0_1 <= 8'h2;
    else if (_GEN_3)
      mem_0_1 <= _GEN_4;
  end
  var logic [7:0] mem_0_2 = 8'h3;
  always @(posedge clk) begin
    if (rst)
      mem_0_2 <= 8'h3;
    else if (_GEN_1)
      mem_0_2 <= _GEN_2;
  end
  var logic [7:0] mem_0_3 = 8'h4;
  always @(posedge clk) begin
    if (rst)
      mem_0_3 <= 8'h4;
    else if (_GEN)
      mem_0_3 <= _GEN_0;
  end
  wire            _GEN_7 = we2 & wb == 64'h0;
  assign _GEN_6 = _GEN_7 ? wd2 : wd;
  assign _GEN_5 = we & wa == 64'h0 | _GEN_7;
  wire            _GEN_8 = we2 & wb == 64'h1;
  assign _GEN_4 = _GEN_8 ? wd2 : wd;
  assign _GEN_3 = we & wa == 64'h1 | _GEN_8;
  wire            _GEN_9 = we2 & wb == 64'h2;
  assign _GEN_2 = _GEN_9 ? wd2 : wd;
  assign _GEN_1 = we & wa == 64'h2 | _GEN_9;
  wire            _GEN_10 = we2 & wb == 64'h3;
  assign _GEN_0 = _GEN_10 ? wd2 : wd;
  assign _GEN = we & wa == 64'h3 | _GEN_10;
  assign out =
    ra == 64'h3 ? mem_0_3 : ra == 64'h2 ? mem_0_2 : ra == 64'h1 ? mem_0_1 : mem_0_0;
endmodule
