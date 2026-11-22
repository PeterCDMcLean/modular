module BitSelect(
  input  wire [11:0] a,
  output wire        out
);
  assign out = a[3];
endmodule
