module ArrayElem(
  input  wire [31:0] a,
  input  wire [63:0] i,
  output wire [7:0]  out
);
  wire [31:0] _GEN = a >> {i[28:0], 3'h0};
  assign out = _GEN[7:0];
endmodule
module ArrayField(
  input  wire [63:0] i,
  input  wire [7:0]  v,
  input  wire        clk,
  input  wire        rst,
  output wire [7:0]  out
);
  wire      [31:0] _GEN;
  var logic [31:0] _GEN_0 = 32'h4030201;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_0 <= 32'h4030201;
    end
    else begin
      _GEN_0 <= _GEN;
    end
  end
  wire      [31:0] _GEN_1 = {i[28:0], 3'h0};
  assign _GEN = _GEN_0 & ~(32'hFF << _GEN_1) | {24'h0, v} << _GEN_1;
  assign out = _GEN_0[7:0];
endmodule
module ArrayPass(
  input  wire [31:0] a,
  output wire [31:0] out
);
  assign out = a;
endmodule
module ArrayReg(
  input  wire [31:0] a,
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
      _GEN <= a;
    end
  end
  assign out = _GEN;
endmodule
module ArrayUpdate(
  input  wire [31:0] a,
  input  wire [63:0] i,
  input  wire [7:0]  v,
  output wire [31:0] out
);
  wire [31:0] _GEN = {i[28:0], 3'h0};
  assign out = a & ~(32'hFF << _GEN) | {24'h0, v} << _GEN;
endmodule
module LogicArrayField(
  input  wire [7:0] v,
  input  wire [7:0] v_xz,
  input  wire       clk,
  input  wire       rst,
  output wire [7:0] out,
  output wire [7:0] out_xz
);
  wire      [31:0] _GEN;
  wire      [31:0] _GEN_0;
  var logic [31:0] _GEN_1 = 32'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_1 <= 32'h0;
    end
    else begin
      _GEN_1 <= _GEN_0;
    end
  end
  var logic [31:0] _GEN_2 = 32'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_2 <= 32'h0;
    end
    else begin
      _GEN_2 <= _GEN;
    end
  end
  assign _GEN_0 = _GEN_1 & 32'hFFFF00FF | {16'h0, v, 8'h0};
  assign _GEN = _GEN_2 & 32'hFFFF00FF | {16'h0, v_xz, 8'h0};
  assign out = _GEN_1[23:16];
  assign out_xz = _GEN_2[23:16];
endmodule
module LogicArrayPass(
  input  wire [31:0] a,
  input  wire [31:0] a_xz,
  output wire [31:0] out,
  output wire [31:0] out_xz
);
  assign out = a;
  assign out_xz = a_xz;
endmodule
