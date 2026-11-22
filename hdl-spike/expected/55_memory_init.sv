module ArrayRamInit(
  input  wire [63:0] addr,
  input  wire [7:0]  wd,
  input  wire        we,
  input  wire        clk,
  input  wire        rst,
  output wire [7:0]  out
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
      if (we) begin
        array_ram_1[addr[1:0]] <= wd;
      end
    end
  end
  assign out = array_ram_1[addr[1:0]];
endmodule
module ArrayRamInitLow(
  input  wire [63:0] addr,
  input  wire [7:0]  wd,
  input  wire        we,
  input  wire        clk,
  input  wire        rst_n,
  output wire [7:0]  out
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
      if (we) begin
        array_ram_1[addr[1:0]] <= wd;
      end
    end
  end
  assign out = array_ram_1[addr[1:0]];
endmodule
module RamInit(
  input  wire [63:0] addr,
  input  wire [7:0]  wd,
  input  wire        we,
  input  wire        clk,
  input  wire        rst,
  output wire [7:0]  out
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
      if (we) begin
        ram_1[addr[1:0]] <= wd;
      end
    end
  end
  assign out = ram_1[addr[1:0]];
endmodule
module RamInitAsync(
  input  wire [63:0] addr,
  input  wire [7:0]  wd,
  input  wire        we,
  input  wire        clk,
  input  wire        rst,
  output wire [7:0]  out
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
      if (we) begin
        ram_1[addr[1:0]] <= wd;
      end
    end
  end
  assign out = ram_1[addr[1:0]];
endmodule
