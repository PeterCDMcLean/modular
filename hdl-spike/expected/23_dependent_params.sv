module DepCounter
  #(parameter W = 8,
    parameter E = 1) (
  input  wire               clk,
  input  wire               rst,
  output wire [E + W - 1:0] out
);
  wire [E + W - 1:0] _GEN;
  var  [E + W - 1:0] _GEN_0;
  always_ff @(posedge clk) begin
    if (rst) begin
      _GEN_0 <= (E + W)'(0);
    end
    else begin
      _GEN_0 <= _GEN;
    end
  end
  assign _GEN = _GEN_0 + (E + W)'(E);
  assign out = _GEN_0;
endmodule
module DepTop(
  input  wire        clk_run_a,
  input  wire        rst_run_a,
  input  wire        clk_run_b,
  input  wire        rst_run_b,
  output wire [8:0]  run_a_out,
  output wire [19:0] run_b_out
);
  DepCounter a (
    .clk (clk_run_a),
    .rst (rst_run_a),
    .out (run_a_out)
  );
  DepCounter #(
    .W(16),
    .E(4)
  ) b (
    .clk (clk_run_b),
    .rst (rst_run_b),
    .out (run_b_out)
  );
endmodule
