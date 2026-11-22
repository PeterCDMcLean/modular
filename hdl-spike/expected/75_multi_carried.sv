module MultiCarriedSequence(
  input  wire [63:0] n,
  input  wire [63:0] m,
  input  wire [7:0]  wa,
  input  wire [7:0]  wa_xz,
  input  wire [7:0]  wb,
  input  wire [7:0]  wb_xz,
  input  wire        clk,
  input  wire        rst,
  output wire [7:0]  out,
  output wire [7:0]  out_xz
);
  wire      [7:0]  _GEN;
  wire      [7:0]  _GEN_0;
  wire      [7:0]  _GEN_1;
  wire      [7:0]  _GEN_2;
  wire      [7:0]  _GEN_3;
  wire      [7:0]  _GEN_4;
  wire      [7:0]  _GEN_5;
  wire      [7:0]  _GEN_6;
  wire      [7:0]  _GEN_7;
  wire      [7:0]  _GEN_8;
  wire      [63:0] _GEN_9;
  wire             _GEN_10;
  wire             _GEN_11;
  wire             _GEN_12;
  wire      [63:0] _GEN_13;
  wire      [7:0]  _GEN_14;
  wire      [7:0]  _GEN_15;
  wire      [7:0]  _GEN_16;
  wire      [7:0]  _GEN_17;
  wire      [7:0]  _GEN_18;
  wire      [7:0]  _GEN_19;
  var logic [63:0] _GEN_20 = 64'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_20 <= 64'h0;
    end
    else begin
      _GEN_20 <= _GEN_9;
    end
  end
  var logic        _GEN_21 = 1'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_21 <= 1'h0;
    end
    else begin
      _GEN_21 <= _GEN_10;
    end
  end
  var logic [7:0]  _GEN_22 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_22 <= 8'h0;
    end
    else begin
      _GEN_22 <= _GEN_6;
    end
  end
  var logic [7:0]  _GEN_23 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_23 <= 8'h0;
    end
    else begin
      _GEN_23 <= _GEN_5;
    end
  end
  var logic [7:0]  _GEN_24 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_24 <= 8'h0;
    end
    else begin
      _GEN_24 <= _GEN_4;
    end
  end
  var logic [7:0]  _GEN_25 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_25 <= 8'h0;
    end
    else begin
      _GEN_25 <= _GEN_3;
    end
  end
  var logic [7:0]  _GEN_26 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_26 <= 8'h0;
    end
    else begin
      _GEN_26 <= _GEN_8;
    end
  end
  var logic [7:0]  _GEN_27 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_27 <= 8'h0;
    end
    else begin
      _GEN_27 <= _GEN_7;
    end
  end
  wire             _GEN_28 = _GEN_21 & _GEN_20 < n;
  wire      [63:0] _GEN_29 = _GEN_20 + 64'h1;
  var logic        _GEN_30 = 1'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_30 <= 1'h0;
    end
    else begin
      _GEN_30 <= _GEN_28 & _GEN_29 == n;
    end
  end
  var logic [63:0] _GEN_31 = 64'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_31 <= 64'h0;
    end
    else begin
      _GEN_31 <= _GEN_13;
    end
  end
  var logic        _GEN_32 = 1'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_32 <= 1'h0;
    end
    else begin
      _GEN_32 <= _GEN_12;
    end
  end
  var logic        _GEN_33 = 1'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_33 <= 1'h0;
    end
    else begin
      _GEN_33 <= _GEN_11;
    end
  end
  var logic [7:0]  _GEN_34 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_34 <= 8'h0;
    end
    else begin
      _GEN_34 <= _GEN_19;
    end
  end
  var logic [7:0]  _GEN_35 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_35 <= 8'h0;
    end
    else begin
      _GEN_35 <= _GEN_18;
    end
  end
  var logic [7:0]  _GEN_36 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_36 <= 8'h0;
    end
    else begin
      _GEN_36 <= _GEN_17;
    end
  end
  var logic [7:0]  _GEN_37 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_37 <= 8'h0;
    end
    else begin
      _GEN_37 <= _GEN_16;
    end
  end
  var logic [7:0]  _GEN_38 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_38 <= 8'h0;
    end
    else begin
      _GEN_38 <= _GEN_15;
    end
  end
  var logic [7:0]  _GEN_39 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_39 <= 8'h0;
    end
    else begin
      _GEN_39 <= _GEN_14;
    end
  end
  wire             _GEN_40 = _GEN_32 & _GEN_33 & _GEN_31 < m;
  assign _GEN_19 = _GEN_33 ? {8{_GEN_40}} & wa | _GEN_34 : _GEN_22;
  assign _GEN_18 =
    _GEN_33
      ? (_GEN_40 ? (_GEN_35 | wa_xz) & (_GEN_35 | ~_GEN_34) & (wa_xz | ~wa) : _GEN_35)
      : _GEN_23;
  assign _GEN_17 = _GEN_33 ? ({8{~_GEN_40}} | wb) & _GEN_36 : _GEN_24;
  assign _GEN_16 =
    _GEN_33
      ? (_GEN_40 ? (_GEN_37 | wb_xz) & (_GEN_37 | _GEN_36) & (wb_xz | wb) : _GEN_37)
      : _GEN_25;
  assign _GEN_15 = _GEN_33 ? (_GEN_40 ? _GEN_38 + 8'h1 : _GEN_38) : _GEN_26;
  assign _GEN_14 = _GEN_33 ? (_GEN_40 ? _GEN_39 + 8'h2 : _GEN_39) : _GEN_27;
  wire      [63:0] _GEN_41 = _GEN_31 + 64'h1;
  wire             _GEN_42 = _GEN_40 & _GEN_41 == m;
  assign _GEN_13 = _GEN_40 ? _GEN_41 : 64'h0;
  assign _GEN_12 = _GEN_30 | ~_GEN_42 & _GEN_32;
  var logic        _GEN_43 = 1'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_43 <= 1'h0;
    end
    else begin
      _GEN_43 <= _GEN_42;
    end
  end
  assign _GEN_11 = _GEN_32 & (~_GEN_33 | ~_GEN_42);
  assign _GEN_10 = ~_GEN_43;
  assign _GEN_9 = _GEN_43 ? 64'h0 : _GEN_28 ? _GEN_29 : _GEN_20;
  assign _GEN_8 = _GEN_43 | ~_GEN_21 ? 8'h0 : _GEN_28 ? _GEN_26 + 8'h1 : _GEN_26;
  assign _GEN_7 = _GEN_43 | ~_GEN_21 ? 8'h3 : _GEN_28 ? _GEN_27 + 8'h2 : _GEN_27;
  assign _GEN_6 = _GEN_43 | ~_GEN_21 ? wa : {8{_GEN_28}} & wa | _GEN_22;
  assign _GEN_5 =
    _GEN_43 | ~_GEN_21
      ? wa_xz
      : _GEN_28 ? (_GEN_23 | wa_xz) & (_GEN_23 | ~_GEN_22) & (wa_xz | ~wa) : _GEN_23;
  assign _GEN_4 = _GEN_43 | ~_GEN_21 ? wb : ({8{~_GEN_28}} | wb) & _GEN_24;
  assign _GEN_3 =
    _GEN_43 | ~_GEN_21
      ? wb_xz
      : _GEN_28 ? (_GEN_25 | wb_xz) & (_GEN_25 | _GEN_24) & (wb_xz | wb) : _GEN_25;
  var logic [7:0]  _GEN_44 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_44 <= 8'h0;
    end
    else begin
      _GEN_44 <= _GEN_2;
    end
  end
  var logic [7:0]  _GEN_45 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_45 <= 8'h0;
    end
    else begin
      _GEN_45 <= _GEN_1;
    end
  end
  assign _GEN_2 = _GEN_43 ? _GEN_34 : _GEN_44;
  assign _GEN_1 = _GEN_43 ? _GEN_35 : _GEN_45;
  var logic [7:0]  _GEN_46 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_46 <= 8'h0;
    end
    else begin
      _GEN_46 <= _GEN_0;
    end
  end
  var logic [7:0]  _GEN_47 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      _GEN_47 <= 8'h0;
    end
    else begin
      _GEN_47 <= _GEN;
    end
  end
  assign _GEN_0 = _GEN_43 ? _GEN_36 : _GEN_46;
  assign _GEN = _GEN_43 ? _GEN_37 : _GEN_47;
  var logic [7:0]  reg_2 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      reg_2 <= 8'h0;
    end
    else if (_GEN_43) begin
      reg_2 <= _GEN_38;
    end
  end
  var logic [7:0]  reg_3 = 8'h0;
  always @(posedge clk) begin
    if (rst) begin
      reg_3 <= 8'h0;
    end
    else if (_GEN_43) begin
      reg_3 <= _GEN_39;
    end
  end
  assign out = _GEN_44;
  assign out_xz = _GEN_45;
endmodule
