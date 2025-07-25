`timescale 1ns/1ps

module testbench;
    reg clk;
    reg rst_n;
    wire [15:0] led;
    wire [2:0] rgb_reg0;
    wire [2:0] rgb_reg1;
    wire [7:0] num_csn;
    wire [6:0] num_a_g;
    mips32 u_mips32(
        .clk(clk),
        .rst_n(rst_n),
        .led(led),
        .rgb_reg0(rgb_reg0),
        .rgb_reg1(rgb_reg1),
        .num_csn(num_csn),
        .num_a_g(num_a_g)
    );


    initial begin
        rst_n = 0; // 复位信号
        #50; // 等待90ns
        rst_n = 1; // 解除复位
    end
    initial begin
        clk = 0;
        #100; // 等待100ns
        forever begin
            clk = ~clk; // 反转时钟信号
            #10; // 每次反转间隔10ns
        end
    end

endmodule
