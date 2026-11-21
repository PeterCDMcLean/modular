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
module MixedReset(
  input        clk_sync_step,
               rst_sync_step,
               clk_async_step,
               rst_async_step,
  output [7:0] sync_step_out,
               async_step_out
);
  wire      [7:0] _GEN;
  var logic [7:0] _GEN_0 = 8'h3;
  always @(posedge clk_sync_step) begin
    if (rst_sync_step)
      _GEN_0 <= 8'h3;
    else
      _GEN_0 <= _GEN;
  end
  assign _GEN = _GEN_0 + 8'h1;
  var logic [7:0] reg_1 = 8'h5;
  always @(posedge clk_async_step or posedge rst_async_step) begin
    if (rst_async_step)
      reg_1 <= 8'h5;
    else
      reg_1 <= reg_1 + 8'h1;
  end
  `ifdef ENABLE_INITIAL_REG_
    `ifdef FIRRTL_BEFORE_INITIAL
      `FIRRTL_BEFORE_INITIAL
    `endif
    initial begin
      if (rst_async_step)
        reg_1 = 8'h5;
    end
    `ifdef FIRRTL_AFTER_INITIAL
      `FIRRTL_AFTER_INITIAL
    `endif
  `endif
  assign sync_step_out = _GEN_0;
  assign async_step_out = reg_1;
endmodule
