module ParamCounter
  #(parameter W = 8) (
  input  wire           clk,
  input  wire           rst,
  output wire [W - 1:0] out
);
  wire [W - 1:0] _GEN;
  var  [W - 1:0] _GEN_0;
  always_ff @(posedge clk) begin
    if (rst) begin
      _GEN_0 <= W'(0);
    end
    else begin
      _GEN_0 <= _GEN;
    end
  end
  assign _GEN = _GEN_0 + W'(1);
  assign out = _GEN_0;
endmodule
module TwoWidths(
  input  wire        clk_run_narrow,
  input  wire        rst_run_narrow,
  input  wire        clk_run_wide,
  input  wire        rst_run_wide,
  output wire [7:0]  run_narrow_out,
  output wire [15:0] run_wide_out
);
  ParamCounter narrow (
    .clk (clk_run_narrow),
    .rst (rst_run_narrow),
    .out (run_narrow_out)
  );
  ParamCounter #(
    .W(16)
  ) wide (
    .clk (clk_run_wide),
    .rst (rst_run_wide),
    .out (run_wide_out)
  );
endmodule
