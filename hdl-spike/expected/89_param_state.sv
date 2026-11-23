module ParamAccumulator
  #(parameter W = 8) (
  input  wire [W - 1:0] step,
  input  wire           clk,
  input  wire           rst,
  output wire [W - 1:0] out
);
  wire [W - 1:0] _GEN;
  wire [W - 1:0] _GEN_0;
  var  [W - 1:0] _GEN_1;
  always_ff @(posedge clk) begin
    if (rst) begin
      _GEN_1 <= W'(0);
    end
    else begin
      _GEN_1 <= _GEN_0;
    end
  end
  assign _GEN_0 = _GEN_1 + step;
  var  [W - 1:0] _GEN_2;
  always_ff @(posedge clk) begin
    if (rst) begin
      _GEN_2 <= W'(1);
    end
    else begin
      _GEN_2 <= _GEN;
    end
  end
  assign _GEN = _GEN_2 + W'(1);
  assign out = _GEN_1 ^ _GEN_2;
endmodule
module ParamStateUsers(
  input  wire [7:0]  n,
  input  wire [15:0] w,
  input  wire        clk_run_narrow,
  input  wire        rst_run_narrow,
  input  wire        clk_run_wide,
  input  wire        rst_run_wide,
  output wire [7:0]  run_narrow_out,
  output wire [15:0] run_wide_out
);
  ParamAccumulator narrow (
    .step (n),
    .clk  (clk_run_narrow),
    .rst  (rst_run_narrow),
    .out  (run_narrow_out)
  );
  ParamAccumulator #(
    .W(16)
  ) wide (
    .step (w),
    .clk  (clk_run_wide),
    .rst  (rst_run_wide),
    .out  (run_wide_out)
  );
endmodule
