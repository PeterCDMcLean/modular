module LogicNextDelay(
  input  wire [7:0] din,
  input  wire [7:0] din_xz,
  input  wire       clk,
  input  wire       rst,
  output wire [7:0] out,
  output wire [7:0] out_xz
);
  var logic [7:0] _GEN = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN <= 8'h0;
    end
    else begin
      _GEN <= din;
    end
  end
  var logic [7:0] _GEN_0 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_0 <= 8'h0;
    end
    else begin
      _GEN_0 <= din_xz;
    end
  end
  var logic [7:0] _GEN_1 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_1 <= 8'h0;
    end
    else begin
      _GEN_1 <= _GEN;
    end
  end
  var logic [7:0] _GEN_2 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_2 <= 8'h0;
    end
    else begin
      _GEN_2 <= _GEN_0;
    end
  end
  assign out = _GEN_1;
  assign out_xz = _GEN_2;
endmodule
module LogicPastDelay(
  input  wire [7:0] din,
  input  wire [7:0] din_xz,
  input  wire       clk,
  input  wire       rst,
  output wire [7:0] out,
  output wire [7:0] out_xz
);
  var logic [7:0] _GEN = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN <= 8'h0;
    end
    else begin
      _GEN <= din;
    end
  end
  var logic [7:0] _GEN_0 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_0 <= 8'h0;
    end
    else begin
      _GEN_0 <= din_xz;
    end
  end
  var logic [7:0] _GEN_1 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_1 <= 8'h0;
    end
    else begin
      _GEN_1 <= _GEN;
    end
  end
  var logic [7:0] _GEN_2 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_2 <= 8'h0;
    end
    else begin
      _GEN_2 <= _GEN_0;
    end
  end
  var logic [7:0] _GEN_3 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_3 <= 8'h0;
    end
    else begin
      _GEN_3 <= _GEN_1;
    end
  end
  var logic [7:0] _GEN_4 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_4 <= 8'h0;
    end
    else begin
      _GEN_4 <= _GEN_2;
    end
  end
  assign out = _GEN_3;
  assign out_xz = _GEN_4;
endmodule
