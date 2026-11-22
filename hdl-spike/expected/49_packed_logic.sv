module LogicPackedGet(
  input  wire [31:0] p,
  input  wire [31:0] p_xz,
  input  wire [63:0] i,
  output wire [7:0]  out,
  output wire [7:0]  out_xz
);
  wire [31:0] _GEN = {i[28:0], 3'h0};
  wire [31:0] _GEN_0 = p >> _GEN;
  wire [31:0] _GEN_1 = p_xz >> _GEN;
  assign out = _GEN_0[7:0];
  assign out_xz = _GEN_1[7:0];
endmodule
module LogicPackedPass(
  input  wire [31:0] p,
  input  wire [31:0] p_xz,
  input  wire [63:0] i,
  input  wire [7:0]  v,
  input  wire [7:0]  v_xz,
  output wire [31:0] out,
  output wire [31:0] out_xz
);
  wire [31:0] _GEN = {i[28:0], 3'h0};
  wire [31:0] _GEN_0 = 32'hFF << _GEN;
  assign out = p & ~_GEN_0 | {24'h0, v} << _GEN;
  assign out_xz = p_xz & ~_GEN_0 | {24'h0, v_xz} << _GEN;
endmodule
module LogicPackedReg(
  input  wire [31:0] din,
  input  wire [31:0] din_xz,
  input  wire        clk,
  input  wire        rst,
  output wire [31:0] out,
  output wire [31:0] out_xz
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
  var logic [31:0] _GEN_0 = 32'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_0 <= 32'h0;
    end
    else begin
      _GEN_0 <= din_xz;
    end
  end
  assign out = _GEN;
  assign out_xz = _GEN_0;
endmodule
