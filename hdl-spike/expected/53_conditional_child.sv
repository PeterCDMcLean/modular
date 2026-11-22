module AccCell(
  input  wire [7:0] delta,
  input  wire       clk,
  input  wire       rst,
  output wire [7:0] out
);
  wire      [7:0] _GEN;
  var logic [7:0] _GEN_0 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_0 <= 8'h0;
    end
    else begin
      _GEN_0 <= _GEN;
    end
  end
  assign _GEN = _GEN_0 + delta;
  assign out = _GEN_0;
endmodule
module ConditionalChain(
  input  wire       sel_a,
  input  wire       sel_b,
  input  wire [7:0] a,
  input  wire [7:0] b,
  input  wire [7:0] c,
  input  wire       clk,
  input  wire       rst,
  output wire [7:0] out
);
  wire      [7:0] _GEN;
  wire      [7:0] _GEN_0;
  wire      [7:0] _cell_out;
  AccCell cell_0 (
    .delta (_GEN_0),
    .clk   (clk),
    .rst   (rst),
    .out   (_cell_out)
  );
  var logic [7:0] _GEN_1 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_1 <= 8'h0;
    end
    else begin
      _GEN_1 <= _GEN;
    end
  end
  wire            _GEN_2 = ~sel_a;
  wire            _GEN_3 = _GEN_2 & sel_b;
  wire            _GEN_4 = _GEN_2 & ~sel_b;
  assign _GEN_0 = _GEN_4 ? c : _GEN_3 ? b : a;
  assign _GEN = _GEN_4 | _GEN_3 | sel_a ? _cell_out : _GEN_1;
  assign out = _GEN_1;
endmodule
module ConditionalTick(
  input  wire       sel,
  input  wire [7:0] a,
  input  wire [7:0] b,
  input  wire       clk,
  input  wire       rst,
  output wire [7:0] out
);
  wire      [7:0] _GEN;
  wire      [7:0] _cell_out;
  AccCell cell_0 (
    .delta (_GEN),
    .clk   (clk),
    .rst   (rst),
    .out   (_cell_out)
  );
  var logic [7:0] _GEN_0 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_0 <= 8'h0;
    end
    else begin
      _GEN_0 <= _cell_out;
    end
  end
  assign _GEN = ~sel ? b : a;
  assign out = _GEN_0;
endmodule
