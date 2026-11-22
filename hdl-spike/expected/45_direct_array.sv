module DirectArraySet(
  input  [63:0] i,
  input  [7:0]  v,
  input         clk,
                rst,
  output [7:0]  out
);
  wire            _GEN;
  wire            _GEN_0;
  var logic [7:0] mem_0_0 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_0 <= 8'h0;
    else if (_GEN_0)
      mem_0_0 <= v;
  end
  var logic [7:0] mem_0_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_1 <= 8'h0;
    else if (_GEN)
      mem_0_1 <= v;
  end
  assign _GEN_0 = i == 64'h0;
  assign _GEN = i == 64'h1;
  assign out = i == 64'h1 ? mem_0_1 : mem_0_0;
endmodule
module DirectLogicSet(
  input  [63:0] i,
  input  [7:0]  v,
                v_xz,
  input         clk,
                rst,
  output [7:0]  out,
                out_xz
);
  wire            _GEN;
  wire            _GEN_0;
  var logic [7:0] mem_0_0 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_0 <= 8'h0;
    else if (_GEN_0)
      mem_0_0 <= v;
  end
  var logic [7:0] mem_0_0_xz = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_0_xz <= 8'h0;
    else if (_GEN_0)
      mem_0_0_xz <= v_xz;
  end
  var logic [7:0] mem_0_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_1 <= 8'h0;
    else if (_GEN)
      mem_0_1 <= v;
  end
  var logic [7:0] mem_0_1_xz = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_1_xz <= 8'h0;
    else if (_GEN)
      mem_0_1_xz <= v_xz;
  end
  assign _GEN_0 = i == 64'h0;
  assign _GEN = i == 64'h1;
  wire            _GEN_1 = i == 64'h1;
  assign out = _GEN_1 ? mem_0_1 : mem_0_0;
  assign out_xz = _GEN_1 ? mem_0_1_xz : mem_0_0_xz;
endmodule
module DirectStaticSet(
  input  [7:0] v,
  input        clk,
               rst,
  output [7:0] out
);
  var logic [7:0] mem_0_0 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_0 <= 8'h0;
    else
      mem_0_0 <= v;
  end
  var logic [7:0] mem_0_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_1 <= 8'h0;
  end
  assign out = mem_0_0;
endmodule
