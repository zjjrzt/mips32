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
    rom u_rom(
        .addr(iaddr[4:0]),
        .data(idata)
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
    initial begin
        rst_n = 0;
        #100;
        rst_n = 1;
        #10000;
        $stop;
    end
endmodule
