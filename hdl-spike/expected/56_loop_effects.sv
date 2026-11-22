module AccCell(
  input  [7:0] delta,
  input        clk,
               rst,
  output [7:0] out
);
  wire      [7:0] _GEN;
  var logic [7:0] _GEN_0 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_0 <= 8'h0;
    else
      _GEN_0 <= _GEN;
  end
  assign _GEN = _GEN_0 + delta;
  assign out = _GEN_0;
endmodule
module LoopMemWrite(
  input  [7:0] wd,
  input        en,
               clk,
               rst,
  output [7:0] out
);
  var logic [7:0] mem_0_0 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_0 <= 8'h0;
    else if (en)
      mem_0_0 <= wd;
  end
  var logic [7:0] mem_0_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_1 <= 8'h0;
    else if (en)
      mem_0_1 <= wd;
  end
  var logic [7:0] mem_0_2 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_2 <= 8'h0;
    else if (en)
      mem_0_2 <= wd;
  end
  var logic [7:0] mem_0_3 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      mem_0_3 <= 8'h0;
    else if (en)
      mem_0_3 <= wd;
  end
  assign out = mem_0_2;
endmodule
module LoopSelectiveTick(
  input  [7:0] delta,
  input        clk,
               rst,
  output [7:0] out
);
  wire      [7:0] _cell_out;
  AccCell cell_0 (
    .delta (delta),
    .clk   (clk),
    .rst   (rst),
    .out   (_cell_out)
  );
  var logic [7:0] _GEN = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN <= 8'h0;
    else
      _GEN <= _cell_out;
  end
  assign out = _GEN;
endmodule
module LoopSum(
  input  [7:0] a,
               b,
  output [7:0] out
);
  assign out = a + {b[5:0], 2'h0};
endmodule
module WhileSum(
  input  [7:0] a,
               b,
  output [7:0] out
);
  assign out = a + {b[5:0], 2'h0};
endmodule
