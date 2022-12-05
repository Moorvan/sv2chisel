module Memory(
  input        clock,
  input        reset,
  input        io_wrEna,
  input  [7:0] io_wrData,
  input  [9:0] io_wrAddr,
  input  [9:0] io_rdAddr,
  output [7:0] io_rdData
);
  wire  resetCounter_clk; // @[Formal.scala 10:36]
  wire  resetCounter_reset; // @[Formal.scala 10:36]
  wire [31:0] resetCounter_timeSinceReset; // @[Formal.scala 10:36]
  wire  resetCounter_notChaos; // @[Formal.scala 10:36]
  reg [7:0] mem [0:1023]; // @[Memory.scala 16:16]
  wire  mem_io_rdData_MPORT_en; // @[Memory.scala 16:16]
  wire [9:0] mem_io_rdData_MPORT_addr; // @[Memory.scala 16:16]
  wire [7:0] mem_io_rdData_MPORT_data; // @[Memory.scala 16:16]
  wire [7:0] mem_MPORT_data; // @[Memory.scala 16:16]
  wire [9:0] mem_MPORT_addr; // @[Memory.scala 16:16]
  wire  mem_MPORT_mask; // @[Memory.scala 16:16]
  wire  mem_MPORT_en; // @[Memory.scala 16:16]
  wire [9:0] addr_cst_out; // @[Formal.scala 85:21]
  wire  flag_clk; // @[Formal.scala 78:21]
  wire  flag_reset; // @[Formal.scala 78:21]
  wire  flag_in; // @[Formal.scala 78:21]
  wire  flag_out; // @[Formal.scala 78:21]
  reg [7:0] data; // @[Memory.scala 29:23]
  wire  flag_value = io_wrAddr == addr_cst_out & io_wrEna; // @[Memory.scala 32:27]
  wire  _T_4 = io_rdAddr == addr_cst_out & flag_out; // @[Memory.scala 36:27]
  assign mem_io_rdData_MPORT_en = 1'h1;
  assign mem_io_rdData_MPORT_addr = io_rdAddr;
  assign mem_io_rdData_MPORT_data = mem[mem_io_rdData_MPORT_addr]; // @[Memory.scala 16:16]
  assign mem_MPORT_data = io_wrData;
  assign mem_MPORT_addr = io_wrAddr;
  assign mem_MPORT_mask = 1'h1;
  assign mem_MPORT_en = io_wrEna;
  assign io_rdData = mem_io_rdData_MPORT_data; // @[Memory.scala 23:13]
  assign resetCounter_clk = clock; // @[Formal.scala 11:23]
  assign resetCounter_reset = reset; // @[Formal.scala 12:25]
  assign flag_clk = clock; // @[Formal.scala 79:16]
  assign flag_reset = reset; // @[Formal.scala 80:18]
  assign flag_in = io_wrAddr == addr_cst_out & io_wrEna; // @[Memory.scala 32:27]
  always @(posedge clock) begin
    if (mem_MPORT_en & mem_MPORT_mask) begin
      mem[mem_MPORT_addr] <= mem_MPORT_data; // @[Memory.scala 16:16]
    end
    if (flag_value) begin // @[Memory.scala 32:39]
      data <= io_wrData; // @[Memory.scala 34:10]
    end
  end
endmodule
