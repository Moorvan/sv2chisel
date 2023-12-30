class Memory extends BlackBox with HasBlackBoxResource {
  val io = IO(new Bundle {
    val clock = Input(Bool())
    val reset = Input(Bool())
    val io_wrEna = Input(Bool())
    val io_wrData = Input(UInt(8.W))
    val io_wrAddr = Input(UInt(10.W))
    val io_rdAddr = Input(UInt(10.W))
    val io_rdData = Output(UInt(8.W))
  })
  addResource("./examples/memory.sv")
}
