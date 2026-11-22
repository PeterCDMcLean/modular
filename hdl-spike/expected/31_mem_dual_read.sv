module MemDualRead(
  input  wire [63:0] addr_a,
  input  wire [63:0] addr_b,
  input  wire        clk,
  input  wire        rst,
  output wire [7:0]  out
);
  var logic [7:0] mem_0_0 = 8'h1;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_0 <= 8'h1;
    end
  end
  var logic [7:0] mem_0_1 = 8'h2;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_1 <= 8'h2;
    end
  end
  var logic [7:0] mem_0_2 = 8'h3;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_2 <= 8'h3;
    end
  end
  var logic [7:0] mem_0_3 = 8'h4;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_3 <= 8'h4;
    end
  end
  assign out =
    (addr_a == 64'h3
       ? mem_0_3
       : addr_a == 64'h2 ? mem_0_2 : addr_a == 64'h1 ? mem_0_1 : mem_0_0)
    ^ (addr_b == 64'h3
         ? mem_0_3
         : addr_b == 64'h2 ? mem_0_2 : addr_b == 64'h1 ? mem_0_1 : mem_0_0);
endmodule
