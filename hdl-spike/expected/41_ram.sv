module RamDemo(
  input  wire [63:0] addr,
  input  wire [7:0]  wd,
  input  wire        we,
  input  wire        clk,
  input  wire        rst,
  output wire [7:0]  out
);
  var logic [7:0] ram_0[0:3];
  always_ff @(posedge clk) begin
    if (rst) begin
    end
    else begin
      if (we) begin
        ram_0[addr[1:0]] <= wd;
      end
    end
  end
  assign out = ram_0[addr[1:0]];
endmodule
