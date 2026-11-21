module ParamCounter_16(
  input         clk,
                rst,
  output [15:0] out
);
  wire      [15:0] _GEN;
  var logic [15:0] _GEN_0 = 16'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_0 <= 16'h0;
    else
      _GEN_0 <= _GEN;
  end
  assign _GEN = _GEN_0 + 16'h1;
  assign out = _GEN_0;
endmodule
module ParamCounter_8(
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
  assign _GEN = _GEN_0 + 8'h1;
  assign out = _GEN_0;
endmodule
module TwoWidths(
  input         clk_run_narrow,
                rst_run_narrow,
                clk_run_wide,
                rst_run_wide,
  output [7:0]  run_narrow_out,
  output [15:0] run_wide_out
);
  ParamCounter_8 narrow (
    .clk (clk_run_narrow),
    .rst (rst_run_narrow),
    .out (run_narrow_out)
  );
  ParamCounter_16 wide (
    .clk (clk_run_wide),
    .rst (rst_run_wide),
    .out (run_wide_out)
  );
endmodule
