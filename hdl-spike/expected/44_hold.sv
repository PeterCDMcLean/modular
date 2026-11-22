module PackedConstHold(
  input  wire        clk,
  input  wire        rst,
  output wire [31:0] out
);
  var logic [31:0] _GEN = 32'h4030201;
  always @(posedge clk) begin
    if (rst) begin
      _GEN <= 32'h4030201;
    end
    else begin
      _GEN <= _GEN;
    end
  end
  assign out = _GEN;
endmodule
module UnwrittenBits(
  input  wire       clk,
  input  wire       rst,
  output wire [7:0] out
);
  var logic [7:0] _GEN = 8'h7;
  always @(posedge clk) begin
    if (rst) begin
      _GEN <= 8'h7;
    end
    else begin
      _GEN <= _GEN;
    end
  end
  assign out = _GEN;
endmodule
