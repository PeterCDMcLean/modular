typedef struct packed {
  integer f1;
  integer f0;
} hdl_PackedLimits;
typedef struct {
  integer f1;
  integer f0;
} hdl_Limits;
function automatic integer hdl_clamp_packed(input integer a0, input hdl_PackedLimits a1);
  if ((a0 < a1.f0)) begin
    return a1.f0;
  end
  if ((a0 > a1.f1)) begin
    return a1.f1;
  end
  return a0;
endfunction
function automatic integer hdl_clamp_to(input integer a0, input hdl_Limits a1);
  if ((a0 < a1.f0)) begin
    return a1.f0;
  end
  if ((a0 > a1.f1)) begin
    return a1.f1;
  end
  return a0;
endfunction
module ClampedPacked
  #(parameter /*integer*/ W) (
  input  wire [hdl_clamp_packed(W, hdl_PackedLimits'{f0: 4, f1: 32}) - 1:0] a,
  output wire [hdl_clamp_packed(W, hdl_PackedLimits'{f0: 4, f1: 32}) - 1:0] out
);
  assign out = a;
endmodule
module ClampedUnpacked
  #(parameter /*integer*/ W) (
  input  wire [hdl_clamp_to(W, hdl_Limits'{f0: 16, f1: 64}) - 1:0] a,
  output wire [hdl_clamp_to(W, hdl_Limits'{f0: 16, f1: 64}) - 1:0] out
);
  assign out = a;
endmodule
