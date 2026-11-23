module ParamLogicState
  #(parameter W = 8) (
  input  wire [W - 1:0] d,
  input  wire [W - 1:0] d_xz,
  input  wire           clk,
  input  wire           rst,
  output wire [W - 1:0] out,
  output wire [W - 1:0] out_xz
);
  wire [W - 1:0] _GEN;
  wire [W - 1:0] _GEN_0;
  var  [W - 1:0] _GEN_1;
  always_ff @(posedge clk) begin
    if (rst) begin
      _GEN_1 <= W'(0);
    end
    else begin
      _GEN_1 <= _GEN;
    end
  end
  var  [W - 1:0] _GEN_2;
  always_ff @(posedge clk) begin
    if (rst) begin
      _GEN_2 <= W'(0);
    end
    else begin
      _GEN_2 <= _GEN_0;
    end
  end
  assign _GEN_0 = (_GEN_2 | d_xz) & (_GEN_2 | _GEN_1) & (d_xz | d);
  assign _GEN = _GEN_1 & d ^ W'(-1);
  assign out = _GEN_1;
  assign out_xz = _GEN_2;
endmodule
module ParamLogicUsers(
  input  wire [7:0]  n,
  input  wire [7:0]  n_xz,
  input  wire [15:0] w,
  input  wire [15:0] w_xz,
  input  wire        clk_run_narrow,
  input  wire        rst_run_narrow,
  input  wire        clk_run_wide,
  input  wire        rst_run_wide,
  output wire [7:0]  run_narrow_out,
  output wire [7:0]  run_narrow_out_xz,
  output wire [15:0] run_wide_out,
  output wire [15:0] run_wide_out_xz
);
  ParamLogicState narrow (
    .d      (n),
    .d_xz   (n_xz),
    .clk    (clk_run_narrow),
    .rst    (rst_run_narrow),
    .out    (run_narrow_out),
    .out_xz (run_narrow_out_xz)
  );
  ParamLogicState #(
    .W(16)
  ) wide (
    .d      (w),
    .d_xz   (w_xz),
    .clk    (clk_run_wide),
    .rst    (rst_run_wide),
    .out    (run_wide_out),
    .out_xz (run_wide_out_xz)
  );
endmodule
