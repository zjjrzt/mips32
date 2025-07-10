module exemem_reg(
    input wire clk,
    input wire rst_n,
    input wire [7:0] exe_aluop,    //ALU操作码
    input wire [4:0] exe_wa,       //写回地址
    input wire [31:0] exe_wd,       //写回数据
    input wire exe_wreg,     //是否写入寄存器堆
    input wire exe_mreg,     //是否访问寄存器堆
    input wire exe_whilo,    //是否写入HI/LO寄存器
    input wire[31:0] exe_din,       //写入寄存器堆的数据
    input wire[63:0] exe_hilo,    //HI/LO寄存器数据

    output reg [7:0] mem_aluop,
    output reg [4:0] mem_wa,
    output reg [31:0] mem_wd,
    output reg mem_wreg,
    output reg mem_mreg,
    output reg mem_whilo,
    output reg [31:0] mem_din,
    output reg [63:0] mem_hilo,
    input wire [3:0] stall
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mem_aluop  <= 8'b0;
        mem_wa     <= 5'b0;
        mem_wd     <= 32'b0;
        mem_wreg   <= 1'b0;
        mem_mreg   <= 1'b0;
        mem_whilo  <= 1'b0;
        mem_din    <= 32'b0;
        mem_hilo   <= 64'b0;
    end else if (stall[3] == 1'b1) begin
        mem_aluop  <= 8'h11;
        mem_wa     <= 5'b00000;
        mem_wd     <= 32'b0;
        mem_wreg   <= 1'b0;
        mem_mreg   <= 1'b0;
        mem_whilo  <= 1'b0;
        mem_din    <= 32'b0;
        mem_hilo   <= 64'b0;
    end
    else if (stall[3] == 1'b0) begin
        mem_aluop  <= exe_aluop;
        mem_wa     <= exe_wa;
        mem_wd     <= exe_wd;
        mem_wreg   <= exe_wreg;
        mem_mreg   <= exe_mreg;
        mem_whilo  <= exe_whilo;
        mem_din    <= exe_din;
        mem_hilo   <= exe_hilo;
    end
end

endmodule