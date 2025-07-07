//译码-执行寄存器
module idexe_reg(
    input wire clk,
    input wire rst_n,
    input wire [2:0] id_alutype,  //ALU操作类型
    input wire [7:0] id_aluop,    //ALU操作码
    input wire [31:0] id_src1,     //源操作数1
    input wire [31:0] id_src2,     //源操作数2
    input wire [4:0] id_wa,       //写入寄存器堆的地址
    input wire id_wreg,     //是否写入寄存器堆
    input wire id_mreg,     //是否写入数据存储器
    input wire [31:0] id_din,       //写入寄存器堆的数据
    input wire id_whilo,    //是否写入HI/LO寄存器

    //送至执行阶段的信息
    output reg [2:0] exe_alutype,
    output reg [7:0] exe_aluop,
    output reg [31:0] exe_src1,
    output reg [31:0] exe_src2,
    output reg [4:0] exe_wa,
    output reg exe_wreg,
    output reg exe_mreg,
    output reg [31:0] exe_din,
    output reg exe_whilo
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        exe_alutype <= 3'b0;
        exe_aluop   <= 8'b0;
        exe_src1    <= 32'b0;
        exe_src2    <= 32'b0;
        exe_wa      <= 5'b0;
        exe_wreg    <= 1'b0;
        exe_mreg    <= 1'b0;
        exe_din     <= 32'b0;
        exe_whilo   <= 1'b0;
    end else begin
        exe_alutype <= id_alutype;
        exe_aluop   <= id_aluop;
        exe_src1    <= id_src1;
        exe_src2    <= id_src2;
        exe_wa      <= id_wa;
        exe_wreg    <= id_wreg;
        exe_mreg    <= id_mreg;
        exe_din     <= id_din;
        exe_whilo   <= id_whilo;
    end
end

endmodule