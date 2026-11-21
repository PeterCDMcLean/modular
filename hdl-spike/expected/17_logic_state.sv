module LogicStateOps(
  input  [7:0] d,
               d_xz,
  input        clk,
               rst,
  output [7:0] out,
               out_xz
);
  wire      [7:0] _GEN;
  wire      [7:0] _GEN_0;
  var logic [7:0] _GEN_1 = 8'h5;
  always @(posedge clk) begin
    if (rst)
      _GEN_1 <= 8'h5;
    else
      _GEN_1 <= _GEN;
  end
  var logic [7:0] _GEN_2 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_2 <= 8'h0;
    else
      _GEN_2 <= _GEN_0;
  end
  assign _GEN_0 = (_GEN_2 | d_xz) & (_GEN_2 | _GEN_1) & (d_xz | d);
  assign _GEN = ~(_GEN_1 & d);
  assign out = _GEN_1;
  assign out_xz = _GEN_2;
endmodule
