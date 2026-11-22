module RegDemo(
  input  wire       en,
  input  wire       clk,
  input  wire       rst,
  output wire [7:0] out
);
  wire      [7:0] _GEN;
  wire      [7:0] _GEN_0;
  var logic [7:0] _GEN_1 = 8'h3;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_1 <= 8'h3;
    end
    else begin
      _GEN_1 <= _GEN_0;
    end
  end
  assign _GEN_0 = _GEN_1 + 8'h1;
  var logic [7:0] reg_1 = 8'h1;
  always @(posedge clk) begin
    if (rst) begin
      reg_1 <= 8'h1;
    end
    else if (en) begin
      reg_1 <= _GEN;
    end
  end
  assign _GEN = reg_1 + 8'h2;
  assign out = _GEN_1 ^ reg_1;
endmodule
