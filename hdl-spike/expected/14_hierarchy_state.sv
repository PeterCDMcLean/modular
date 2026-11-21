module ChildCounter(
  input        en,
               clk,
               rst,
  output [7:0] out
);
  wire      [7:0] _GEN;
  var logic [7:0] _GEN_0 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_0 <= 8'h0;
    else
      _GEN_0 <= _GEN;
  end
  assign _GEN = en ? _GEN_0 + 8'h1 : _GEN_0;
  assign out = _GEN_0;
endmodule
module Parent(
  input        en,
               clk,
               rst,
  output [7:0] out
);
  ChildCounter child (
    .en  (en),
    .clk (clk),
    .rst (rst),
    .out (out)
  );
endmodule
