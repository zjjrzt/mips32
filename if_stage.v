//取指模块
module if_stage
(
    input wire clk,             //时钟信号
    input wire rst_n,           //复位信号
    output wire ice,             //指令有效信号
    output reg [31:0] pc,      //pc寄存器的值，表示读取指令的地址
    output wire [31:0] iaddr,   //指令地址
    //增加转移指令有关代码
    input wire [31:0] jump_addr_1, //跳转指令的地址1
    input wire [31:0] jump_addr_2, //跳转指令的地址2
    input wire [31:0] jump_addr_3,  //跳转指令的地址
    input wire [1:0] jtsel,       //跳转选择信号
    output wire [31:0] pc_plus_4,
    //添加暂停模块相关代码
    input wire [3:0] stall,
    //流水线异常相关代码
    input wire flush,
    input wire [31:0] cp0_excaddr
);

wire [31:0] pc_next; //下一个pc值
assign pc_plus_4 = (rst_n) ? pc + 4 : 32'h00000000; //pc加4的值
assign pc_next = (jtsel == 2'b00) ? pc_plus_4 :
                    (jtsel == 2'b01) ? jump_addr_1 :
                    (jtsel == 2'b10) ? jump_addr_3 :
                    (jtsel == 2'b11) ? jump_addr_2 : 32'h00000000;

wire ce = (!rst_n) ? 1'b0 : 1'b1; //时钟使能信号
//指令有效信号

assign ice = (stall [1] == 1'b1 || flush) ? 0 : ce; //指令有效信号
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pc <= 32'h00000000; //复位时pc的初始值
    end
    else begin
        if (flush) begin
            pc <= cp0_excaddr;
        end
        else if (stall[0] == 1'b0) begin
            pc <= pc_next; //更新pc值
        end
    end
end

assign iaddr = (ice) ? pc : 32'h00000000; //指令地址

endmodule