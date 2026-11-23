module DivMod
  #(parameter W = 8) (
  input  wire           clk,
  input  wire           rst,
  output wire [W - 1:0] out
);
  wire [(W / 2) - 1:0] _GEN;
  var  [(W / 2) - 1:0] _GEN_0;
  always_ff @(posedge clk) begin
    if (rst) begin
      _GEN_0 <= (W / 2)'(2);
    end
    else begin
      _GEN_0 <= _GEN;
    end
  end
  assign _GEN = _GEN_0 + (W / 2)'(1);
  assign out = W'(0);
endmodule
module SubMod
  #(parameter W = 8) (
  input  wire           clk,
  input  wire           rst,
  output wire [W - 1:0] out
);
  wire [W - 2:0] _GEN;
  var  [W - 2:0] _GEN_0;
  always_ff @(posedge clk) begin
    if (rst) begin
      _GEN_0 <= (W - 1)'(1);
    end
    else begin
      _GEN_0 <= _GEN;
    end
  end
  assign _GEN = _GEN_0 + (W - 1)'(1);
  assign out = W'(0);
endmodule
module MaxMod
  #(parameter W = 8,
    parameter E = 2) (
  input  wire           clk,
  input  wire           rst,
  output wire [W - 1:0] out
);
  wire [((E < W) ? W : E) - 1:0] _GEN;
  var  [((E < W) ? W : E) - 1:0] _GEN_0;
  always_ff @(posedge clk) begin
    if (rst) begin
      _GEN_0 <= ((E < W) ? W : E)'(3);
    end
    else begin
      _GEN_0 <= _GEN;
    end
  end
  assign _GEN = _GEN_0 + ((E < W) ? W : E)'(1);
  assign out = W'(0);
endmodule
module ExprTop(
  input  wire       clk_run_s,
  input  wire       rst_run_s,
  input  wire       clk_run_d,
  input  wire       rst_run_d,
  input  wire       clk_run_m,
  input  wire       rst_run_m,
  output wire [7:0] run_s_out,
  output wire [8:0] run_d_out,
  output wire [7:0] run_m_out
);
  SubMod s (
    .clk (clk_run_s),
    .rst (rst_run_s),
    .out (run_s_out)
  );
  DivMod #(
    .W(9)
  ) d (
    .clk (clk_run_d),
    .rst (rst_run_d),
    .out (run_d_out)
  );
  MaxMod m (
    .clk (clk_run_m),
    .rst (rst_run_m),
    .out (run_m_out)
  );
endmodule
