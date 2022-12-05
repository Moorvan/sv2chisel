module Counter(
  input        clock,
  input        reset,
  output [7:0] io_out
);
  reg [7:0] reg_; // @[Counter.scala 9:20]
  wire [7:0] _reg_T_1 = reg_ + 8'h1; // @[Counter.scala 13:16]
  assign io_out = reg_; // @[Counter.scala 16:10]
  always @(posedge clock) begin
    if (reset) begin // @[Counter.scala 9:20]
      reg_ <= 8'h0; // @[Counter.scala 9:20]
    end else if (reg_ == 8'ha) begin // @[Counter.scala 10:22]
      reg_ <= 8'h0; // @[Counter.scala 11:9]
    end else begin
      reg_ <= _reg_T_1; // @[Counter.scala 13:9]
    end
  end
endmodule

module Counter2(
  input        clock,
  input        reset,
  output [7:0] io_out
);
  reg [7:0] reg_; // @[Counter.scala 9:20]
  wire [7:0] _reg_T_1 = reg_ + 8'h1; // @[Counter.scala 13:16]
  assign io_out = reg_; // @[Counter.scala 16:10]
  always @(posedge clock) begin
    if (reset) begin // @[Counter.scala 9:20]
      reg_ <= 8'h0; // @[Counter.scala 9:20]
    end else if (reg_ == 8'ha) begin // @[Counter.scala 10:22]
      reg_ <= 8'h0; // @[Counter.scala 11:9]
    end else begin
      reg_ <= _reg_T_1; // @[Counter.scala 13:9]
    end
  end
endmodule