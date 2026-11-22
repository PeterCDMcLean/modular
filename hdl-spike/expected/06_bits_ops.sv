module BitsOps(
  input  wire [11:0] a,
  input  wire [11:0] b,
  output wire [11:0] out
);
  assign out = a & b ^ ~a | a - b + b;
endmodule
