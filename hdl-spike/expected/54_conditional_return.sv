module AccCell(
  input  [7:0] delta,
  input        clk,
               rst,
  output [7:0] out
);
  wire      [7:0] _GEN;
  var logic [7:0] _GEN_0 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_0 <= 8'h0;
    else
      _GEN_0 <= _GEN;
  end
  assign _GEN = _GEN_0 + delta;
  assign out = _GEN_0;
endmodule
module LogicReturn(
  input        sel,
  input  [7:0] a,
               a_xz,
               b,
               b_xz,
  output [7:0] out,
               out_xz
);
  assign out = sel ? a : b;
  assign out_xz = sel ? a_xz : b_xz;
endmodule
module ReturnFallthrough(
  input        sel,
  input  [7:0] a,
               b,
  output [7:0] out
);
  assign out = sel ? a : b;
endmodule
module ReturnInstance(
  input        sel,
  input  [7:0] a,
               b,
  input        clk,
               rst,
  output [7:0] out
);
  wire [7:0] _GEN;
  AccCell cell_0 (
    .delta (_GEN),
    .clk   (clk),
    .rst   (rst),
    .out   (out)
  );
  assign _GEN = ~sel ? b : a;
endmodule
module ReturnMux(
  input        sel,
  input  [7:0] a,
               b,
  output [7:0] out
);
  assign out = sel ? a : b;
endmodule
