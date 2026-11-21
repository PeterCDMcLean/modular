module PackedConstOut(
  output [31:0] out
);
  assign out = 32'h4030201;
endmodule
module PackedHold(
  input  [31:0] din,
  input         clk,
                rst,
  output [31:0] out
);
  var logic [31:0] _GEN = 32'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN <= 32'h0;
    else
      _GEN <= din;
  end
  assign out = _GEN;
endmodule
module PackedPass(
  input  [31:0] din,
  output [31:0] out
);
  assign out = din;
endmodule
