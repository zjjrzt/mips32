`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/10
// Module Name   : seg_595_dynamic
// Project Name  : top_seg_595
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 数码管动态显示
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  seg_595_dynamic
(
    input   wire            sys_clk     , //系统时钟，频率50MHz
    input   wire            sys_rst_n   , //复位信号，低有效
    input   wire    [41:0]  data        , //数码管要显示的值
    input   wire    [5:0]   point       , //小数点显示,高电平有效
    input   wire            seg_en      , //数码管使能信号，高电平有效
    input   wire            sign        , //符号位，高电平显示负号
    input wire [15:0] led,

    output  wire            stcp        , //数据存储器时钟
    output  wire            shcp        , //移位寄存器时钟
    output  wire            ds          , //串行数据输入
    output  wire            oe            //使能信号

);

//********************************************************************//
//******************** Parameter And Internal Signal *****************//
//********************************************************************//
//wire  define
wire    [5:0]   sel;    //数码管位选信号
wire    [7:0]   seg;    //数码管段选信号
wire [7:0] seg_reg1;
wire [7:0] seg_reg2;
wire [7:0] seg_reg3;
wire [7:0] seg_reg4;
wire [7:0] seg_reg5;
wire [7:0] seg_reg6;
assign seg_reg1 = {1'b1, data[35],data[36],data[37],data[38],data[39],data[40],data[41]}; // 添加1'b1以确保小数点显示
assign seg_reg2 = {1'b1, data[28],data[29],data[30],data[31],data[32],data[33],data[34]}; // 添加1'b1以确保小数点显示
assign seg_reg3 = {1'b1, data[21],data[22],data[23],data[24],data[25],data[26],data[27]}; // 添加1'b1以确保小数点显示
assign seg_reg4 = {1'b1, data[14],data[15],data[16],data[17],data[18],data[19],data[20]}; // 添加1'b1以确保小数点显示
//assign seg_reg5 = {1'b1, data[7],data[8],data[9],data[10],data[11],data[12],data[13]}; // 添加1'b1以确保小数点显示
//assign seg_reg6 = {1'b1, data[0],data[1],data[2],data[3],data[4],data[5],data[6]}; // 添加1'b1以确保小数点显示
assign seg_reg5 = led[7:0]; // 使用 led 的低8位作为 seg_reg5
assign seg_reg6 = led[15:8]; // 使用 led 的高8位作为 seg_reg6

// 定义计数器用于选择 seg_reg 和 sel
reg [2:0] sel_counter;

// 在 stcp 的上升沿更新 seg 和 sel
always @(posedge stcp or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        sel_counter <= 3'd0;
    end else begin
        sel_counter <= (sel_counter == 3'd5) ? 3'd0 : sel_counter + 1;
    end
end

// 根据 sel_counter 选择 seg 和 sel
assign seg = (sel_counter == 3'd0) ? seg_reg1 :
             (sel_counter == 3'd1) ? seg_reg2 :
             (sel_counter == 3'd2) ? seg_reg3 :
             (sel_counter == 3'd3) ? seg_reg4 :
             (sel_counter == 3'd4) ? seg_reg5 : seg_reg6;

assign sel = (sel_counter == 3'd0) ? 6'b100000 :
             (sel_counter == 3'd1) ? 6'b010000 :
             (sel_counter == 3'd2) ? 6'b001000 :
             (sel_counter == 3'd3) ? 6'b000100 :
             (sel_counter == 3'd4) ? 6'b000010 : 6'b000001;

//---------- hc595_ctrl_inst ----------
hc595_ctrl  hc595_ctrl_inst
(
    .sys_clk     (sys_clk  ),   //系统时钟，频率50MHz
    .sys_rst_n   (sys_rst_n),   //复位信号，低有效
    .sel         (sel      ),   //数码管位选信号
    .seg         (seg      ),   //数码管段选信号

    .stcp        (stcp     ),   //输出数据存储寄时钟
    .shcp        (shcp     ),   //移位寄存器的时钟输入
    .ds          (ds       ),   //串行数据输入
    .oe          (oe       )

);

endmodule
