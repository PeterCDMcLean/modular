module TwoIndependentMems(
  input  [7:0] wd_a,
  input        en_a,
  input  [7:0] wd_b,
  input        en_b,
               clk_run_a,
               rst_run_a,
               clk_run_b,
               rst_run_b,
  output [7:0] run_a_out,
               run_b_out
);
  wire      [7:0] _GEN;
  wire      [7:0] _GEN_0;
  var logic [7:0] mem_0_0 = 8'h0;
  always @(posedge clk_run_a) begin
    if (rst_run_a)
      mem_0_0 <= 8'h0;
    else if (en_a)
      mem_0_0 <= wd_a;
  end
  var logic [7:0] mem_0_1 = 8'h0;
  always @(posedge clk_run_a) begin
    if (rst_run_a)
      mem_0_1 <= 8'h0;
  end
  var logic [7:0] mem_0_2 = 8'h0;
  always @(posedge clk_run_a) begin
    if (rst_run_a)
      mem_0_2 <= 8'h0;
  end
  var logic [7:0] mem_0_3 = 8'h0;
  always @(posedge clk_run_a) begin
    if (rst_run_a)
      mem_0_3 <= 8'h0;
  end
  var logic [7:0] _GEN_1 = 8'h0;
  always @(posedge clk_run_a) begin
    if (rst_run_a)
      _GEN_1 <= 8'h0;
    else
      _GEN_1 <= _GEN_0;
  end
  assign _GEN_0 = _GEN_1 + 8'h1;
  var logic [7:0] mem_1_0 = 8'h0;
  always @(posedge clk_run_b) begin
    if (rst_run_b)
      mem_1_0 <= 8'h0;
    else if (en_b)
      mem_1_0 <= wd_b;
  end
  var logic [7:0] mem_1_1 = 8'h0;
  always @(posedge clk_run_b) begin
    if (rst_run_b)
      mem_1_1 <= 8'h0;
  end
  var logic [7:0] mem_1_2 = 8'h0;
  always @(posedge clk_run_b) begin
    if (rst_run_b)
      mem_1_2 <= 8'h0;
  end
  var logic [7:0] mem_1_3 = 8'h0;
  always @(posedge clk_run_b) begin
    if (rst_run_b)
      mem_1_3 <= 8'h0;
  end
  var logic [7:0] _GEN_2 = 8'h0;
  always @(posedge clk_run_b) begin
    if (rst_run_b)
      _GEN_2 <= 8'h0;
    else
      _GEN_2 <= _GEN;
  end
  assign _GEN = _GEN_2 + 8'h2;
  assign run_a_out = mem_0_0 ^ _GEN_1;
  assign run_b_out = mem_1_0 ^ _GEN_2;
endmodule
