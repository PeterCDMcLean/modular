module TwoIndependentMems(
  input  wire [7:0] wd_a,
  input  wire       en_a,
  input  wire [7:0] wd_b,
  input  wire       en_b,
  input  wire       clk_run_a,
  input  wire       rst_run_a,
  input  wire       clk_run_b,
  input  wire       rst_run_b,
  output wire [7:0] run_a_out,
  output wire [7:0] run_b_out
);
  wire      [7:0] _GEN;
  wire      [7:0] _GEN_0;
  var logic [7:0] mem_0_0 = 8'h0;
  always @(posedge clk_run_a) begin
    if (rst_run_a) begin
      mem_0_0 <= 8'h0;
    end
    else if (en_a) begin
      mem_0_0 <= wd_a;
    end
  end
  var logic [7:0] mem_0_1 = 8'h0;
  always @(posedge clk_run_a) begin
    if (rst_run_a) begin
      mem_0_1 <= 8'h0;
    end
  end
  var logic [7:0] mem_0_2 = 8'h0;
  always @(posedge clk_run_a) begin
    if (rst_run_a) begin
      mem_0_2 <= 8'h0;
    end
  end
  var logic [7:0] mem_0_3 = 8'h0;
  always @(posedge clk_run_a) begin
    if (rst_run_a) begin
      mem_0_3 <= 8'h0;
    end
  end
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
  var logic [7:0] mem_1_0 = 8'h0;
  always @(posedge clk_run_b) begin
    if (rst_run_b) begin
      mem_1_0 <= 8'h0;
    end
    else if (en_b) begin
      mem_1_0 <= wd_b;
    end
  end
  var logic [7:0] mem_1_1 = 8'h0;
  always @(posedge clk_run_b) begin
    if (rst_run_b) begin
      mem_1_1 <= 8'h0;
    end
  end
  var logic [7:0] mem_1_2 = 8'h0;
  always @(posedge clk_run_b) begin
    if (rst_run_b) begin
      mem_1_2 <= 8'h0;
    end
  end
  var logic [7:0] mem_1_3 = 8'h0;
  always @(posedge clk_run_b) begin
    if (rst_run_b) begin
      mem_1_3 <= 8'h0;
    end
  end
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
  assign run_a_out = mem_0_0 ^ _GEN_1;
  assign run_b_out = mem_1_0 ^ _GEN_2;
endmodule
