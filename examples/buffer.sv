module TOP #(parameter WIDTH = 8, PSIZE = 2, DEPTH = 2**PSIZE) (
    input 	           clk,
    input 	           rst_n,
    input 	           in_wr,
    input      [WIDTH-1:0] in_wdata,
    input 	           in_rd ,
    output reg [WIDTH-1:0] out_rdata,
    output                 out_empty,
    output reg             out_full
);

reg [WIDTH-1:0] buffer [DEPTH-1:0];
reg [PSIZE-1:0] wrptr;
reg [PSIZE-1:0] rdptr;
wire            pdiff;

//buffer empty flag
assign out_empty = (wrptr==rdptr) & ~out_full;

//buffer full flag
always @(posedge clk)
    if(!rst_n)                        out_full <= 1'b0;
    else if(pdiff && in_wr && !in_rd) out_full <= 1'b1;
    else if(!in_wr && in_rd)          out_full <= 1'b0;
    else                              out_full <= out_full;

assign pdiff = (rdptr == (wrptr + 1'b1));

//write ptr
always @(posedge clk)
    if(!rst_n)     wrptr <= {PSIZE{1'b0}};
    else if(in_wr) wrptr <= (wrptr < (DEPTH-1)) ? (wrptr + 1'b1) : {PSIZE{1'b0}};
    else           wrptr <= wrptr;

//read ptr
always @(posedge clk)
    if(!rst_n)     rdptr <= {PSIZE{1'b0}};
    else if(in_rd) rdptr <= (rdptr < (DEPTH-1)) ? (rdptr + 1'b1) : {PSIZE{1'b0}};
    else           rdptr <= rdptr;

//buffer
always @(posedge clk)
    if(in_wr) buffer[wrptr] <= in_wdata;

//read data from buffer
always @(posedge clk)
    if(!rst_n)     out_rdata <= {WIDTH{1'b0}};
    else if(in_rd) out_rdata <= buffer[rdptr];
    else           out_rdata <= out_rdata;


//Assert Pass
// asm1: assume property(@(posedge clk) out_full |-> !in_wr);
// asm2: assume property(@(posedge clk) out_empty |-> !in_rd);
always @(posedge clk) begin
    if (out_full) 
        assume(!in_wr);
    if (out_empty)
        assume(!in_rd);
end

reg  in_rd_ff1;
reg  flag;
wire rnd_mark;
wire mark_vld;
wire check_vld;

assign mark_vld = in_wr & rnd_mark;
assign check_vld = in_rd_ff1 & (out_rdata == {WIDTH{1'b1}});

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
	in_rd_ff1 <= 1'b0;
    else 
	in_rd_ff1 <= in_rd;
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
	flag <= 1'b0;
    else if(check_vld)
	flag <= 1'b0;
    else if(mark_vld)
	flag <= 1'b1;
end

initial begin
    assume(!rst_n);
end
// asm3: assume property(@(posedge clk) mark_vld |-> in_wdata == {WIDTH{1'b1}});
// asm4: assume property(@(posedge clk) !mark_vld && in_wr |-> in_wdata == {WIDTH{1'b0}});
// asm5: assume property(@(posedge clk) flag |-> !mark_vld);
always @(posedge clk) begin
    if (mark_vld) 
        assume(in_wdata == {WIDTH{1'b1}});
    if (!mark_vld && in_wr) 
        assume(in_wdata == {WIDTH{1'b0}});
    if (flag)
        assume(!mark_vld);
    if (check_vld) 
        assert(flag);
end


// ast1: assert property(@(posedge clk) check_vld |-> flag);


//Assert Fail
// wire check_vld_fail;
// reg  flag_fail;

// assign check_vld_fail = in_rd_ff1 & (out_rdata == {{(WIDTH-1){1'b1}},1'b0});

// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n)
// 	flag_fail <= 1'b0;
//     else if(check_vld_fail)
// 	flag_fail <= 1'b0;
//     else if(mark_vld)
// 	flag_fail <= 1'b1;
// end

// ast1_fail: assert property(@(posedge clk) flag_fail |-> !mark_vld);

// always @(posedge clk) begin
//     if (flag_fail) 
//         assert(!mark_vld);
// end

	
endmodule
