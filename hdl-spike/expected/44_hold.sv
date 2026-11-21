module PackedConstHold(
  input         clk,
                rst,
  output [31:0] out
);
  var logic [31:0] _GEN = 32'h4030201;
  always @(posedge clk) begin
    if (rst)
      _GEN <= 32'h4030201;
    else
      _GEN <= _GEN;
  end
  assign out = _GEN;
endmodule
module UnwrittenBits(
  input        clk,
               rst,
  output [7:0] out
);
  var logic [7:0] _GEN = 8'h7;
  always @(posedge clk) begin
    if (rst)
      _GEN <= 8'h7;
    else
      _GEN <= _GEN;
  end
  assign out = _GEN;
endmodule
