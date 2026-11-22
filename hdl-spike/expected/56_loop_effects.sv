module AccCell(
  input  wire [7:0] delta,
  input  wire       clk,
  input  wire       rst,
  output wire [7:0] out
);
  wire      [7:0] _GEN;
  var logic [7:0] _GEN_0 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_0 <= 8'h0;
    end
    else begin
      _GEN_0 <= _GEN;
    end
  end
  assign _GEN = _GEN_0 + delta;
  assign out = _GEN_0;
endmodule
module LoopMemWrite(
  input  wire [7:0] wd,
  input  wire       en,
  input  wire       clk,
  input  wire       rst,
  output wire [7:0] out
);
  var logic [7:0] mem_0_0 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_0 <= 8'h0;
    end
    else if (en) begin
      mem_0_0 <= wd;
    end
  end
  var logic [7:0] mem_0_1 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_1 <= 8'h0;
    end
    else if (en) begin
      mem_0_1 <= wd;
    end
  end
  var logic [7:0] mem_0_2 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_2 <= 8'h0;
    end
    else if (en) begin
      mem_0_2 <= wd;
    end
  end
  var logic [7:0] mem_0_3 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      mem_0_3 <= 8'h0;
    end
    else if (en) begin
      mem_0_3 <= wd;
    end
  end
  assign out = mem_0_2;
endmodule
module LoopSelectiveTick(
  input  wire [7:0] delta,
  input  wire       clk,
  input  wire       rst,
  output wire [7:0] out
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
    if (rst) begin
      _GEN <= 8'h0;
    end
    else begin
      _GEN <= _cell_out;
    end
  end
  assign out = _GEN;
endmodule
module LoopSum(
  input  wire [7:0] a,
  input  wire [7:0] b,
  output wire [7:0] out
);
  assign out = a + {b[5:0], 2'h0};
endmodule
module WhileSum(
  input  wire [7:0] a,
  input  wire [7:0] b,
  output wire [7:0] out
);
  assign out = a + {b[5:0], 2'h0};
endmodule
