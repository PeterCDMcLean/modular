module MemTop(
  input  wire [63:0] addr,
  input  wire [7:0]  wdata,
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
      mem_0_0 <= wdata;
    end
  end
  var logic [7:0] mem_0_1 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_1 <= 8'h0;
    end
    else if (_GEN_1) begin
      mem_0_1 <= wdata;
    end
  end
  var logic [7:0] mem_0_2 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_2 <= 8'h0;
    end
    else if (_GEN_0) begin
      mem_0_2 <= wdata;
    end
  end
  var logic [7:0] mem_0_3 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_3 <= 8'h0;
    end
    else if (_GEN) begin
      mem_0_3 <= wdata;
    end
  end
  assign _GEN_2 = we & addr == 64'h0;
  assign _GEN_1 = we & addr == 64'h1;
  assign _GEN_0 = we & addr == 64'h2;
  assign _GEN = we & addr == 64'h3;
  assign out =
    addr == 64'h3 ? mem_0_3 : addr == 64'h2 ? mem_0_2 : addr == 64'h1 ? mem_0_1 : mem_0_0;
endmodule
