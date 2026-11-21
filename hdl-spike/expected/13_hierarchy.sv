module Inverter(
  input  [7:0] a,
  output [7:0] out
);
  assign out = ~a;
endmodule
module Top(
  input  [7:0] a,
  output [7:0] out
);
  Inverter inv (
    .a   (a),
    .out (out)
  );
endmodule
