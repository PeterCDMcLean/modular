module DivMod_9(
  input        clk,
               rst,
  output [8:0] out
);
  wire      [3:0] _GEN;
  var logic [3:0] _GEN_0 = 4'h2;
  always @(posedge clk) begin
    if (rst)
      _GEN_0 <= 4'h2;
    else
      _GEN_0 <= _GEN;
  end
  assign _GEN = _GEN_0 + 4'h1;
  assign out = 9'h0;
endmodule
module SubMod_8(
  input        clk,
               rst,
  output [7:0] out
);
  wire      [6:0] _GEN;
  var logic [6:0] _GEN_0 = 7'h1;
  always @(posedge clk) begin
    if (rst)
      _GEN_0 <= 7'h1;
    else
      _GEN_0 <= _GEN;
  end
  assign _GEN = _GEN_0 + 7'h1;
  assign out = 8'h0;
endmodule
module MaxMod_8_2(
  input        clk,
               rst,
  output [7:0] out
);
  wire      [7:0] _GEN;
  var logic [7:0] _GEN_0 = 8'h3;
  always @(posedge clk) begin
    if (rst)
      _GEN_0 <= 8'h3;
    else
      _GEN_0 <= _GEN;
  end
  assign _GEN = _GEN_0 + 8'h1;
  assign out = 8'h0;
endmodule
module ExprTop(
  input        clk_run_s,
               rst_run_s,
               clk_run_d,
               rst_run_d,
               clk_run_m,
               rst_run_m,
  output [7:0] run_s_out,
  output [8:0] run_d_out,
  output [7:0] run_m_out
);
  SubMod_8 s (
    .clk (clk_run_s),
    .rst (rst_run_s),
    .out (run_s_out)
  );
  DivMod_9 d (
    .clk (clk_run_d),
    .rst (rst_run_d),
    .out (run_d_out)
  );
  MaxMod_8_2 m (
    .clk (clk_run_m),
    .rst (rst_run_m),
    .out (run_m_out)
  );
endmodule
