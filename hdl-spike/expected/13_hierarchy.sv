module Inverter(
  input  wire [7:0] a,
  output wire [7:0] out
);
  assign out = ~a;
endmodule
module Top(
  input  wire [7:0] a,
  output wire [7:0] out
);
  Inverter inv (
    .a   (a),
    .out (out)
  );
endmodule
