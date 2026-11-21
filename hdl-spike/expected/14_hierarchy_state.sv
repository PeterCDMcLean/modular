module ChildCounter(
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
