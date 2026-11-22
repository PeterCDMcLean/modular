module BareArray(
  input  wire [63:0] addr,
  input  wire [7:0]  wd,
  input  wire        we,
  input  wire        clk,
  input  wire        rst,
  output wire [7:0]  out
);
  wire            _GEN;
  wire            _GEN_0;
  wire            _GEN_1;
  wire            _GEN_2;
  var logic [7:0] mem_0_0 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_0 <= 8'h0;
    end
    else if (_GEN_2) begin
      mem_0_0 <= wd;
    end
  end
  var logic [7:0] mem_0_1 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_1 <= 8'h0;
    end
    else if (_GEN_1) begin
      mem_0_1 <= wd;
    end
  end
  var logic [7:0] mem_0_2 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_2 <= 8'h0;
    end
    else if (_GEN_0) begin
      mem_0_2 <= wd;
    end
  end
  var logic [7:0] mem_0_3 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_3 <= 8'h0;
    end
    else if (_GEN) begin
      mem_0_3 <= wd;
    end
  end
  assign _GEN_2 = we & addr == 64'h0;
  assign _GEN_1 = we & addr == 64'h1;
  assign _GEN_0 = we & addr == 64'h2;
  assign _GEN = we & addr == 64'h3;
  assign out =
    addr == 64'h3 ? mem_0_3 : addr == 64'h2 ? mem_0_2 : addr == 64'h1 ? mem_0_1 : mem_0_0;
endmodule
module LogicArray(
  input  wire [63:0] addr,
  input  wire [7:0]  wd,
  input  wire [7:0]  wd_xz,
  input  wire        we,
  input  wire        clk,
  input  wire        rst,
  output wire [7:0]  out,
  output wire [7:0]  out_xz
);
  wire            _GEN;
  wire            _GEN_0;
  var logic [7:0] mem_0_0 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_0 <= 8'h0;
    end
    else if (_GEN_0) begin
      mem_0_0 <= wd;
    end
  end
  var logic [7:0] mem_0_0_xz = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_0_xz <= 8'h0;
    end
    else if (_GEN_0) begin
      mem_0_0_xz <= wd_xz;
    end
  end
  var logic [7:0] mem_0_1 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_1 <= 8'h0;
    end
    else if (_GEN) begin
      mem_0_1 <= wd;
    end
  end
  var logic [7:0] mem_0_1_xz = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_1_xz <= 8'h0;
    end
    else if (_GEN) begin
      mem_0_1_xz <= wd_xz;
    end
  end
  assign _GEN_0 = we & addr == 64'h0;
  assign _GEN = we & addr == 64'h1;
  wire            _GEN_1 = addr == 64'h1;
  assign out = _GEN_1 ? mem_0_1 : mem_0_0;
  assign out_xz = _GEN_1 ? mem_0_1_xz : mem_0_0_xz;
endmodule
module StaticArray(
  input  wire [7:0] wd,
  input  wire       we,
  input  wire       clk,
  input  wire       rst,
  output wire [7:0] out
);
  var logic [7:0] mem_0_0 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_0 <= 8'h0;
    end
    else if (we) begin
      mem_0_0 <= wd;
    end
  end
  var logic [7:0] mem_0_1 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_1 <= 8'h0;
    end
  end
  assign out = mem_0_1;
endmodule
