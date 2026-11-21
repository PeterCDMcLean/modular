module BitSelect(
  input  [11:0] a,
  output        out
);
  assign out = a[3];
endmodule
