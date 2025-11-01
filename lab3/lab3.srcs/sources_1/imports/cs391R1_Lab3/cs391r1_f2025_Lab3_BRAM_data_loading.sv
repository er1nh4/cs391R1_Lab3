module test_simulation();

bit clk;
bit rst;

wire awready;
bit awvalid;
bit[19:0] awaddr;
wire wready;
bit wvalid;
bit[31:0] wdata;
bit bready;
wire bvalid;
wire[1:0] bresp;
wire arready;
bit arvalid;
bit[19:0] araddr;
bit rready;
wire rvalid;
wire[31:0] rdata;

reg _rst;
reg _awvalid;
reg[19:0] _awaddr;
reg _wvalid;
reg[31:0] _wdata;
reg _bready;
reg _arvalid;
reg[19:0] _araddr;
reg _rready;

always #5ns begin
    clk = ~clk;
end

always @ (posedge clk) begin
    _rst <= rst;
    _awvalid <= awvalid;
    _awaddr <= awaddr;
    _wvalid <= wvalid;
    _wdata <= wdata;
    _bready <= bready;
    _arvalid <= arvalid;
    _araddr <= araddr;
    _rready <= rready;
end

axi_bram_ctrl_0 my_bram(
    .s_axi_aclk(clk),
    .s_axi_aresetn(~rst),
    .s_axi_araddr(_araddr),
    .s_axi_arprot(0),
    .s_axi_arready(arready),
    .s_axi_arvalid(_arvalid),
    .s_axi_awaddr(_awaddr),
    .s_axi_awprot(0),
    .s_axi_awready(awready),
    .s_axi_awvalid(_awvalid),
    .s_axi_bready(_bready),
    .s_axi_bresp(bresp),
    .s_axi_bvalid(bvalid),
    .s_axi_rdata(rdata),
    .s_axi_rready(_rready),
    .s_axi_rvalid(rvalid),
    .s_axi_wdata(_wdata),
    .s_axi_wready(wready),
    .s_axi_wstrb('b1111),
    .s_axi_wvalid(_wvalid) 
);

reg [7:0] my_memory[511:0];

initial begin

    rst = 1;
    #20ns;
    rst = 0;
    #20ns;

    $readmemh("/.../lab3_binary.hex", my_memory);

    #40ns;

    for (int i = 0; i < 512; i+=4) begin
        awvalid = 1;
        wvalid = 1;
        awaddr = i;
        wdata = {my_memory[i], my_memory[i+1], my_memory[i+2], my_memory[i+3]}; // be careful with endianness...
        #20ns;
        awvalid = 0;
        wvalid = 0;
        bready = 1;
        #20ns;
        bready = 0;
        #20ns;
    end

    #20ns;

    // actual test-bench starts here...

    $finish;
end

endmodule