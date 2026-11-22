module DivCounter(
  input  wire       clk,
  input  wire       rst,
  output wire [7:0] out
);
  wire      [7:0] _GEN;
  var logic       clock_out_0;
  always @(posedge clk) begin
    clock_out_0 = ~clock_out_0;
  end
  var logic       clock_out_1;
  always @(posedge clock_out_0) begin
    clock_out_1 = ~clock_out_1;
  end
  initial begin
    clock_out_0 = 1'h0;
    clock_out_1 = 1'h0;
  end
  var logic [7:0] _GEN_0 = 8'h0;
  always @(posedge clock_out_1) begin
    if (rst) begin
      _GEN_0 <= 8'h0;
    end
    else begin
      _GEN_0 <= _GEN;
    end
  end
  assign _GEN = _GEN_0 + 8'h1;
  assign out = _GEN_0;
endmodule
module ClockTop(
  input  wire       clk,
  input  wire       rst,
  output wire [7:0] out
);
  DivCounter child (
    .clk (clk),
    .rst (rst),
    .out (out)
  );
endmodule
