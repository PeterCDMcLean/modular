module DirectArraySet(
  input  wire [63:0] i,
  input  wire [7:0]  v,
  input  wire        clk,
  input  wire        rst,
  output wire [7:0]  out
);
  wire            _GEN;
  wire            _GEN_0;
  var logic [7:0] mem_0_0 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_0 <= 8'h0;
    end
    else if (_GEN_0) begin
      mem_0_0 <= v;
    end
  end
  var logic [7:0] mem_0_1 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_1 <= 8'h0;
    end
    else if (_GEN) begin
      mem_0_1 <= v;
    end
  end
  assign _GEN_0 = i == 64'h0;
  assign _GEN = i == 64'h1;
  assign out = i == 64'h1 ? mem_0_1 : mem_0_0;
endmodule
module DirectLogicSet(
  input  wire [63:0] i,
  input  wire [7:0]  v,
  input  wire [7:0]  v_xz,
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
      mem_0_0 <= v;
    end
  end
  var logic [7:0] mem_0_0_xz = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_0_xz <= 8'h0;
    end
    else if (_GEN_0) begin
      mem_0_0_xz <= v_xz;
    end
  end
  var logic [7:0] mem_0_1 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_1 <= 8'h0;
    end
    else if (_GEN) begin
      mem_0_1 <= v;
    end
  end
  var logic [7:0] mem_0_1_xz = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_1_xz <= 8'h0;
    end
    else if (_GEN) begin
      mem_0_1_xz <= v_xz;
    end
  end
  assign _GEN_0 = i == 64'h0;
  assign _GEN = i == 64'h1;
  wire            _GEN_1 = i == 64'h1;
  assign out = _GEN_1 ? mem_0_1 : mem_0_0;
  assign out_xz = _GEN_1 ? mem_0_1_xz : mem_0_0_xz;
endmodule
module DirectStaticSet(
  input  wire [7:0] v,
  input  wire       clk,
  input  wire       rst,
  output wire [7:0] out
);
  var logic [7:0] mem_0_0 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_0 <= 8'h0;
    end
    else begin
      mem_0_0 <= v;
    end
  end
  var logic [7:0] mem_0_1 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_1 <= 8'h0;
    end
  end
  assign out = mem_0_0;
endmodule
