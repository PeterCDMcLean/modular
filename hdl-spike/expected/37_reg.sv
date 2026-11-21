module RegDemo(
  input        en,
               clk,
               rst,
  output [7:0] out
);
  wire      [7:0] _GEN;
  wire      [7:0] _GEN_0;
  var logic [7:0] _GEN_1 = 8'h3;
  always @(posedge clk) begin
    if (rst)
      _GEN_1 <= 8'h3;
    else
      _GEN_1 <= _GEN_0;
  end
  assign _GEN_0 = _GEN_1 + 8'h1;
  var logic [7:0] reg_1 = 8'h1;
  always @(posedge clk) begin
    if (rst)
      reg_1 <= 8'h1;
    else if (en)
      reg_1 <= _GEN;
  end
  assign _GEN = reg_1 + 8'h2;
  assign out = _GEN_1 ^ reg_1;
endmodule
