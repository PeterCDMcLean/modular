module LogicStateOps(
  input  wire [7:0] d,
  input  wire [7:0] d_xz,
  input  wire       clk,
  input  wire       rst,
  output wire [7:0] out,
  output wire [7:0] out_xz
);
  wire      [7:0] _GEN;
  wire      [7:0] _GEN_0;
  var logic [7:0] _GEN_1 = 8'h5;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_1 <= 8'h5;
    end
    else begin
      _GEN_1 <= _GEN;
    end
  end
  var logic [7:0] _GEN_2 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_2 <= 8'h0;
    end
    else begin
      _GEN_2 <= _GEN_0;
    end
  end
  assign _GEN_0 = (_GEN_2 | d_xz) & (_GEN_2 | _GEN_1) & (d_xz | d);
  assign _GEN = ~(_GEN_1 & d);
  assign out = _GEN_1;
  assign out_xz = _GEN_2;
endmodule
