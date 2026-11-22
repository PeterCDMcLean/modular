module EnableCounter(
  input  wire        en,
  input  wire        clk,
  input  wire        rst,
  output wire [11:0] out
);
  wire      [11:0] _GEN;
  var logic [11:0] reg_0 = 12'h0;
  always @(posedge clk) begin
    if (rst) begin
      reg_0 <= 12'h0;
    end
    else if (en) begin
      reg_0 <= _GEN;
    end
  end
  assign _GEN = reg_0 + 12'h1;
  assign out = reg_0;
endmodule
module EnableIfElse(
  input  wire       en,
  input  wire       clk,
  input  wire       rst,
  output wire [7:0] out
);
  wire      [7:0] _GEN;
  wire      [7:0] _GEN_0;
  var logic [7:0] _GEN_1 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_1 <= 8'h0;
    end
    else begin
      _GEN_1 <= _GEN;
    end
  end
  assign _GEN_0 = _GEN_1 + 8'h1;
  assign _GEN = ~en ? _GEN_1 + 8'h2 : en ? _GEN_0 : _GEN_1;
  assign out = _GEN_1;
endmodule
