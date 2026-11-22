module PowerOnCounter(
  input  wire       clk,
  input  wire       rst,
  output wire [7:0] out
);
  wire      [7:0] _GEN;
  var logic [7:0] _GEN_0 = 8'h9;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_0 <= 8'h5;
    end
    else begin
      _GEN_0 <= _GEN;
    end
  end
  assign _GEN = _GEN_0 + 8'h1;
  assign out = _GEN_0;
endmodule
