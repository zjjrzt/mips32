`timescale 1ns / 1ps
module testbench_n;    
class transaction;
    // Transaction class definition
    logic [31:0] expected_addr;
    logic [31:0] received_data;
    logic [31:0] idata;
endclass

logic clk;
logic rst_n;
logic ice;
logic dce;
logic [31:0] iaddr;
logic [31:0] idata;
logic [31:0] daddr;
logic [3:0] we;
logic [31:0] din;
logic [31:0] dm;

top u_top(
    .clk(clk),
    .rst_n(rst_n),
    .iaddr(iaddr),
    .ice(ice),
    .inst(idata),
    .dce(dce),
    .daddr(daddr),
    .we(we),
    .din(din),
    .dm(dm)
);



initial begin
    clk = 0;
    forever begin
        #5 clk = ~clk;
    end
end

initial begin
transaction t;
transaction t2[$]; // 队列声明放在模块作用域
    t = new();
    t.idata = 32'h0000_0000; // 初始化idata
    idata = t.idata; // 将idata赋值给idata信号
    rst_n = 0;
    repeat(10) @(posedge clk);
    rst_n = 1;
    @(posedge clk);
    t.idata = 32'h1000_0008;
    idata = t.idata; // 将idata赋值给idata信号
    t.expected_addr = 32'h0000_0040; // 预期地址
    @(posedge clk);
    t.received_data = iaddr; // 接收地址
    t2.push_back(t); // 将t添加到t2数组中
    t = new(); // 新建对象，避免多次push_back同一个对象
    t.idata = 32'h1000_000C;
    idata = t.idata; // 将idata赋值给idata信号
    repeat(10) @(posedge clk);
    t.expected_addr = 32'h0000_0040; // 预期地址
    @(posedge clk);
    t.received_data = iaddr; // 接收地址
    t2.push_back(t);
    t = new();
    @(posedge clk);
    t.idata = 32'h0000_0000;
    idata = t.idata; // 将idata赋值给idata信号
    t.expected_addr = 32'h0000_0044; // 预期地址
    t.received_data = iaddr; // 接收地址
    t2.push_back(t);
    repeat(10) @(posedge clk);
    t = new();
    t.idata = 32'h0800_4000;
    idata = t.idata; // 将idata赋值给idata信号
    repeat(10) @(posedge clk);
    t = new();
    t.idata = 32'h0928_4000;
    idata = t.idata; // 将idata赋值给idata信号
    repeat(10) @(posedge clk);


    $stop;
end
endmodule