module LogicMem(
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
  wire            _GEN_1;
  wire            _GEN_2;
  var logic [7:0] mem_0_0 = 8'h1;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_0 <= 8'h1;
    end
    else if (_GEN_2) begin
      mem_0_0 <= wd;
    end
  end
  var logic [7:0] mem_0_0_xz = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_0_xz <= 8'h0;
    end
    else if (_GEN_2) begin
      mem_0_0_xz <= wd_xz;
    end
  end
  var logic [7:0] mem_0_1 = 8'h2;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_1 <= 8'h2;
    end
    else if (_GEN_1) begin
      mem_0_1 <= wd;
    end
  end
  var logic [7:0] mem_0_1_xz = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_1_xz <= 8'h0;
    end
    else if (_GEN_1) begin
      mem_0_1_xz <= wd_xz;
    end
  end
  var logic [7:0] mem_0_2 = 8'h3;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_2 <= 8'h3;
    end
    else if (_GEN_0) begin
      mem_0_2 <= wd;
    end
  end
  var logic [7:0] mem_0_2_xz = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_2_xz <= 8'h0;
    end
    else if (_GEN_0) begin
      mem_0_2_xz <= wd_xz;
    end
  end
  var logic [7:0] mem_0_3 = 8'h4;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_3 <= 8'h4;
    end
    else if (_GEN) begin
      mem_0_3 <= wd;
    end
  end
  var logic [7:0] mem_0_3_xz = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_3_xz <= 8'h0;
    end
    else if (_GEN) begin
      mem_0_3_xz <= wd_xz;
    end
  end
  assign _GEN_2 = we & addr == 64'h0;
  assign _GEN_1 = we & addr == 64'h1;
  assign _GEN_0 = we & addr == 64'h2;
  assign _GEN = we & addr == 64'h3;
  wire            _GEN_3 = addr == 64'h1;
  wire            _GEN_4 = addr == 64'h2;
  wire            _GEN_5 = addr == 64'h3;
  assign out = _GEN_5 ? mem_0_3 : _GEN_4 ? mem_0_2 : _GEN_3 ? mem_0_1 : mem_0_0;
  assign out_xz =
    _GEN_5 ? mem_0_3_xz : _GEN_4 ? mem_0_2_xz : _GEN_3 ? mem_0_1_xz : mem_0_0_xz;
endmodule
