//取指模块
module if_stage
(
    input wire clk,             //时钟信号
    input wire rst_n,           //复位信号
    output reg ice,             //指令有效信号
    output reg [31:0] pc,      //pc寄存器的值，表示读取指令的地址
    output wire [31:0] iaddr,   //指令地址
    //增加转移指令有关代码
    input wire [31:0] jump_addr_1, //跳转指令的地址1
    input wire [31:0] jump_addr_2, //跳转指令的地址2
    input wire [31:0] jump_addr_3,  //跳转指令的地址
    input wire [1:0] jtsel,       //跳转选择信号
    output wire [31:0] pc_plus_4
);

wire [31:0] pc_next; //下一个pc值
assign pc_plus_4 = (rst_n) ? pc + 4 : 32'h00000000; //pc加4的值
assign pc_next = (jtsel == 2'b00) ? pc_plus_4 :
                    (jtsel == 2'b01) ? jump_addr_1 :
                    (jtsel == 2'b10) ? jump_addr_3 :
                    (jtsel == 2'b11) ? jump_addr_2 : 32'h00000000;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ice <= 1'b0; //复位时指令无效
    end
    else begin
        ice <= 1'b1; //时钟上升沿有效
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pc <= 32'h00000000; //复位时pc的初始值
    end
    else begin
        pc <= pc_next; //时钟上升沿更新pc值
    end
end

assign iaddr = (ice) ? pc : 32'h00000000; //指令地址

endmodule