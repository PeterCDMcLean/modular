module TwoDomains(
  input  wire       clk_run_a,
  input  wire       rst_run_a,
  input  wire       clk_run_b,
  input  wire       rst_run_b,
  output wire [7:0] run_a_out,
  output wire [7:0] run_b_out
);
  wire      [7:0] _GEN;
  wire      [7:0] _GEN_0;
  var logic [7:0] _GEN_1 = 8'h0;
  always @(posedge clk_run_a) begin
    if (rst_run_a) begin
      _GEN_1 <= 8'h0;
    end
    else begin
      _GEN_1 <= _GEN_0;
    end
  end
  assign _GEN_0 = _GEN_1 + 8'h1;
  var logic [7:0] _GEN_2 = 8'h0;
  always @(posedge clk_run_b) begin
    if (rst_run_b) begin
      _GEN_2 <= 8'h0;
    end
    else begin
      _GEN_2 <= _GEN;
    end
  end
  assign _GEN = _GEN_2 + 8'h2;
  assign run_a_out = _GEN_1;
  assign run_b_out = _GEN_2;
endmodule
