module LogicNextDelay(
  input  [7:0] din,
               din_xz,
  input        clk,
               rst,
  output [7:0] out,
               out_xz
);
  var logic [7:0] _GEN = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN <= 8'h0;
    else
      _GEN <= din;
  end
  var logic [7:0] _GEN_0 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_0 <= 8'h0;
    else
      _GEN_0 <= din_xz;
  end
  var logic [7:0] _GEN_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_1 <= 8'h0;
    else
      _GEN_1 <= _GEN;
  end
  var logic [7:0] _GEN_2 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_2 <= 8'h0;
    else
      _GEN_2 <= _GEN_0;
  end
  assign out = _GEN_1;
  assign out_xz = _GEN_2;
endmodule
module LogicPastDelay(
  input  [7:0] din,
               din_xz,
  input        clk,
               rst,
  output [7:0] out,
               out_xz
);
  var logic [7:0] _GEN = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN <= 8'h0;
    else
      _GEN <= din;
  end
  var logic [7:0] _GEN_0 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_0 <= 8'h0;
    else
      _GEN_0 <= din_xz;
  end
  var logic [7:0] _GEN_1 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_1 <= 8'h0;
    else
      _GEN_1 <= _GEN;
  end
  var logic [7:0] _GEN_2 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_2 <= 8'h0;
    else
      _GEN_2 <= _GEN_0;
  end
  var logic [7:0] _GEN_3 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_3 <= 8'h0;
    else
      _GEN_3 <= _GEN_1;
  end
  var logic [7:0] _GEN_4 = 8'h0;
  always @(posedge clk) begin
    if (rst)
      _GEN_4 <= 8'h0;
    else
      _GEN_4 <= _GEN_2;
  end
  assign out = _GEN_3;
  assign out_xz = _GEN_4;
endmodule
