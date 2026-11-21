module Counter(
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
module Inverter(
  input  [7:0] a,
  output [7:0] out
);
  assign out = ~a;
endmodule
module MultiInstance(
  input  [7:0] a,
               b,
  input        en_a,
               en_b,
               clk,
               rst,
  output [7:0] out
);
  wire [7:0] _ctr_b_out;
  wire [7:0] _ctr_a_out;
  wire [7:0] _inv_b_out;
  wire [7:0] _inv_a_out;
  Inverter inv_a (
    .a   (a),
    .out (_inv_a_out)
  );
  Inverter inv_b (
    .a   (b),
    .out (_inv_b_out)
  );
  Counter ctr_a (
    .en  (en_a),
    .clk (clk),
    .rst (rst),
    .out (_ctr_a_out)
  );
  Counter ctr_b (
    .en  (en_b),
    .clk (clk),
    .rst (rst),
    .out (_ctr_b_out)
  );
  assign out = _inv_a_out ^ _inv_b_out ^ _ctr_a_out ^ _ctr_b_out;
endmodule
