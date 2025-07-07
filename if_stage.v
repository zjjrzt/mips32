//取指模块
module if_stage
(
    input wire clk,             //时钟信号
    input wire rst_n,           //复位信号
    output reg ice,             //指令有效信号
    output reg [31:0] pc,      //pc寄存器的值，表示读取指令的地址
    output wire [31:0] iaddr   //指令地址
);

wire [31:0] pc_next; //下一个pc值
assign pc_next = pc + 4;

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
        pc <= 32'h00003000; //复位时pc的初始值
    end
    else begin
        pc <= pc_next; //时钟上升沿更新pc值
    end
end

assign iaddr = (ice) ? pc : 32'h00000000; //指令地址

endmodule