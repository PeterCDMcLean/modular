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
module MixedLogicReset(
  input  [7:0] d,
               d_xz,
               e,
               e_xz,
  input        clk_sync_step,
               rst_sync_step,
               clk_async_step,
               rst_async_step,
  output [7:0] sync_step_out,
               sync_step_out_xz,
               async_step_out,
               async_step_out_xz
);
  wire      [7:0] _GEN;
  wire      [7:0] _GEN_0;
  var logic [7:0] _GEN_1 = 8'h3;
  always @(posedge clk_sync_step) begin
    if (rst_sync_step)
      _GEN_1 <= 8'h3;
    else
      _GEN_1 <= _GEN;
  end
  var logic [7:0] _GEN_2 = 8'h0;
  always @(posedge clk_sync_step) begin
    if (rst_sync_step)
      _GEN_2 <= 8'h0;
    else
      _GEN_2 <= _GEN_0;
  end
  assign _GEN_0 = (_GEN_2 | d_xz) & (_GEN_2 | _GEN_1) & (d_xz | d);
  assign _GEN = ~(_GEN_1 & d);
  var logic [7:0] reg_2 = 8'h5;
  var logic [7:0] reg_3 = 8'h0;
  always @(posedge clk_async_step or posedge rst_async_step) begin
    if (rst_async_step) begin
      reg_2 <= 8'h5;
      reg_3 <= 8'h0;
    end
    else begin
      reg_2 <= ~(reg_2 & e);
      reg_3 <= (reg_3 | e_xz) & (reg_3 | reg_2) & (e_xz | e);
    end
  end
  `ifdef ENABLE_INITIAL_REG_
    `ifdef FIRRTL_BEFORE_INITIAL
      `FIRRTL_BEFORE_INITIAL
    `endif
    initial begin
      if (rst_async_step) begin
        reg_2 = 8'h5;
        reg_3 = 8'h0;
      end
    end
    `ifdef FIRRTL_AFTER_INITIAL
      `FIRRTL_AFTER_INITIAL
    `endif
  `endif
  assign sync_step_out = _GEN_1;
  assign sync_step_out_xz = _GEN_2;
  assign async_step_out = reg_2;
  assign async_step_out_xz = reg_3;
endmodule
