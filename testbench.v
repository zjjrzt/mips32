`timescale 1ns/1ps

module testbench;
    reg clk;
    reg rst_n;
    wire [16:0] led;
    wire [2:0] rgb_reg0;
    wire [2:0] rgb_reg1;
    wire [7:0] num_csn;
    wire [6:0] num_a_g;
    minips32 u_minips32(
        .clk(clk),
        .rst_n(rst_n),
        .led(led),
        .rgb_reg0(rgb_reg0),
        .rgb_reg1(rgb_reg1),
        .num_csn(num_csn),
        .num_a_g(num_a_g)
    );


    // 50MHz时钟
    initial clk = 0;
    always #10 clk = ~clk; // 20ns周期
    initial begin
        rst_n = 0; // 复位信号
        #100; // 等待100ns
        rst_n = 1; // 解除复位
    end


endmodule
