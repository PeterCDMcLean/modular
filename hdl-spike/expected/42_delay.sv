module NextDelay(
  input  wire [7:0] din,
  input  wire       clk,
  input  wire       rst,
  output wire [7:0] out
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
      _GEN_0 <= _GEN;
    end
  end
  assign out = _GEN_0;
endmodule
module PastDelay(
  input  wire [7:0] din,
  input  wire       clk,
  input  wire       rst,
  output wire [7:0] out
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
      _GEN_0 <= _GEN;
    end
  end
  var logic [7:0] _GEN_1 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_1 <= 8'h0;
    end
    else begin
      _GEN_1 <= _GEN_0;
    end
  end
  assign out = _GEN_1;
endmodule
