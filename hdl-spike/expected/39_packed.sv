module PackedConstOut(
  output wire [31:0] out
);
  assign out = 32'h4030201;
endmodule
module PackedHold(
  input  wire [31:0] din,
  input  wire        clk,
  input  wire        rst,
  output wire [31:0] out
);
  var logic [31:0] _GEN = 32'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN <= 32'h0;
    end
    else begin
      _GEN <= din;
    end
  end
  assign out = _GEN;
endmodule
module PackedPass(
  input  wire [31:0] din,
  output wire [31:0] out
);
  assign out = din;
endmodule
