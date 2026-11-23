module Passthrough
  #(parameter W = 8) (
  input  wire [W - 1:0] a,
  output wire [W - 1:0] out
);
  assign out = a;
endmodule
module Scaled
  #(parameter W = 8) (
  input  wire [W:0] a,
  output wire [W:0] out
);
  assign out = a;
endmodule
module ScaledUsers(
  input  wire [8:0]  si,
  input  wire [16:0] li,
  output wire [8:0]  run_small_out,
  output wire [16:0] run_large_out
);
  Scaled small_0 (
    .a   (si),
    .out (run_small_out)
  );
  Scaled #(
    .W(16)
  ) large_0 (
    .a   (li),
    .out (run_large_out)
  );
endmodule
module TwoWidths(
  input  wire [7:0]  ni,
  input  wire [15:0] wi,
  output wire [7:0]  run_narrow_out,
  output wire [15:0] run_wide_out
);
  Passthrough narrow (
    .a   (ni),
    .out (run_narrow_out)
  );
  Passthrough #(
    .W(16)
  ) wide (
    .a   (wi),
    .out (run_wide_out)
  );
endmodule
