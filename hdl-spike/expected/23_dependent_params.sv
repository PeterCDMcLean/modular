module DepCounter_16_4(
  input  wire        clk,
  input  wire        rst,
  output wire [19:0] out
);
  wire      [19:0] _GEN;
  var logic [19:0] _GEN_0 = 20'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_0 <= 20'h0;
    end
    else begin
      _GEN_0 <= _GEN;
    end
  end
  assign _GEN = _GEN_0 + 20'h4;
  assign out = _GEN_0;
endmodule
module DepCounter_8_1(
  input  wire       clk,
  input  wire       rst,
  output wire [8:0] out
);
  wire      [8:0] _GEN;
  var logic [8:0] _GEN_0 = 9'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_0 <= 9'h0;
    end
    else begin
      _GEN_0 <= _GEN;
    end
  end
  assign _GEN = _GEN_0 + 9'h1;
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
  DepCounter_8_1 a (
    .clk (clk_run_a),
    .rst (rst_run_a),
    .out (run_a_out)
  );
  DepCounter_16_4 b (
    .clk (clk_run_b),
    .rst (rst_run_b),
    .out (run_b_out)
  );
endmodule
