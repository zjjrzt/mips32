module memwb_reg(
    input wire clk,
    input wire rst_n,

    input wire [31:0] mem_dreg,      //从寄存器堆读出的数据
    input wire [4:0] mem_wa,       //写回地址
    input wire mem_wreg,     //是否写入寄存器堆
    input wire mem_mreg,     //是否访问寄存器堆
    input wire [3:0] dre,
    input wire mem_whilo,    //是否写入HI/LO寄存器
    input wire [63:0] mem_hilo,    //HI/LO寄存器数据
    output reg [31:0] wb_dreg,
    output reg [4:0] wb_wa,
    output reg wb_wreg,
    output reg wb_mreg,
    output reg [3:0] wb_dre,
    output reg wb_whilo,
    output reg [63:0] wb_hilo,

    input wire mem_cp0_we,
    input wire [4:0] mem_cp0_waddr,
    input wire [31:0] mem_cp0_wdata,
    input wire flush,
    output reg wb_cp0_we,
    output reg [4:0] wb_cp0_waddr,
    output reg [31:0] wb_cp0_wdata
);

always @(posedge clk or negedge rst_n or posedge flush) begin
    if (!rst_n || flush) begin
        wb_dreg   <= 32'b0;
        wb_wa     <= 5'b0;
        wb_wreg   <= 1'b0;
        wb_mreg   <= 1'b0;
        wb_dre    <= 4'b0;
        wb_whilo  <= 1'b0;
        wb_hilo   <= 64'b0;
        wb_cp0_we <= 1'b0;
        wb_cp0_waddr <= 5'b0;
        wb_cp0_wdata <= 32'b0;
    end else begin
        wb_dreg   <= mem_dreg;
        wb_wa     <= mem_wa;
        wb_wreg   <= mem_wreg;
        wb_mreg   <= mem_mreg;
        wb_dre    <= dre;
        wb_whilo  <= mem_whilo;
        wb_hilo   <= mem_hilo;
        wb_cp0_we <= mem_cp0_we;
        wb_cp0_waddr <= mem_cp0_waddr;
        wb_cp0_wdata <= mem_cp0_wdata;
    end
end

endmodule