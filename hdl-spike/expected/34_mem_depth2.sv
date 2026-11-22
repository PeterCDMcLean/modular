module MemDepth2(
  input  wire [63:0] addr,
  input  wire [7:0]  wdata,
  input  wire        we,
  input  wire        clk,
  input  wire        rst,
  output wire [7:0]  out
);
  wire            _GEN;
  wire            _GEN_0;
  var logic [7:0] mem_0_0 = 8'h7;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_0 <= 8'h7;
    end
    else if (_GEN_0) begin
      mem_0_0 <= wdata;
    end
  end
  var logic [7:0] mem_0_1 = 8'h9;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_1 <= 8'h9;
    end
    else if (_GEN) begin
      mem_0_1 <= wdata;
    end
  end
  assign _GEN_0 = we & addr == 64'h0;
  assign _GEN = we & addr == 64'h1;
  assign out = addr == 64'h1 ? mem_0_1 : mem_0_0;
endmodule
