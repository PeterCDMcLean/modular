module ClogCounter
  #(parameter W = 8) (
  input  wire clk,
  input  wire rst,
  output wire out
);
  wire [$clog2($unsigned(W)) - 1:0] _GEN;
  var  [$clog2($unsigned(W)) - 1:0] _GEN_0;
  always_ff @(posedge clk) begin
    if (rst) begin
      _GEN_0 <= ($clog2(W))'(0);
    end
    else begin
      _GEN_0 <= _GEN;
    end
  end
  assign _GEN = _GEN_0 + ($clog2(W))'(1);
  assign out = 1'h0;
endmodule
module ClogPort
  #(parameter W = 8) (
  input  wire [$clog2($unsigned(W)) - 1:0] a,
  output wire [$clog2($unsigned(W)) - 1:0] out
);
  assign out = a;
endmodule
module ClogTop(
  input  wire clk_run_small,
  input  wire rst_run_small,
  input  wire clk_run_large,
  input  wire rst_run_large,
  output wire run_small_out,
  output wire run_large_out
);
  ClogCounter small_0 (
    .clk (clk_run_small),
    .rst (rst_run_small),
    .out (run_small_out)
  );
  ClogCounter #(
    .W(32)
  ) large_0 (
    .clk (clk_run_large),
    .rst (rst_run_large),
    .out (run_large_out)
  );
endmodule
