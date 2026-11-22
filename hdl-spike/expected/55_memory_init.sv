module ArrayRamInit(
  input  [63:0] addr,
  input  [7:0]  wd,
  input         we,
                clk,
                rst,
  output [7:0]  out
);
  var logic [7:0] array_ram_1[0:3];
  initial begin
    array_ram_1[2'h0] = 8'h9;
    array_ram_1[2'h1] = 8'h9;
    array_ram_1[2'h2] = 8'h9;
    array_ram_1[2'h3] = 8'h9;
  end
  always_ff @(posedge clk) begin
    if (rst) begin
      array_ram_1[2'h0] <= 8'h1;
      array_ram_1[2'h1] <= 8'h2;
      array_ram_1[2'h2] <= 8'h3;
      array_ram_1[2'h3] <= 8'h4;
    end
    else begin
      if (we)
        array_ram_1[addr[1:0]] <= wd;
    end
  end
  assign out = array_ram_1[addr[1:0]];
endmodule
module ArrayRamInitLow(
  input  [63:0] addr,
  input  [7:0]  wd,
  input         we,
                clk,
                rst_n,
  output [7:0]  out
);
  wire            _GEN = ~rst_n;
  var logic [7:0] array_ram_1[0:3];
  initial begin
    array_ram_1[2'h0] = 8'h1;
    array_ram_1[2'h1] = 8'h2;
    array_ram_1[2'h2] = 8'h3;
    array_ram_1[2'h3] = 8'h4;
  end
  always_ff @(posedge clk or posedge _GEN) begin
    if (_GEN) begin
      array_ram_1[2'h0] <= 8'h1;
      array_ram_1[2'h1] <= 8'h2;
      array_ram_1[2'h2] <= 8'h3;
      array_ram_1[2'h3] <= 8'h4;
    end
    else begin
      if (we)
        array_ram_1[addr[1:0]] <= wd;
    end
  end
  assign out = array_ram_1[addr[1:0]];
endmodule
module RamInit(
  input  [63:0] addr,
  input  [7:0]  wd,
  input         we,
                clk,
                rst,
  output [7:0]  out
);
  var logic [7:0] ram_1[0:3];
  initial begin
    ram_1[2'h0] = 8'h9;
    ram_1[2'h1] = 8'h9;
    ram_1[2'h2] = 8'h9;
    ram_1[2'h3] = 8'h9;
  end
  always_ff @(posedge clk) begin
    if (rst) begin
      ram_1[2'h0] <= 8'h1;
      ram_1[2'h1] <= 8'h2;
      ram_1[2'h2] <= 8'h3;
      ram_1[2'h3] <= 8'h4;
    end
    else begin
      if (we)
        ram_1[addr[1:0]] <= wd;
    end
  end
  assign out = ram_1[addr[1:0]];
endmodule
module RamInitAsync(
  input  [63:0] addr,
  input  [7:0]  wd,
  input         we,
                clk,
                rst,
  output [7:0]  out
);
  var logic [7:0] ram_1[0:3];
  initial begin
    ram_1[2'h0] = 8'h1;
    ram_1[2'h1] = 8'h2;
    ram_1[2'h2] = 8'h3;
    ram_1[2'h3] = 8'h4;
  end
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      ram_1[2'h0] <= 8'h1;
      ram_1[2'h1] <= 8'h2;
      ram_1[2'h2] <= 8'h3;
      ram_1[2'h3] <= 8'h4;
    end
    else begin
      if (we)
        ram_1[addr[1:0]] <= wd;
    end
  end
  assign out = ram_1[addr[1:0]];
endmodule
