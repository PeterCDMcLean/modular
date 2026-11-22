module ChildCounter(
  input        en,
               clk,
               rst,
  output [7:0] out
);
  wire      [7:0] _GEN;
  var logic [7:0] reg_0 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      reg_0 <= 8'h0;
    else if (en)
      reg_0 <= _GEN;
  end
  assign _GEN = reg_0 + 8'h1;
  assign out = reg_0;
endmodule
module TwoDomainChildren(
  input        en_a,
               en_b,
               clk_run_a,
               rst_run_a,
               clk_run_b,
               rst_run_b,
  output [7:0] run_a_out,
               run_b_out
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
