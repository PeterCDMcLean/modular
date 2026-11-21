module MemDepth2(
  input  [63:0] addr,
  input  [7:0]  wdata,
  input         we,
                clk,
                rst,
  output [7:0]  out
);
  wire            _GEN;
  wire            _GEN_0;
  var logic [7:0] mem_0_0 = 8'h7;
  always @(posedge clk) begin
    if (rst)
      mem_0_0 <= 8'h7;
    else if (_GEN_0)
      mem_0_0 <= wdata;
  end
  var logic [7:0] mem_0_1 = 8'h9;
  always @(posedge clk) begin
    if (rst)
      mem_0_1 <= 8'h9;
    else if (_GEN)
      mem_0_1 <= wdata;
  end
  assign _GEN_0 = we & addr == 64'h0;
  assign _GEN = we & addr == 64'h1;
  assign out = addr == 64'h1 ? mem_0_1 : mem_0_0;
endmodule
