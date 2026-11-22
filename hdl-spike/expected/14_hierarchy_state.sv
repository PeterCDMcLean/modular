module ChildCounter(
  input  wire       en,
  input  wire       clk,
  input  wire       rst,
  output wire [7:0] out
);
  wire      [7:0] _GEN;
  var logic [7:0] reg_0 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      reg_0 <= 8'h0;
    end
    else if (en) begin
      reg_0 <= _GEN;
    end
  end
  assign _GEN = reg_0 + 8'h1;
  assign out = reg_0;
endmodule
module Parent(
  input  wire       en,
  input  wire       clk,
  input  wire       rst,
  output wire [7:0] out
);
  ChildCounter child (
    .en  (en),
    .clk (clk),
    .rst (rst),
    .out (out)
  );
endmodule
