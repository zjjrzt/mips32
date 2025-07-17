module mem_stage(
    input wire rst_n,

    input wire [7:0] mem_aluop_i,    //ALU操作码
    input wire [4:0] mem_wa_i,       //写回地址
    input wire mem_wreg_i,     //是否写入寄存器堆
    input wire mem_mreg_i,     //是否访问寄存器堆
    input wire [31:0] mem_wd_i,       //写回数据
    input wire [31:0] mem_din_i,       //写入寄存器堆的数据
    input wire [63:0] mem_hilo_i,      //HI/LO寄存器数据
    input wire mem_whilo_i,              //是否写入HI/LO寄存器

    output wire [31:0] mem_dreg_o,      //从寄存器堆读出的数据
    output wire [4:0] mem_wa_o,       //写回地址
    output wire mem_wreg_o,     //是否写入寄存器堆
    output wire mem_mreg_o,     //是否访问寄存器堆
    output wire [3:0] dre,
    output wire mem_whilo_o,    //是否写入HI/LO寄存器
    output wire [63:0] mem_hilo_o,    //HI/LO寄存器数据
    output wire dce,
    output wire [31:0] daddr,       //数据存储器地址
    output wire [31:0] din,         //数据存储器写入数据
    output wire [3:0] we,          // 新增we端口

    input wire cp0_we_i,
    input wire [4:0] cp0_waddr_i,
    input wire [31:0] cp0_wdata_i,
    input wire wb2mem_cp0_we,
    input wire [4:0] wb2mem_cp0_wa,
    input wire [31:0] wb2mem_cp0_wd,
    input wire [31:0] mem_pc_i,
    input wire mem_in_delay_i,
    input wire [4:0] mem_exccode_i,
    input wire [31:0] cp0_status,
    input wire [31:0] cp0_cause,
    output wire cp0_we_o,
    output wire [4:0] cp0_waddr_o,
    output wire [31:0] cp0_wdata_o,
    output wire [31:0] cp0_pc,
    output wire cp0_in_delay,
    output wire [4:0] cp0_exccode
);

    // 指令类型判定
    wire inst_lb = (mem_aluop_i == 8'h90);
    wire inst_lw = (mem_aluop_i == 8'h92);
    wire inst_sb = (mem_aluop_i == 8'h98);
    wire inst_sw = (mem_aluop_i == 8'h9A);

    // 数据存储器字节使能
    assign dre[3] = (rst_n == 1'b0) ? 1'b0 : (((inst_lb | inst_sb) & (mem_wd_i[1:0] == 2'b00)) | inst_lw | inst_sw);
    assign dre[2] = (rst_n == 1'b0) ? 1'b0 : (((inst_lb | inst_sb) & (mem_wd_i[1:0] == 2'b01)) | inst_lw | inst_sw);
    assign dre[1] = (rst_n == 1'b0) ? 1'b0 : (((inst_lb | inst_sb) & (mem_wd_i[1:0] == 2'b10)) | inst_lw | inst_sw);
    assign dre[0] = (rst_n == 1'b0) ? 1'b0 : (((inst_lb | inst_sb) & (mem_wd_i[1:0] == 2'b11)) | inst_lw | inst_sw);

    // 数据存储器片选
    assign dce = (rst_n == 1'b0) ? 1'b0 : (inst_lb | inst_lw | inst_sb | inst_sw);
    // 数据存储器地址
    assign daddr = (rst_n == 1'b0) ? 32'b0 : mem_wd_i;

    // 写使能信号（内部）
    wire [3:0] we_internal;
    assign we_internal[3] = (rst_n == 1'b0) ? 1'b0 : ((inst_sb | inst_sw) ? dre[3] : 1'b0);
    assign we_internal[2] = (rst_n == 1'b0) ? 1'b0 : ((inst_sb | inst_sw) ? dre[2] : 1'b0);
    assign we_internal[1] = (rst_n == 1'b0) ? 1'b0 : ((inst_sb | inst_sw) ? dre[1] : 1'b0);
    assign we_internal[0] = (rst_n == 1'b0) ? 1'b0 : ((inst_sb | inst_sw) ? dre[0] : 1'b0);
    assign we = we_internal;

    // 写入数据（大端转小端/字节扩展）
    wire [31:0] din_reverse = {mem_din_i[7:0], mem_din_i[15:8], mem_din_i[23:16], mem_din_i[31:24]};
    wire [31:0] din_byte    = {mem_din_i[7:0], mem_din_i[7:0], mem_din_i[7:0], mem_din_i[7:0]};
    assign din = (rst_n == 1'b0) ? 32'b0 :
                 (we == 4'b1111) ? din_reverse :
                 (we == 4'b1000) ? din_byte :
                 (we == 4'b0100) ? din_byte :
                 (we == 4'b0010) ? din_byte :
                 (we == 4'b0001) ? din_byte : 32'b0;

    // 直通信号
    assign mem_wa_o    = (rst_n == 1'b0) ? 5'b0  : mem_wa_i;
    assign mem_wreg_o  = (rst_n == 1'b0) ? 1'b0  : mem_wreg_i;
    assign mem_dreg_o  = (rst_n == 1'b0) ? 32'b0 : mem_wd_i;
    assign mem_whilo_o = (rst_n == 1'b0) ? 1'b0  : mem_whilo_i;
    assign mem_hilo_o  = (rst_n == 1'b0) ? 64'b0 : mem_hilo_i;
    assign mem_mreg_o  = (rst_n == 1'b0) ? 1'b0  : mem_mreg_i;
    //直接送往写回阶段的信号
    assign cp0_we_o = (rst_n == 1'b0) ? 1'b0 : cp0_we_i;
    assign cp0_waddr_o = (rst_n == 1'b0) ? 5'b0 : cp0_waddr_i;
    assign cp0_wdata_o = (rst_n == 1'b0) ? 32'b0 : cp0_wdata_i;
    //cp0中status和cause寄存器的值
    wire [31:0] status = (wb2mem_cp0_we && wb2mem_cp0_wa == 12) ? wb2mem_cp0_wd : cp0_status;
    wire [31:0] cause = (wb2mem_cp0_we && wb2mem_cp0_wa == 13) ? wb2mem_cp0_wd : cp0_cause;
    //生成输入到cp0协处理器的信号
    assign cp0_in_delay = (rst_n == 1'b0) ? 1'b0 : mem_in_delay_i;
    reg [4:0] cp0_exccode_r;
    assign cp0_exccode = cp0_exccode_r;
    always @(*) begin
        if (rst_n == 1'b0)
            cp0_exccode_r = 5'h00;
        else if ((status[15:10] & cause[15:10]) != 8'h00 && status[1] == 1'b0 && status[0] == 1'b1)
            cp0_exccode_r = 5'h00;
        else
            cp0_exccode_r = mem_exccode_i;
    end
    assign cp0_pc = (rst_n == 1'b0) ? 32'h00000000 : mem_pc_i;

endmodule

