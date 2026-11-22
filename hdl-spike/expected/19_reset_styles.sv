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
module AsyncHighCounter(
  input  wire       clk,
  input  wire       rst,
  output wire [7:0] out
);
  var logic [7:0] reg_1 = 8'h2;
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      reg_1 <= 8'h2;
    end
    else begin
      reg_1 <= reg_1 + 8'h1;
    end
  end
  `ifdef ENABLE_INITIAL_REG_
    `ifdef FIRRTL_BEFORE_INITIAL
      `FIRRTL_BEFORE_INITIAL
    `endif
    initial begin
      if (rst) begin
        reg_1 = 8'h2;
      end
    end
    `ifdef FIRRTL_AFTER_INITIAL
      `FIRRTL_AFTER_INITIAL
    `endif
  `endif
  assign out = reg_1;
endmodule
module AsyncLowCounter(
  input  wire       clk,
  input  wire       rst_n,
  output wire [7:0] out
);
  wire            _GEN = ~rst_n;
  var logic [7:0] reg_1 = 8'h3;
  always @(posedge clk or posedge _GEN) begin
    if (_GEN) begin
      reg_1 <= 8'h3;
    end
    else begin
      reg_1 <= reg_1 + 8'h1;
    end
  end
  `ifdef ENABLE_INITIAL_REG_
    `ifdef FIRRTL_BEFORE_INITIAL
      `FIRRTL_BEFORE_INITIAL
    `endif
    initial begin
      if (_GEN) begin
        reg_1 = 8'h3;
      end
    end
    `ifdef FIRRTL_AFTER_INITIAL
      `FIRRTL_AFTER_INITIAL
    `endif
  `endif
  assign out = reg_1;
endmodule
module SyncLowCounter(
  input  wire       clk,
  input  wire       rst_n,
  output wire [7:0] out
);
  wire      [7:0] _GEN;
  var logic [7:0] _GEN_0 = 8'h1;
  always @(posedge clk) begin
    if (~rst_n) begin
      _GEN_0 <= 8'h1;
    end
    else begin
      _GEN_0 <= _GEN;
    end
  end
  assign _GEN = _GEN_0 + 8'h1;
  assign out = _GEN_0;
endmodule
module ResetTop(
  input  wire       clk,
  input  wire       rst,
  output wire [7:0] out
);
  SyncLowCounter low (
    .clk   (clk),
    .rst_n (~rst),
    .out   (out)
  );
endmodule
