module LogicPackedGet(
  input  [31:0] p,
                p_xz,
  input  [63:0] i,
  output [7:0]  out,
                out_xz
);
  wire [31:0] _GEN = {i[28:0], 3'h0};
  wire [31:0] _GEN_0 = p >> _GEN;
  wire [31:0] _GEN_1 = p_xz >> _GEN;
  assign out = _GEN_0[7:0];
  assign out_xz = _GEN_1[7:0];
endmodule
module LogicPackedPass(
  input  [31:0] p,
                p_xz,
  input  [63:0] i,
  input  [7:0]  v,
                v_xz,
  output [31:0] out,
                out_xz
);
  wire [31:0] _GEN = {i[28:0], 3'h0};
  wire [31:0] _GEN_0 = 32'hFF << _GEN;
  assign out = p & ~_GEN_0 | {24'h0, v} << _GEN;
  assign out_xz = p_xz & ~_GEN_0 | {24'h0, v_xz} << _GEN;
endmodule
module LogicPackedReg(
  input  [31:0] din,
                din_xz,
  input         clk,
                rst,
  output [31:0] out,
                out_xz
);
  var logic [31:0] _GEN = 32'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN <= 32'h0;
    else
      _GEN <= din;
  end
  var logic [31:0] _GEN_0 = 32'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_0 <= 32'h0;
    else
      _GEN_0 <= din_xz;
  end
  assign out = _GEN;
  assign out_xz = _GEN_0;
endmodule
