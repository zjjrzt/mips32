`timescale 1ns/1ps

module testbench;
    reg clk;
    reg rst_n;
    wire [31:0] im_addr_o;
    wire [31:0] im_data_i;
    wire im_ce_o;
    wire [31:0] dm_addr_o;
    reg  [31:0] dm_data_i = 32'b0;
    wire [31:0] dm_data_o;
    wire dm_we_o;
    wire dm_ce_o;

    // 指令ROM实例化
    rom u_rom(
        .addr(im_addr_o[4:0]),
        .data(im_data_i)
    );

    // 实例化顶层模块
    top u_top(
        .clk(clk),
        .rst_n(rst_n),
        .im_addr_o(im_addr_o),
        .im_data_i(im_data_i),
        .im_ce_o(im_ce_o),
        .dm_addr_o(dm_addr_o),
        .dm_data_i(dm_data_i),
        .dm_data_o(dm_data_o),
        .dm_we_o(dm_we_o),
        .dm_ce_o(dm_ce_o)
    );

    // 50MHz时钟
    initial clk = 0;
    always #10 clk = ~clk; // 20ns周期

    // 仿真控制
    initial begin
        rst_n = 0;
        #100;
        rst_n = 1;
        #99900;
        $stop;
    end
endmodule
