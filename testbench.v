`timescale 1ns/1ps

module testbench;
    reg clk;
    reg rst_n;
    wire [31:0] iaddr;
    wire ice;
    wire [31:0] idata;
    wire dce;
    wire [31:0] daddr;
    wire [3:0] we;
    wire [31:0] din;
    wire [31:0] dm;

    // 指令ROM实例化
    blk_mem_gen_0 your_instance_name (
  .clka(clk),    // input wire clka
  .ena(ice),      // input wire ena
  .wea(0),      // input wire [0 : 0] wea
  .addra(iaddr[10:0]),  // input wire [10 : 0] addra
  .dina(dina),    // input wire [31 : 0] dina
  .douta(idata)  // output wire [31 : 0] douta
);

    // 实例化顶层模块
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

    ram u_ram(
        .clk(clk),
        .ena(dce),
        .wea(we),
        .addr(daddr[9:0]),
        .dina(din),
        .douta(dm)
    );

    // 50MHz时钟
    initial clk = 0;
    always #10 clk = ~clk; // 20ns周期

    // 仿真控制
    integer instr_count;
    initial begin
        rst_n = 0;
        #100;
        rst_n = 1;
        // 等待ROM内所有指令执行完毕（假设每条指令1周期，实际可根据iaddr最大值判断）
        instr_count = 0;
        wait (iaddr == 156); // iaddr到达最后一条指令的下一个地址
        // 再等10个时钟周期
        repeat(10) @(posedge clk);
        $stop;
    end
endmodule
