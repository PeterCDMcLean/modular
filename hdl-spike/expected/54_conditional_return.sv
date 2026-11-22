module AccCell(
  input  wire [7:0] delta,
  input  wire       clk,
  input  wire       rst,
  output wire [7:0] out
);
  wire      [7:0] _GEN;
  var logic [7:0] _GEN_0 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_0 <= 8'h0;
    end
    else begin
      _GEN_0 <= _GEN;
    end
  end
  assign _GEN = _GEN_0 + delta;
  assign out = _GEN_0;
endmodule
module LogicReturn(
  input  wire       sel,
  input  wire [7:0] a,
  input  wire [7:0] a_xz,
  input  wire [7:0] b,
  input  wire [7:0] b_xz,
  output wire [7:0] out,
  output wire [7:0] out_xz
);
  assign out = sel ? a : b;
  assign out_xz = sel ? a_xz : b_xz;
endmodule
module ReturnFallthrough(
  input  wire       sel,
  input  wire [7:0] a,
  input  wire [7:0] b,
  output wire [7:0] out
);
  assign out = sel ? a : b;
endmodule
module ReturnInstance(
  input  wire       sel,
  input  wire [7:0] a,
  input  wire [7:0] b,
  input  wire       clk,
  input  wire       rst,
  output wire [7:0] out
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
  input  wire       sel,
  input  wire [7:0] a,
  input  wire [7:0] b,
  output wire [7:0] out
);
  assign out = sel ? a : b;
endmodule
