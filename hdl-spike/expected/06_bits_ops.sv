module BitsOps(
  input  [11:0] a,
                b,
  output [11:0] out
);
  assign out = a & b ^ ~a | a - b + b;
endmodule
