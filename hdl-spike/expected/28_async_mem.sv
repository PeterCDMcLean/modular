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
module AsyncMem(
  input  [63:0] addr,
  input  [7:0]  wdata,
  input         we,
                clk,
                rst,
  output [7:0]  out
);
  var logic [7:0] mem_1_0 = 8'h5;
  var logic [7:0] mem_1_1 = 8'h5;
  var logic [7:0] mem_1_2 = 8'h5;
  var logic [7:0] mem_1_3 = 8'h5;
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      mem_1_0 <= 8'h5;
      mem_1_1 <= 8'h5;
      mem_1_2 <= 8'h5;
      mem_1_3 <= 8'h5;
    end
    else begin
      mem_1_0 <= we & addr == 64'h0 ? wdata : mem_1_0;
      mem_1_1 <= we & addr == 64'h1 ? wdata : mem_1_1;
      mem_1_2 <= we & addr == 64'h2 ? wdata : mem_1_2;
      mem_1_3 <= we & addr == 64'h3 ? wdata : mem_1_3;
    end
  end
  `ifdef ENABLE_INITIAL_REG_
    `ifdef FIRRTL_BEFORE_INITIAL
      `FIRRTL_BEFORE_INITIAL
    `endif
    initial begin
      if (rst) begin
        mem_1_0 = 8'h5;
        mem_1_1 = 8'h5;
        mem_1_2 = 8'h5;
        mem_1_3 = 8'h5;
      end
    end
    `ifdef FIRRTL_AFTER_INITIAL
      `FIRRTL_AFTER_INITIAL
    `endif
  `endif
  assign out =
    addr == 64'h3 ? mem_1_3 : addr == 64'h2 ? mem_1_2 : addr == 64'h1 ? mem_1_1 : mem_1_0;
endmodule
