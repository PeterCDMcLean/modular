module BareArray(
  input  [63:0] addr,
  input  [7:0]  wd,
  input         we,
                clk,
                rst,
  output [7:0]  out
);
  wire            _GEN;
  wire            _GEN_0;
  wire            _GEN_1;
  wire            _GEN_2;
  var logic [7:0] mem_0_0 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_0 <= 8'h0;
    else if (_GEN_2)
      mem_0_0 <= wd;
  end
  var logic [7:0] mem_0_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_1 <= 8'h0;
    else if (_GEN_1)
      mem_0_1 <= wd;
  end
  var logic [7:0] mem_0_2 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_2 <= 8'h0;
    else if (_GEN_0)
      mem_0_2 <= wd;
  end
  var logic [7:0] mem_0_3 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_3 <= 8'h0;
    else if (_GEN)
      mem_0_3 <= wd;
  end
  assign _GEN_2 = we & addr == 64'h0;
  assign _GEN_1 = we & addr == 64'h1;
  assign _GEN_0 = we & addr == 64'h2;
  assign _GEN = we & addr == 64'h3;
  assign out =
    addr == 64'h3 ? mem_0_3 : addr == 64'h2 ? mem_0_2 : addr == 64'h1 ? mem_0_1 : mem_0_0;
endmodule
module LogicArray(
  input  [63:0] addr,
  input  [7:0]  wd,
                wd_xz,
  input         we,
                clk,
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
      mem_0_0 <= wd;
  end
  var logic [7:0] mem_0_0_xz = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_0_xz <= 8'h0;
    else if (_GEN_0)
      mem_0_0_xz <= wd_xz;
  end
  var logic [7:0] mem_0_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_1 <= 8'h0;
    else if (_GEN)
      mem_0_1 <= wd;
  end
  var logic [7:0] mem_0_1_xz = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_1_xz <= 8'h0;
    else if (_GEN)
      mem_0_1_xz <= wd_xz;
  end
  assign _GEN_0 = we & addr == 64'h0;
  assign _GEN = we & addr == 64'h1;
  wire            _GEN_1 = addr == 64'h1;
  assign out = _GEN_1 ? mem_0_1 : mem_0_0;
  assign out_xz = _GEN_1 ? mem_0_1_xz : mem_0_0_xz;
endmodule
module StaticArray(
  input  [7:0] wd,
  input        we,
               clk,
               rst,
  output [7:0] out
);
  var logic [7:0] mem_0_0 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_0 <= 8'h0;
    else if (we)
      mem_0_0 <= wd;
  end
  var logic [7:0] mem_0_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_1 <= 8'h0;
  end
  assign out = mem_0_1;
endmodule
