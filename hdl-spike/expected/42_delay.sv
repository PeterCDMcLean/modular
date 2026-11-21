module NextDelay(
  input  [7:0] din,
  input        clk,
               rst,
  output [7:0] out
);
  var logic [7:0] _GEN = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN <= 8'h0;
    else
      _GEN <= din;
  end
  var logic [7:0] _GEN_0 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_0 <= 8'h0;
    else
      _GEN_0 <= _GEN;
  end
  assign out = _GEN_0;
endmodule
module PastDelay(
  input  [7:0] din,
  input        clk,
               rst,
  output [7:0] out
);
  var logic [7:0] _GEN = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN <= 8'h0;
    else
      _GEN <= din;
  end
  var logic [7:0] _GEN_0 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_0 <= 8'h0;
    else
      _GEN_0 <= _GEN;
  end
  var logic [7:0] _GEN_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_1 <= 8'h0;
    else
      _GEN_1 <= _GEN_0;
  end
  assign out = _GEN_1;
endmodule
