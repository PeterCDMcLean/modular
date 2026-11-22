module ChildCounter(
  input  wire       en,
  input  wire       clk,
  input  wire       rst,
  output wire [7:0] out
);
  wire      [7:0] _GEN;
  var logic [7:0] reg_0 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      reg_0 <= 8'h0;
    end
    else if (en) begin
      reg_0 <= _GEN;
    end
  end
  assign _GEN = reg_0 + 8'h1;
  assign out = reg_0;
endmodule
module TwoDomainChildren(
  input  wire       en_a,
  input  wire       en_b,
  input  wire       clk_run_a,
  input  wire       rst_run_a,
  input  wire       clk_run_b,
  input  wire       rst_run_b,
  output wire [7:0] run_a_out,
  output wire [7:0] run_b_out
);
  ChildCounter a (
    .en  (en_a),
    .clk (clk_run_a),
    .rst (rst_run_a),
    .out (run_a_out)
  );
  ChildCounter b (
    .en  (en_b),
    .clk (clk_run_b),
    .rst (rst_run_b),
    .out (run_b_out)
  );
endmodule
