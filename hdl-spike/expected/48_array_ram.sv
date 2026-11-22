`ifndef RANDOMIZE
  `ifdef RANDOMIZE_REG_INIT
    `define RANDOMIZE
  `endif
`endif
`ifndef SYNTHESIS
  `ifndef ENABLE_INITIAL_REG_
    `define ENABLE_INITIAL_REG_
  `endif
`endif
`ifndef RANDOMIZE
  `ifdef RANDOMIZE_MEM_INIT
    `define RANDOMIZE
  `endif
`endif
`ifndef SYNTHESIS
  `ifndef ENABLE_INITIAL_MEM_
    `define ENABLE_INITIAL_MEM_
  `endif
`endif
`ifndef RANDOM
  `define RANDOM $random
`endif
`ifndef INIT_RANDOM
  `define INIT_RANDOM
`endif
`ifndef RANDOMIZE_DELAY
  `define RANDOMIZE_DELAY 0.002
`endif
`ifndef INIT_RANDOM_PROLOG_
  `ifdef RANDOMIZE
    `ifdef VERILATOR
      `define INIT_RANDOM_PROLOG_ `INIT_RANDOM
    `else
      `define INIT_RANDOM_PROLOG_ `INIT_RANDOM #`RANDOMIZE_DELAY begin end
    `endif
  `else
    `define INIT_RANDOM_PROLOG_
  `endif
`endif
module mem_4x8(
  input  [1:0] R0_addr,
  input        R0_en,
               R0_clk,
  output [7:0] R0_data,
  input  [1:0] W0_addr,
  input        W0_en,
               W0_clk,
  input  [7:0] W0_data
);
  var logic [7:0] Memory[0:3];
  always @(posedge W0_clk) begin
    if (W0_en)
      Memory[W0_addr] <= W0_data;
  end
  `ifdef ENABLE_INITIAL_MEM_
    var logic [31:0] _RANDOM_MEM;
    initial begin
      `INIT_RANDOM_PROLOG_
      `ifdef RANDOMIZE_MEM_INIT
        for (logic [2:0] i = 3'h0; i < 3'h4; i += 3'h1) begin
          _RANDOM_MEM = `RANDOM;
          Memory[i[1:0]] = _RANDOM_MEM[7:0];
        end
      `endif
    end
  `endif
  assign R0_data = R0_en ? Memory[R0_addr] : 8'bx;
endmodule
module ArrayRamDemo(
  input  [63:0] addr,
  input  [7:0]  wd,
  input         we,
                clk,
                rst,
  output [7:0]  out
);
  wire [1:0] _addr_1to0;
  mem_4x8 mem_ext (
    .R0_addr (_addr_1to0),
    .R0_en   (1'h1),
    .R0_clk  (clk),
    .R0_data (out),
    .W0_addr (addr[1:0]),
    .W0_en   (we),
    .W0_clk  (clk),
    .W0_data (wd)
  );
  assign _addr_1to0 = addr[1:0];
endmodule
