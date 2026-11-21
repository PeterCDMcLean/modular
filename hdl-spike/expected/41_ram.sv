module RamDemo(
  input  [63:0] addr,
  input  [7:0]  wd,
  input         we,
                clk,
                rst,
  output [7:0]  out
);
  var logic [7:0] ram_0[0:3];
  always_ff @(posedge clk) begin
    if (rst) begin
    end
    else begin
      if (we)
        ram_0[addr[1:0]] <= wd;
    end
  end
  assign out = ram_0[addr[1:0]];
endmodule
