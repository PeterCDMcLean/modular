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
module AsyncLowChild(
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
module SyncHighChild(
  input  wire       clk,
  input  wire       rst,
  output wire [7:0] out
);
  wire      [7:0] _GEN;
  var logic [7:0] _GEN_0 = 8'h5;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_0 <= 8'h5;
    end
    else begin
      _GEN_0 <= _GEN;
    end
  end
  assign _GEN = _GEN_0 + 8'h1;
  assign out = _GEN_0;
endmodule
module ResetParentHigh(
  input  wire       clk,
  input  wire       rst,
  output wire [7:0] out
);
  wire [7:0] _b_out;
  wire [7:0] _a_out;
  AsyncLowChild a (
    .clk   (clk),
    .rst_n (~rst),
    .out   (_a_out)
  );
  SyncHighChild b (
    .clk (clk),
    .rst (rst),
    .out (_b_out)
  );
  assign out = _a_out ^ _b_out;
endmodule
module ResetParentLow(
  input  wire       clk,
  input  wire       rst_n,
  output wire [7:0] out
);
  wire [7:0] _b_out;
  wire [7:0] _a_out;
  AsyncLowChild a (
    .clk   (clk),
    .rst_n (rst_n),
    .out   (_a_out)
  );
  SyncHighChild b (
    .clk (clk),
    .rst (~rst_n),
    .out (_b_out)
  );
  assign out = _a_out ^ _b_out;
endmodule
