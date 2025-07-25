module data(
    input wire clk,
    input wire rst_n,
    input wire [6:0] data_in,
    input wire [7:0] addr_in,
    output wire [41:0] data_out,
    output wire [5:0] point,
    output wire seg_en,
    output wire sign
);
assign point = 6'b000000; // 默认小数点不显示
assign seg_en = 1'b1; // 默认使能数码管显示
assign sign = 1'b0; // 默认不显示负号

wire [6:0] data_reg_1;
wire [6:0] data_reg_2;
wire [6:0] data_reg_3;
wire [6:0] data_reg_4;
wire [6:0] data_reg_5;
wire [6:0] data_reg_6;

assign data_reg_1 = (addr_in == 8'b01111111) ? data_in : 7'b0;
assign data_reg_2 = (addr_in == 8'b10111111) ? data_in : 7'b0;
assign data_reg_3 = (addr_in == 8'b11011111) ? data_in : 7'b0;
assign data_reg_4 = (addr_in == 8'b11111011) ? data_in : 7'b0;
assign data_reg_5 = (addr_in == 8'b11111101) ? data_in : 7'b0;
assign data_reg_6 = (addr_in == 8'b11111110) ? data_in : 7'b0;

// 将 data_out 设置为 data_reg_1 到 data_reg_6 的加权加和
assign data_out = {data_reg_1, data_reg_2, data_reg_3, data_reg_4, data_reg_5, data_reg_6};

endmodule
